/* 
 * enables modules 
 */
nextflow.enable.dsl=2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */

params.sra_id = "" //SRR000001
params.outdir = "data"

log.info """\
         S R A  T O  F A S T Q  -  C O M P R E S S  A N D  Q U A L I T Y  C O N T R O L  -  P I P E L I N E    
         ===================================
         sra_id: ${params.sra_id}
         outdir: ${params.outdir}
         """
         .stripIndent()
         
include { sradcqcFlow } from './sradcqc-flow.nf'
         
/* 
 * main script flow
 */
workflow {
    
    sradcqcFlow( params.sra_id )

}

/* 
 * completion handler
 */
workflow.onComplete {

    if( params.sra_id ) {
    	log.info (workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
    } else {
        log.info ("\nPlease give in SRA identifier to download via --sra_id <SRA identifier> \n" )
    }
    
}
