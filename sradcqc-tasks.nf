params.outdir = "data"

process DOWNLOAD {  

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
    pigz -f $fastq_ch 
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
    fastqc -o fastqc_${params.sra_id}_logs $fastqgz_ch
    """

}

process MULTIQC {
    publishDir params.outdir, mode:'copy'

    input:
    path('*')

    output:
    path('multiqc_report.html')

    script:
    """
    multiqc .
    """
}

