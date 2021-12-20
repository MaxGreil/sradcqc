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
          .set { singleSRAId }
          

      
      } else {
      
        SRAIDs()
      
        SRAIDs.out
      	  .splitText()
      	  .map { it -> ['id': it.trim()] }
      	  .set { singleSRAId }
      	
      }
      
      PREFETCH(singleSRAId)
      
      CONVERT(PREFETCH.out)
      
      TRIM(CONVERT.out, bbmap_adapters)
      
      FASTQC_TRIM(TRIM.out.trim)
      
      COMPRESS_TRIM(TRIM.out.trim)
      
      COMPRESS(CONVERT.out)
      
      FASTQC(COMPRESS.out)
      
      MULTIQC(FASTQC.out, FASTQC_TRIM.out)
      
}
