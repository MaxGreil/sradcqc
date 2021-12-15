process SRAIDs {
	
    output:
    file 'sra.txt'
	
    script:
    """
    esearch -db sra -query $params.sra_id | efetch -format runinfo | grep SRR | cut -d ',' -f 1 > sra.txt
    """
}

process PREFETCH {
    
    tag "${meta.id}"
    
    input:
    val meta
    
    output:
    tuple val(meta), path('*')
    
    script:
    """
    prefetch $meta.id
    """
    
}

process CONVERT {  

    tag "${meta.id}"

    input:
    tuple val(meta), path('*')

    output:
    tuple val(meta), file('*.fastq.gz')
    
    script:
    """
    fasterq-dump -e $task.cpus $meta.id
    """
    
}

process COMPRESS {
    publishDir params.outdir, mode:'copy'  
    
    tag "${meta.id}"
    
    input:
    tuple val(meta), val(fastq_ch)
    
    output:
    tuple val(meta), file('*.fastq.gz')
    
    script:
    """
    pigz -p $task.cpus -f $fastq_ch 
    """
}

process FASTQC {

    tag "${meta.id}"

    input:
    tuple val(meta), val(fastqgz_ch)
    
    output:
    tuple val(meta), path("fastqc_${meta.id}_logs")
    
    script:
    """
    mkdir -p fastqc_${meta.id}_logs
    fastqc -t $task.cpus -o fastqc_${meta.id}_logs $fastqgz_ch
    """

}

process MULTIQC {
    publishDir params.outdir, mode:'copy'

    input:
    tuple val(meta), path('*')

    output:
    path('multiqc_report_${meta.id}.html')

    script:
    """
    multiqc .
    """
}