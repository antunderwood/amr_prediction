process combine_ariba_summaries{
    tag {'combine_ariba_summaries'}
    publishDir "${params.output_dir}/ariba", mode: 'copy'

    input:
    file(summary_files)

    output:
    path 'combined_summary.csv'

    script:
    """
    mkdir sorted_summaries
    tail -n +2 ${summary_files[0]} | sort > sorted_summaries/${summary_files[0]}
    tail -n +2 ${summary_files[1]} | sort > sorted_summaries/${summary_files[1]}
    join sorted_summaries/${summary_files[0]} sorted_summaries/${summary_files[1]} > combined_summary.csv
    """
}