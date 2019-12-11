include './messages.nf'
include './params_utilities.nf'

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
                    
    params.ariba_extra_summary_arguments = false

    params.resfinder_min_cov = false
    params.resfinder_identity_threshold = false
    params.resfinder_species = false
    params.resfinder_point_mutation = false
    params.resfinder_db_resfinder = false
    params.resfinder_db_pointfinder = false

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

    // ariba database - default is in container at /resfinder_database.17.10.2019
    if (params.ariba_database_dir){
        final_params.ariba_database_dir = file(params.ariba_database_dir)
    } else {
        final_params.ariba_database_dir = file('ariba_databases/ncbi_db_2019-10-30.1')
    }

    // ariba summary columns (default --preset cluster_all)
    if (params.ariba_extra_summary_arguments){
        final_params.ariba_extra_summary_arguments = params.ariba_extra_summary_arguments
    } else {
        final_params.ariba_extra_summary_arguments = '--preset cluster_all'
    }

    return final_params

}


