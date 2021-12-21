/* 
 * include requires tasks 
 */
include { SRAIDs; PREFETCH; CONVERT; COMPRESS; FASTQC; MULTIQC; TRIM; FASTQC_TRIM; COMPRESS_TRIM} from './sradcqc-tasks.nf'

/* 
 * define the data analysis workflow 
 */
workflow sradcqcFlow {
    // required inputs
    take:
      sra_id
      input
    // workflow implementation
    main:
      
      if ( params.bbmap_adapters ){
      
         Channel.fromPath("${params.bbmap_adapters}")
           .set{ bbmap_adapters }
      }
      
      if(input) {
      
        Channel.fromPath(params.input, checkIfExists: true)
          .splitCsv(header: true, sep: '\t', strip: true)
          .map ({ row -> ['id': row.run_accession] })
          .combine(bbmap_adapters)
          .groupTuple()
          .set { singleSRAId }
      
      } else {
      
        SRAIDs()
      
        SRAIDs.out
      	  .splitText()
      	  .map { it -> ['id': it.trim()] }
      	  .combine(bbmap_adapters)
          .groupTuple()
      	  .set { singleSRAId }
      	
      }
      
      PREFETCH(singleSRAId)
      
      CONVERT(PREFETCH.out.meta, PREFETCH.out.sra)
      
      TRIM(CONVERT.out.meta, CONVERT.out.fastq)
      
      FASTQC_TRIM(TRIM.out.meta, TRIM.out.trim)
      
      COMPRESS_TRIM(TRIM.out.meta, TRIM.out.trim)
      
      COMPRESS(CONVERT.out.meta, CONVERT.out.fastq)
      
      FASTQC(COMPRESS.out.meta, COMPRESS.out.fastqcgz)
      
      MULTIQC(FASTQC.out.meta, FASTQC.out.fastqc, FASTQC_TRIM.out.fastqc_trim)
      
}
