To make NCBI database
 * use this [fork](https://github.com/aunderwo/ariba/commit/6eaea71697eb9887ad6f24564630813802bf162f) of Ariba code
 * run
   ```
   ariba getref ncbi out.ncbi
   ariba prepareref -f out.ncbi.fa -m out.ncbi.tsv ncbi_<DATE>
   rm out.ncbi.fas out.ncbi.tsv
   ```

To make pointfinder database 
 * clone the pointfinder db wih `git clone --depth=1 https://bitbucket.org/genomicepidemiology/pointfinder_db.git`
 * in the pointfinder_to_ariba dir run
   ```
   python3 pointfinder_to_ariba.py -p nextflow_pipelines/data_sources/ariba_amr_databases/pointfinder_db -o nextflow_pipelines/data_sources/ariba_amr_databases/pointfinder_db_temp
   mkdir pointfinder_db_2021-02-17
   mv pointfinder_db_temp/*/*_db pointfinder_db_2021-02-17
   rm -r pointfinder_db pointfinder_db_temp
   ``` 
