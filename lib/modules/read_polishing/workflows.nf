include './processes'
workflow polish_reads {
  take: reads

  main:
    // get read lengths
    read_lengths = determine_min_read_length(reads)
    reads_and_lengths = reads.join(read_lengths)

    // trim reads
    trimmed_reads = trim_reads(reads_and_lengths, params.adapter_file)

    // estimate genome size
    mash_output = estimate_genome_size(reads)
    genome_sizes = mash_output.map { pair_id, file -> find_genome_size(pair_id, file.text) }
    reads_and_genome_sizes = trimmed_reads.join(genome_sizes)

    // correct reads
    (corrected_reads, lighter_output) = correct_reads(reads_and_genome_sizes)

    // find  read depths
    read_depths = lighter_output.map { pair_id, file -> find_average_depth(pair_id, file.text) }

    // downsample reads
    corrected_reads_and_read_depths = corrected_reads.join(read_depths)
    downsampled_reads = downsample_reads(corrected_reads_and_read_depths, params.depth_cutoff)
  emit:
    downsampled_reads

}