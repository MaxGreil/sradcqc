/* 
 * include requires tasks 
 */
include { SRAIDs; PREFETCH; CONVERT; COMPRESS; FASTQC; MULTIQC; } from './sradcqc-tasks.nf'

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
      
      COMPRESS(CONVERT.out)
      
      FASTQC(COMPRESS.out)
      
      MULTIQC(FASTQC.out)
      
      //missing: adapter removing and quality trim using BBDUK
}
