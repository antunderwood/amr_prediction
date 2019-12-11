#!/usr/bin/env nextflow
/*
========================================================================================
                          GHRU AMR Pipeline
========================================================================================
*/

// DSL 2
nextflow.preview.dsl=2
include './lib/messages'
include './lib/params_parser'
include './lib/params_utilities.nf'

version = '0.1'
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
params_for_read_polising = rename_params_keys(final_params, read_polising_params_renames)
include polish_reads from '../read_polishing/main' params(params_for_read_polising)

// // include resfinder functionality
// resfinder_params_renames = [
//   "resfinder_min_cov" : "min_cov",
//   "resfinder_identity_threshold" : "identity_threshold",
//   "resfinder_species" : "species",
//   "resfinder_point_mutation" : "point_mutation",
//   "resfinder_db_resfinder" : "db_resfinder",
//   "resfinder_db_pointfinder" : "db_pointfinder"
// ] 
// params_for_resfinder = rename_params_keys(final_params, resfinder_params_renames)
// include './sub_workflows/resfinder/main' params(params_for_resfinder)

// include ariba functionality
ariba_params_renames = [
  "ariba_database_dir" : "database_dir",
  "ariba_extra_summary_arguments" : "extra_summary_arguments",
] 
params_for_ariba = rename_params_keys(final_params, ariba_params_renames)
include ariba from '../ariba/main' params(params_for_ariba)


workflow {
  //Setup input Channel from Read path
  Channel
      .fromFilePairs( final_params.reads_path )
      .ifEmpty { error "Cannot find any reads matching: ${final_params.reads_path}" }
      .set { reads }

  polished_reads = polish_reads(reads)

  // Ariba
  ariba(polished_reads, params_for_ariba.database_dir)

}

workflow.onComplete {
  complete_message(final_params, workflow, version)
}

workflow.onError {
  error_message(workflow)
}