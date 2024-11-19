include { REGISTRATION_ANTSAPPLYTRANSFORMS } from '../../../modules/nf-neuro/registration/antsapplytransforms/main'

workflow REGISTER_MASK {

    take:
    ch_masks  // channel: [ val(meta), [ bam ] ]
    ch_ref    // channel: [ val(meta), [ ref ] ]
    ch_affine // channel: [ val(meta), [ affine ] ]

    main:

    ch_versions = Channel.empty()

    REGISTRATION_ANTSAPPLYTRANSFORMS ( 
        ch_masks.combine(ch_ref.first(), by: 0).combine(ch_affine.first(), by: 0),
    )
    ch_versions = ch_versions.mix(REGISTRATION_ANTSAPPLYTRANSFORMS.out.versions.first())

    emit:
    masks_warped = REGISTRATION_ANTSAPPLYTRANSFORMS.out.warped_image // channel: [ val(meta), [ mask ] ]

    versions = ch_versions                                          // channel: [ versions.yml ]
}

