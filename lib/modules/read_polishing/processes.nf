// Assess read length and make MIN LEN for trimmomatic 1/3 of this value
process determine_min_read_length {
  container 'bioinformant/ghru-read-polishing:1.0'
  tag { pair_id }

  input:
  tuple pair_id, file(file_pair)

  output:
  tuple pair_id, stdout

  script:
  """
  gzip -cd ${file_pair[0]} | head -n 400000 | printf "%.0f" \$(awk 'NR%4==2{sum+=length(\$0)}END{print sum/(NR/4)}')
  """
}

// Trimming
process trim_reads {
  container 'bioinformant/ghru-read-polishing:1.0'
  memory '4 GB'
  
  tag { pair_id }
  
  input:
  tuple pair_id, file(file_pair), min_read_length
  file('adapter_file.fas')

  output:
  tuple pair_id, file('trimmed_fastqs/*.f*q.gz')

  script:
  shortest_read_length_to_keep = min_read_length.toInteger()/3
  """
  mkdir trimmed_fastqs
  trimmomatic PE -threads 1 -phred33 ${file_pair[0]} ${file_pair[1]} trimmed_fastqs/${file_pair[0]} /dev/null trimmed_fastqs/${file_pair[1]} /dev/null ILLUMINACLIP:adapter_file.fas:2:30:10 SLIDINGWINDOW:4:20 LEADING:25 TRAILING:25 MINLEN:${shortest_read_length_to_keep}  
  """
}

process estimate_genome_size {
  container 'bioinformant/ghru-read-polishing:1.0'
  tag { pair_id }
  
  input:
  tuple pair_id, file(file_pair)

  output:
  tuple pair_id, file('mash_stats.out')

  """
  kat hist --mer_len 21  --thread 1 --output_prefix ${pair_id} ${file_pair[0]} > /dev/null 2>&1 \
  && minima=`cat  ${pair_id}.dist_analysis.json | jq '.global_minima .freq' | tr -d '\\n'`
  mash sketch -o sketch_${pair_id}  -k 32 -m \$minima -r ${file_pair[0]}  2> mash_stats.out
  """
}

def find_genome_size(pair_id, mash_output) {
  m = mash_output =~ /Estimated genome size: (.+)/
  genome_size = Float.parseFloat(m[0][1]).toInteger()
  return [pair_id, genome_size]
}


// Read Corection
process correct_reads {
  container 'bioinformant/ghru-read-polishing:1.0'
  tag { pair_id }
  
  input:
  tuple pair_id, file(file_pair), genome_size

  output:
  tuple pair_id, file('corrected_fastqs/*.fastq.gz')
  tuple pair_id, file('lighter.out') 

  script:
  """
  lighter -od corrected_fastqs -r  ${file_pair[0]} -r  ${file_pair[1]} -K 32 ${genome_size}  -maxcor 1 2> lighter.out
  for file in corrected_fastqs/*.cor.fq.gz
  do
      new_file=\${file%.cor.fq.gz}.fastq.gz
      mv \${file} \${new_file}
  done
  """
}

def find_average_depth(pair_id, lighter_output){
  m = lighter_output =~  /.+Average coverage is ([0-9]+\.[0-9]+)\s.+/
  average_depth = Float.parseFloat(m[0][1])
  return [pair_id, average_depth]
}

process downsample_reads {
  container 'bioinformant/ghru-read-polishing:1.0'
  tag { pair_id }

  input:
  tuple pair_id, file(file_pair), read_depth
  val depth_cutoff

  output:
  tuple pair_id, file("output_fastqs/*.fastq.gz")

  script:
  if ( depth_cutoff && read_depth > depth_cutoff.toInteger()){
    downsampling_factor = depth_cutoff.toInteger()/read_depth
    """
    mkdir output_fastqs
    seqtk sample -s 12345 ${file_pair[0]} ${downsampling_factor} | gzip > output_fastqs/${pair_id}_1.fastq.gz
    seqtk sample -s 12345 ${file_pair[1]} ${downsampling_factor} | gzip > output_fastqs/${pair_id}_2.fastq.gz
    """

  } else {
    // do nothing
    """
    mkdir output_fastqs
    ln -s \$(readlink -f ${file_pair[0]}) output_fastqs/${pair_id}_1.fastq.gz
    ln -s \$(readlink -f ${file_pair[1]}) output_fastqs/${pair_id}_2.fastq.gz
    """
  }
}