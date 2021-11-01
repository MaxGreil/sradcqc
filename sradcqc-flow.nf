/* 
 * include requires tasks 
 */
include { DOWNLOAD; COMPRESS; FASTQC; MULTIQC  } from './sradcqc-tasks.nf'
 
/* 
 * define the data analysis workflow 
 */
workflow sradcqcFlow {
    // required inputs
    take:
      sra_id
    // workflow implementation
    main:
      if (sra_id) { 
        DOWNLOAD()
        COMPRESS(DOWNLOAD.out)
        FASTQC(COMPRESS.out)
        MULTIQC(FASTQC.out)
      } 
}
