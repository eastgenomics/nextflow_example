// Declare syntax
#!/usr/bin/env nextflow
nextflow.enable.dsl=2 

// Parameters
params.refGenome
params.bed
params.map
params.segdup


process preprocessIntervals {
  input: 
    path ${params.refGenome}
    path ${params.bed}
  output:
    path 'preprocessed.interval_list'
  script:
    """
    sed -i 's/^chr//' bed
    sort -k1V -k2n -k3n bed > capture_targets.bed
    echo 'gatk PreprocessIntervals -R ${params.refGenome} -L capture_targets.bed \
    -imr OVERLAPPING_ONLY --bin-length $bin_length --padding $padding \
    -O preprocessed.interval_list'
    """
}

process addSegdup {
  input:
    path ${params.segdup}
  output:
    path 'segmental_duplication.bed'
  when:
    segdup exists
  script:
    """
    sed -i 's/^chr//' segdup
    sort -k1V -k2n -k3n segdup > segmental_duplication.bed
    echo 'gatk IndexFeatureFile -I segmental_duplication.bed'
    """
}

process addMap {
  input:
    path ${params.map}
  output:
    path 'mappability_merged.bed'
  when:
    map exists
  script:
    """
    sed -i 's/^chr//' map
    sort -k1V -k2n -k3n map > mappability_merged.bed
    gatk IndexFeatureFile -I mappability_merged.bed
    """

process annotateIntervals {
  input: 
    path ${params.refGenome}
    path 'preprocessed.interval_list'
    path 'segmental_duplication.bed'
    path 'mappability_merged.bed'
  output:
    path 'annotated_intervals.tsv'
  script:
    """
    echo 'gatk AnnotateIntervals -R ${params.refGenome} -L preprocessed.interval_list \
    -imr OVERLAPPING_ONLY --mappability-track mappability_merged.bed \
    --segmental-duplication-track segmental_duplication.bed \
    -O annotated_intervals.tsv'
    """
}


workflow {
  preprocessIntervals | annotateIntervals
}
