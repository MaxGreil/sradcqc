/* 
 * include requires tasks 
 */
include { DOWNLOAD; COMPRESS; FASTQC; MULTIQC; FASTQC_TRIM} from './sradcqc-tasks.nf'


/*
 * Create a channel for input read files
 */
if (params.singleEnd) {

} else {

}

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
