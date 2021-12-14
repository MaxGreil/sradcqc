/* 
 * include requires tasks 
 */
include { INFO; PREFETCH; CONVERT; COMPRESS; FASTQC; MULTIQC; } from './modules/sradcqc-tasks.nf'


/* 
 * define the data analysis workflow 
 */
workflow sradcqcFlow {
    // required inputs
    take:
      sra_id
    // workflow implementation
    main:
      INFO()
      INFO.out.view()
      PREFETCH()
      CONVERT(PREFETCH.out)
      COMPRESS(CONVERT.out)
      FASTQC(CONVERT.out)
      MULTIQC(FASTQC.out)
      //missing: adapter removing and quality trim using BBDUK
}
