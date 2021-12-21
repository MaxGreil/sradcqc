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
    tuple val(meta), file(bbmap_adapters)
    
    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*'), emit: sra
    
    script:
    """
    prefetch $meta.id
    """
    
}

process CONVERT {  

    tag "${meta.id}"

    input:
    tuple val(meta), file(bbmap_adapters)
    path('*')

    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*.fastq'), emit: fastq
    
    script:
    """
    fasterq-dump -e $task.cpus $meta.id
    """
    
}

process COMPRESS {
    publishDir "${params.outdir}/${meta.id}", pattern:'*.fastq.gz', mode:'copy'  
    
    tag "${meta.id}"
    
    input:
    tuple val(meta), file(bbmap_adapters)
    file(fastq_ch)
    
    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*.fastq.gz'), emit: fastqcgz
    
    script:
    """
    pigz -p $task.cpus -f $fastq_ch 
    """
}

process COMPRESS_TRIM {
    publishDir "${params.outdir}/${meta.id}", pattern:'*.fastq.gz', mode:'copy'  
    
    tag "${meta.id}"
    
    input:
    tuple val(meta), file(bbmap_adapters)
    file(fastq_trim_ch)
    
    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*.fastq.gz'), emit: fastqcgz
    
    script:
    """
    pigz -p $task.cpus -f $fastq_trim_ch 
    """
}

process TRIM {
   publishDir "${params.outdir}/${meta.id}", pattern: '*.txt', mode: 'copy'

   tag "${meta.id}"
   
   input:
   tuple val(meta), file(bbmap_adapters)
   file(fastq_ch)
   
   output:
   tuple val(meta), file(bbmap_adapters), emit: meta
   path('*.trim.fastq'), emit: trim
   path('*.txt'), emit: txt
   
   script:
   if(fastq_ch.size() == 1) {
     """
     bbduk.sh t=${task.cpus} \
              in=${meta.id}.fastq \
              out=${meta.id}.trim.fastq \
              ref=${bbmap_adapters} \
              ktrim=r qtrim=10 k=23 mink=11 hdist=1 \
              maq=10 minlen=25 \
              tpe tbo \
              literal=AAAAAAAAAAAAAAAAAAAAAAA \
              stats=${meta.id}.trimstats.txt \
              refstats=${meta.id}.refstats.txt \
              ehist=${meta.id}.ehist.txt
     """

   } else {
     """
     bbduk.sh t=${task.cpus} \
              in=${meta.id}_1.fastq \
              in2=${meta.id}_2.fastq \
              out=${meta.id}_1.trim.fastq \
              out2=${meta.id}_2.trim.fastq \
              ref=${bbmap_adapters}  \
              ktrim=r qtrim=10 k=23 mink=11 hdist=1 \
              maq=10 minlen=25 \
              tpe tbo \
              literal=AAAAAAAAAAAAAAAAAAAAAAA \
              stats=${meta.id}.trimstats.txt \
              refstats=${meta.id}.refstats.txt \
              ehist=${meta.id}.ehist.txt
     """
   }
}

process FASTQC {

    tag "${meta.id}"

    input:
    tuple val(meta), file(bbmap_adapters)
    file(fastqgz_ch)
    
    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*_fastqc.{zip,html}'), emit: fastqc
    
    script:
    """
    fastqc -t $task.cpus $fastqgz_ch
    """

}

process FASTQC_TRIM {

    tag "${meta.id}"

    input:
    tuple val(meta), file(bbmap_adapters)
    file(fastq_trim_ch)
    
    output:
    tuple val(meta), file(bbmap_adapters), emit: meta
    path('*_fastqc.{zip,html}'), emit: fastqc_trim
    
    script:
    """
    fastqc -t $task.cpus $fastq_trim_ch
    """

}

process MULTIQC {
    publishDir "${params.outdir}/${meta.id}", mode:'copy'

    tag "${meta.id}"

    input:
    tuple val(meta), file(bbmap_adapters)
    file(fastqc)
    file(fastqc_trim)

    output:
    path('multiqc_report.html')

    script:
    """
    multiqc .
    """
}

