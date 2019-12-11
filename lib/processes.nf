process combine_ariba_summaries{
    tag {'combine_ariba_summaries'}
    input:
    file(summary_files)

    output:

    script:
    """
    mkdir sorted_summaries
    for summary_file in ${summary_files}
    do
        awk 'NR == 1; NR > 1 {print \$0 | "sort -n"}' \$summary_file > sorted_summaries\\$summary_file
    done
    """
}