## Workflow to process samples through AMR pipelines
### Usage
```
===================================================
    AMR prediction Pipeline version 1.0
===================================================


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
```

This pipeline will run ARIBA on two AMR prediction databases in parallel
### NCBI
Samples will be processed using a NCBI database of acquired AMR genes

### pointfinder_db
Samples will be processed using the resfinder4 software and the predicted antimicrobial sensitivities found in the files `full_summary.tsv` and `species_specific_summary.tsv` in a sub-directory named resfinder within the output directory set using `--output_dir`

---

### Running test data
The test dataset can be run using this command
```
 NXF_VER=19.11.0-edge nextflow run main.nf --input_dir $PWD/test_input --fastq_pattern '*{R,_}{1,2}.fastq.gz' --output_dir $PWD/test_output  --depth_cutoff 100  --species staphylococcus_aureus -resume
```
