process INFO {

    output:
    stdout
    
    script:
    """
    vdb-dump --info $params.sra_id
    """

}

process PREFETCH {
    
    output:
    path('*')
    
    script:
    """
    prefetch $params.sra_id
    """
    
}

process CONVERT {  

    input:
    path('*')

    output:
    file '*.fastq'
    
    script:
    """
    fasterq-dump -e $task.cpus $params.sra_id
    """
    
}

process COMPRESS {
    publishDir params.outdir, mode:'copy'  
    
    input:
    file fastq_ch
    
    output:
    file '*.fastq.gz'
    
    script:
    """
    pigz -p $task.cpus -f $fastq_ch 
    """
}

process FASTQC {

    input:
    file fastqgz_ch
    
    output:
    path("fastqc_${params.sra_id}_logs")
    
    script:
    """
    mkdir -p fastqc_${params.sra_id}_logs
    fastqc -t $task.cpus -o fastqc_${params.sra_id}_logs $fastqgz_ch
    """

}

process MULTIQC {
    publishDir params.outdir, mode:'copy'

    input:
    path('*')

    output:
    path('multiqc_report_${params.sra_id}.html')

    script:
    """
    multiqc .
    """
}
