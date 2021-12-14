#!/usr/bin/env nextflow

/*
 * enables modules
 */
nextflow.enable.dsl=2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */
params.sra_id = "" //SRR000001
params.outdir = "output"

log.info """\
         S R A  T O  F A S T Q  -  C O M P R E S S  A N D  Q U A L I T Y  C O N T R O L  -  P I P E L I N E
         ===================================
         sra_id:     ${params.sra_id}
         outdir:     ${params.outdir}
         tracedir:   ${params.tracedir}
         """
         .stripIndent()

include { sradcqcFlow } from './sradcqc-flow.nf'

if (!params.sra_id) {
   exit 1, "\nPlease give in SRA identifier to download via --sra_id <SRA identifier> \n"
}

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

    log.info ( workflow.success ? "\nDone! Open the following reports in your browser --> $params.outdir/multiqc_report_${params.sra_id}.html and $params.tracedir/execution_report.html\n" : "Oops .. something went wrong" )

}
