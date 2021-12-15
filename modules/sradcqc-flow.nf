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
    // workflow implementation
    main:
      SRAIDs()
      
      SRAIDs.out
      	.splitText()
      	.map { it -> ['id': it.trim()] }
      	.set { singleSRAId }
      	
      PREFETCH(singleSRAId)
      
      CONVERT(PREFETCH.out)
      
      COMPRESS(CONVERT.out)
      
      FASTQC(COMPRESS.out)
      
      MULTIQC(FASTQC.out)
      
      //missing: adapter removing and quality trim using BBDUK
}
