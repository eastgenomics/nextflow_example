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
    echo '$x world!'
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
    echo '$x world!'
    """
}


workflow {
  Channel.of('Bonjour', 'Ciao', 'Hello', 'Hola') | sayHello | view
}
