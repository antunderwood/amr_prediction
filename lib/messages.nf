def version_message(String version) {
    println(
        """
        ==============================================
        Resfinder Pipeline version ${version}
        ==============================================
        """.stripIndent()
    )
}

def help_message() {
    println(
        """
        Mandatory arguments:
        --input_dir                 Path to input dir. This must be used in conjunction with fastq_pattern
        --fastq_pattern             The regular expression that will match fastq files e.g '*_{1,2}.fastq.gz'
        --output_dir                Path to output dir

        Optional ariba arguments:
        --ariba_database_dir   Path to a local dir containing ariba resitance database (default is ariba_databases/ncbi_db_2019-10-30.1)
        --ariba_summary_arguments Supply the non-default options for the ariba summary command.
            Wrap these in quotes e.g '--preset minimal --min_id 95'
            (default is '--cluster_cols assembled,match,ref_seq,pct_id,ctg_cov')
        --species If point-based mutations are required specify a species. This must be one of
                    campylobacter
                    enterococcus_faecalis
                    enterococcus_faecium
                    escherichia_coli
                    helicobacter_pylori
                    klebsiella
                    mycobacterium_tuberculosis
                    neisseria_gonorrhoeae
                    salmonella
                    staphylococcus_aureus
        """
    )
}

def complete_message(Map params, nextflow.script.WorkflowMetadata workflow, String version){
    // Display complete message
    println ""
    println "Ran the workflow: ${workflow.scriptName} ${version}"
    println "Command line    : ${workflow.commandLine}"
    println "Completed at    : ${workflow.complete}"
    println "Duration        : ${workflow.duration}"
    println "Success         : ${workflow.success}"
    println "Work directory  : ${workflow.workDir}"
    println "Exit status     : ${workflow.exitStatus}"
    println ""
    println "Parameters"
    println "=========="
    params.each{ k, v ->
        if (v){
            println "${k}: ${v}"
        }
    }
}

def error_message(nextflow.script.WorkflowMetadata workflow){
    // Display error message
    println ""
    println "Workflow execution stopped with the following message:"
    println "  " + workflow.errorMessage

}