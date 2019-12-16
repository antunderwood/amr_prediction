include './messages'
include './params_utilities'

def default_params(){
    /***************** Setup inputs and channels ************************/
    def params = [:]
    params.help = false
    params.version = false

    params.nextflow_modules_path = false

    params.input_dir = false
    params.fastq_pattern = false
    params.output_dir = false

    params.read_polishing_adapter_file = false
    params.read_polishing_depth_cutoff = false

    params.ariba_database_dir = false
    params.ariba_get_database = false
                    
    params.ariba_summary_arguments = false

    params.species = false
    return params
}

def check_params(Map params, String version) { 
    // set up input directory
    def final_params = [:]
    // final_params.nextflow_modules_path = check_mandatory_parameter(params, 'nextflow_modules_path')  - ~/\/$/
    def input_dir = check_mandatory_parameter(params, 'input_dir') - ~/\/$/

    //  check a pattern has been specified
    def fastq_pattern = check_mandatory_parameter(params, 'fastq_pattern')

    //
    final_params.reads_path = input_dir + "/" + fastq_pattern

    // set up output directory
    final_params.output_dir = check_mandatory_parameter(params, 'output_dir') - ~/\/$/

    // ---------------- Read polishing Params ------------------- //
    if (params.read_polishing_adapter_file){
        final_params.read_polishing_adapter_file = file(params.read_polishing_adapter_file)
    } else {
        final_params.read_polishing_adapter_file = file('adapters.fas')
    }

    if (params.read_polishing_depth_cutoff){
        final_params.read_polishing_depth_cutoff = params.read_polishing_depth_cutoff
    } else {
        final_params.read_polishing_depth_cutoff = false
    }

    // ---------------- Ariba Params --------------------- //

    // ariba database - default at ariba_databases/ncbi_db_2019-10-30.1
    if (params.ariba_database_dir){
        final_params.ariba_database_dir = file(params.ariba_database_dir)
    } else {
        final_params.ariba_database_dir = file("${workflow.projectDir}/ariba_databases/ncbi_db_2019-10-30.1")
    }

    // ariba summary columns (default --preset cluster_all)
    if (params.ariba_summary_arguments){
        final_params.ariba_summary_arguments = params.ariba_summary_arguments
    } else {
        final_params.ariba_summary_arguments = '--cluster_cols assembled,match,ref_seq,pct_id,ctg_cov --col_filter n'
    }
    //species for pointfinder databases
    if (params.species){
        valid_species = ['campylobacter', 'enterococcus_faecalis', 'enterococcus_faecium', 'escherichia_coli', 'helicobacter_pylori', 'klebsiella', 'mycobacterium_tuberculosis', 'neisseria_gonorrhoeae', 'salmonella', 'staphylococcus_aureus']
        final_params.species = check_parameter_value('species', params.species, valid_species)
    }

    return final_params

}


