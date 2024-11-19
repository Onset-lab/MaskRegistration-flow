#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PIPELINE_INITIALISATION } from './subworkflows/local/pipeline_initialisation/main.nf'
include { REGISTER_MASK } from './subworkflows/local/register_mask/main.nf'

//
// WORKFLOW: Run main pipeline
//
workflow REGISTER_AFFINE_MASK {

    take:
    masks              // channel: [ val(meta), [ images ] ]
    reference           // channel: [ val(meta), [ image ] ]
    affine              // channel: [ val(meta), [ affine ] ]

    main:

    //
    // WORKFLOW: Run brain extraction
    //
    REGISTER_MASK (
        masks,
        reference,
        affine,
    )

    emit:
    masks_warped = REGISTER_MASK.out.masks_warped // channel: [ val(meta), [ image ] ]
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.input,
        params.output_dir,
    )

    // //
    // // WORKFLOW: Run main workflow
    // //
    REGISTER_AFFINE_MASK (
        PIPELINE_INITIALISATION.out.masks,
        PIPELINE_INITIALISATION.out.reference,
        PIPELINE_INITIALISATION.out.affine,
    )
}
