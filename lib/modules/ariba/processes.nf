 process run_ariba {
  container 'bioinformant/ghru-ariba:1.0'

  tag {sample_id}
  publishDir "${params.output_dir}/ariba",
  mode: 'copy'

   input:
   tuple sample_id, file(reads)
   file(database_dir)

   output:
   file("${sample_id}_${database_dir}.report.tsv")

   """
   ariba run ${database_dir} ${reads[0]} ${reads[1]} ${sample_id}.ariba
   mv ${sample_id}.ariba/report.tsv ${sample_id}_${database_dir}.report.tsv
   """
 }

 process ariba_summary {
  container 'bioinformant/ghru-ariba:1.0'
  
  tag {'ariba summary'}
  publishDir "${params.output_dir}/ariba", mode: 'copy'

  input:
  file(report_tsvs)
  file(database_dir)
  val summary_arguments

  output:
  file "ariba_${database_dir}_summary.*"

  script:
  """
  ariba summary ${summary_arguments} ariba_${database_dir}_summary ${report_tsvs}
  """
}