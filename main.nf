// Declare syntax
#!/usr/bin/env nextflow
nextflow.enable.dsl=2 

// Parameters
params.refGenome = refGen
params.bed = bed
params.map = map
params.segdup = segdup

process preprocessIntervals {
  input: 
    path refGenome
    path bed
  output:
    path pre_intervals
  script:
    """
    sed -i 's/^chr//' bed
    sort -k1V -k2n -k3n bed > capture_targets.bed
    echo 'Done preprocess'
    """
}

process addAnnotations {
  input:
    path map
    path segdup
  output:
    path map_bed
    path segdup_bed
  script:
    """
    sed -i 's/^chr//' map
    sort -k1V -k2n -k3n map > mappability_merged.bed
    sed -i 's/^chr//' segdup
    sort -k1V -k2n -k3n segdup > segmental_duplication.bed
    gatk IndexFeatureFile -I mappability_merged.bed
    gatk IndexFeatureFile -I segmental_duplication.bed
    """
}

process annotateIntervals {
  input: 
    path refGenome
    path pre_intervals
    path segdup
    path map
  output:
    path anno_intervals
  script:
    """
    echo 'Done annotate'
    """
}


workflow {
  // Channel.fromPath(params.map, checkIfExists:true)
  // Channel.fromPath(params.segdup, checkIfExists:true)
  preprocessIntervals | annotateIntervals
}
