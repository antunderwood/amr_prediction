#!/usr/bin/env nextflow
/*
========================================================================================
                          GHRU AMR Pipeline
========================================================================================
*/

// DSL 2
nextflow.preview.dsl=2
version = '0.1'
// include workflow modules
include './lib/messages'
include './lib/params_parser'
include './lib/params_utilities'
include './lib/processes'

// setup params
default_params = default_params()
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)

final_params = check_params(merged_params, version)

// include read polishing functionality
read_polising_params_renames = [
  "read_polishing_adapter_file" : "adapter_file",
  "read_polishing_depth_cutoff" : "depth_cutoff"
]
params_for_read_polishing = rename_params_keys(final_params, read_polising_params_renames)
include './lib/modules/read_polishing/workflows' params(params_for_read_polishing)

// include ariba functionality
ariba_params_renames = [
  "ariba_database_dir" : "database_dir",
  "ariba_summary_arguments" : "summary_arguments",
] 
params_for_ariba = rename_params_keys(final_params, ariba_params_renames)
include ariba as ariba_for_acquired from './lib/modules/ariba/workflows' params(params_for_ariba)
include ariba as ariba_for_point from './lib/modules/ariba/workflows' params(params_for_ariba)



workflow {
  //Setup input Channel from Read path
  Channel
      .fromFilePairs( final_params.reads_path )
      .ifEmpty { error "Cannot find any reads matching: ${final_params.reads_path}" }
      .set { reads }

  polished_reads = polish_reads(reads)

  // Run Ariba with ncbi acquired database
  ariba_acquired_summary_output = ariba_for_acquired(polished_reads, params_for_ariba.database_dir, params_for_ariba.summary_arguments)
  if (final_params.species){
    pointfinder_db = file('ariba_databases/pointfinder/' + final_params.species + '_db')
    ariba_point_summary_output = ariba_for_point(polished_reads,pointfinder_db, '--known_variants')
    acquired_and_point_summaries = ariba_acquired_summary_output.summary_file.concat(ariba_point_summary_output.summary_file)
    // acquired_and_point_summaries.view()
    // combine_ariba_summaries(acquired_and_point_summaries)
  }

}

workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}