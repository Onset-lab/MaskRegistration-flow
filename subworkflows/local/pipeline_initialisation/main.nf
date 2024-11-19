
def logoHeader(){
    // Log colors ANSI codes
    c_reset = "\033[0m";
    c_dim = "\033[2m";
    c_blue = "\033[0;34m";

    return """
    ${c_dim}-----------------------------------${c_reset}
    ${c_blue}    ___  _   _ ____  _____ _____   ${c_reset}
    ${c_blue}   / _ \\| \\ | / ___|| ____|_   _|  ${c_reset}
    ${c_blue}  | | | |  \\| \\___ \\|  _|   | |    ${c_reset}
    ${c_blue}  | |_| | |\\  |___) | |___  | |    ${c_reset}
    ${c_blue}   \\___/|_| \\_|____/|_____| |_|    ${c_reset}

    ${c_dim}------------------------------------${c_reset}
    """.stripIndent()
}

log.info logoHeader()

log.info "\033[0;33m ${workflow.manifest.name} \033[0m"
log.info "  ${workflow.manifest.description}"
log.info "  Version: ${workflow.manifest.version}"
log.info "  Github: ${workflow.manifest.homePage}"
log.info " "

workflow.onComplete {
    log.info " "
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
}

workflow PIPELINE_INITIALISATION {

    take:
    input           // path
    outdir          // path

    main:

    ch_versions = Channel.empty()

    if (params.help) {
        usage = file("$baseDir/USAGE")
        engine = new groovy.text.SimpleTemplateEngine()
        template = engine.createTemplate(usage.text).make()
        print template.toString()
        exit 0
    }

    masks_channel = Channel.fromPath("$input/**/masks/*.nii.gz")
                    .map{ch1 ->
                        def fmeta = [:]
                        // Set meta.id
                        fmeta.id = ch1.parent.parent.name
                        [fmeta, ch1]
                        }

    reference_channel = Channel.fromPath("$input/**/*reference.nii.gz")
                    .map{ch1 ->
                        def fmeta = [:]
                        // Set meta.id
                        fmeta.id = ch1.parent.name
                        [fmeta, ch1]
                        }

    affine_channel = Channel.fromPath("$input/**/*.mat")
                    .map{ch1 ->
                        def fmeta = [:]
                        // Set meta.id
                        fmeta.id = ch1.parent.name
                        [fmeta, ch1]
                        }

    log.info "\033[0;33m Parameters \033[0m"
    log.info " Input: ${input}"
    log.info " Output directory: ${outdir}"

    emit:
    masks = masks_channel              // channel: [ val(meta), [ image ] ]
    reference = reference_channel  // channel: [ val(meta), [ image ] ]
    affine = affine_channel        // channel: [ val(meta), [ affine ] ]
    versions = ch_versions          // channel: [ versions.yml ]
}
