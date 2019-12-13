process combine_ariba_summaries{
    tag {'combine_ariba_summaries'}
    publishDir "${params.output_dir}/ariba", mode: 'copy'

    input:
    file(summary_files)

    output:
    path 'combined_summary.csv'

    script:
    """
    # combine headers
    echo "\$(head -1 ${summary_files[0]}),known_variants,\$(head -1 ${summary_files[1]} | cut -d',' -f2-)" > combined_summary.csv
    # remove headers and sort
    mkdir sorted_summaries
    tail -n +2 ${summary_files[0]} | sort > sorted_summaries/${summary_files[0]}
    # add blank column to 2nd file to add in known_variants column seperator
    tail -n +2 ${summary_files[1]} | sort | awk -F, '\$1=FS\$1' OFS=, > sorted_summaries/${summary_files[1]}
    # join sorted body text
    join -t , -2 2 sorted_summaries/${summary_files[0]} sorted_summaries/${summary_files[1]} >> combined_summary.csv
    """
}