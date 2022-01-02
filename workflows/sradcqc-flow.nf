/* 
 * include requires tasks 
 */
include { SRAIDs; PREFETCH; CONVERT; COMPRESS; FASTQC; MULTIQC; TRIM; FASTQC_TRIM; COMPRESS_TRIM } from '../modules/sradcqc-tasks.nf'

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
      
      if ( params.bbmap_adapters ) {
      
         Channel.fromPath( params.bbmap_adapters )
           .ifEmpty { exit 1, "bbmap_adapters was empty - no input file supplied" }
           .set{ bbmap_adapters }
      }
      
      if( input ) {
      
        Channel.fromPath( params.input, checkIfExists: true )
          .splitCsv(header: true, sep: '\t', strip: true)
          .map { row -> ['id': row.run_accession] }
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
      
      TRIM(bbmap_adapters.first(), CONVERT.out)  //value channel, queue channel -> process termination determined by content of queue channel
      
      COMPRESS_TRIM(TRIM.out.trim)
      
      FASTQC_TRIM(COMPRESS_TRIM.out)
      
      COMPRESS(CONVERT.out)
      
      FASTQC(COMPRESS.out)
      
      MULTIQC(FASTQC.out.collect(), FASTQC_TRIM.out.collect())
      
}
