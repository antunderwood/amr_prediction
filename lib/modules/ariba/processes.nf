 process run_ariba {
  tag {sample_id}
  publishDir "${params.output_dir}/ariba",
  mode: 'copy'

   input:
   tuple sample_id, file(reads)
   file(database_dir)

   output:
   file("${sample_id}_${database_dir}.report.csv")

   """
   ariba run ${database_dir} ${reads[0]} ${reads[1]} ${sample_id}.ariba
   mv ${sample_id}.ariba/report.tsv ${sample_id}_${database_dir}.report.csv
   """
 }

 process ariba_summary {
  tag {'ariba summary'}
  publishDir "${params.output_dir}/ariba", mode: 'copy'

  input:
  file(report_tsvs)
  file(database_dir)
  val summary_arguments

  output:
  path "ariba_${database_dir}_summary.csv", emit: summary_csv
  path "ariba_${database_dir}_summary.phandango.*", emit: phandango_files

  script:
  """
  mkdir renamed_reports
  for report_tsv in ${report_tsvs}; do
    mv \$report_tsv renamed_reports/\${report_tsv%_${database_dir}.report.csv}
  done
  renamed_report_files=\$(ls renamed_reports)
  mv renamed_reports/* .
  ariba summary ${summary_arguments} ariba_${database_dir}_summary \$renamed_report_files
  """
}