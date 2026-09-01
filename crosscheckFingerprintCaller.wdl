version 1.0

import "imports/pull_crosscheckFingerprints.wdl" as crosscheckFingerprints

workflow crosscheckFingerprintCaller {
    input {
        # crosscheckFingerprint inputs
        Array[File] inputs
        Array[File]? compareAgainst
        String? cachedFilePath
        String haplotypeMapFileName
        String haplotypeMapDir = "$CROSSCHECKFINGERPRINTS_HAPLOTYPE_MAP_ROOT"
        String crosscheckBy = "SAMPLE"
        Boolean calculateTumorAwareResults = false

        # crosscheckFingerprintCaller inputs
        Array[Map[String, String]] metadata
        Array[Map[String, String]] ambiguous
        String outputFileNamePrefix
        String seperator = ";"
    }

    parameter_meta {
        inputs: "A list of SAM/BAM/VCF files to fingerprint."
        cachedFilePath: "Previous output of this workflow. If given, only new comparisons will be calculated."
        compareAgainst: "If defined, inputs are compared against these files. Ignored if cachedFilePath is defined."
        haplotypeMapFileName: "The file name that lists a set of SNPs, optionally arranged in high-LD blocks, to be used for fingerprinting."
        haplotypeMapDir: "The directory that contains haplotype map files. By default the modulator data directory."
        crosscheckBy: "Specificies which data-type should be used as the basic comparison unit. Fingerprints from readgroups can be rolled-up to the LIBRARY, SAMPLE, or FILE level before being compared. Fingerprints from VCF can be be compared by SAMPLE or FILE."
        calculateTumorAwareResults: "Specifies whether the Tumor-aware result should be calculated. These are time consuming and can roughly double the runtime of the tool. When crosschecking many groups not calculating the tumor-aware results can result in a significant speedup."

        metadata: "Metadata to add to the CrosscheckFingerprints data"
        ambiguous: "The ambiguous LOD ranges for each library design pair"
        seperator: "Which character is used to seperate multiple batches"
        outputFileNamePrefix: "String to add to the output file names"
    }

    call crosscheckFingerprints.crosscheckFingerprints {
        input:
            inputs = inputs,
            compareAgainst = compareAgainst,
            cachedFilePath = cachedFilePath,
            haplotypeMapFileName = haplotypeMapFileName,
            haplotypeMapDir = haplotypeMapDir,
            crosscheckBy = crosscheckBy,
            calculateTumorAwareResults = calculateTumorAwareResults,
            outputPrefix = outputFileNamePrefix
    }

    call writeAmbiguousRange {
        input:
            ambiguous = ambiguous
    }

    call writeMetadata {
        input:
            metadata = metadata
    }

    call runMain {
        input:
            crosscheckFingerprints = [crosscheckFingerprints.crosscheckMetrics],
            metadata = writeMetadata.out,
            ambiguous = writeAmbiguousRange.out,
            seperator = seperator,
            outputFileNamePrefix = outputFileNamePrefix,
    }

    output {
        File calls = runMain.calls
        File detailed = runMain.detailed
    }

    meta {
        author: "Savo Lazic"
        email: "slazic@oicr.on.ca"
        description: "To call sequencing library swaps and matches from CrosscheckFingerprints output given OICR metadata."
        dependencies: [
            {
                name: "crosscheck_fingerprint_caller",
                url: "https://github.com/oicr-gsi/crosscheck_fingerprint_caller"
            },
            {
                name: "jq",
                url: "https://jqlang.github.io/jq/"
            }
        ]
        output_meta: {
            calls: {
                description: "CSV file with metadata and swap calls for each library",
                vidarr_label: "calls"
            },
            detailed: {
                description: "CSV file with metadata and detailed swap calls for each library pair",
                vidarr_label: "detailed"
            }
        }
    }
}

task writeAmbiguousRange {
    input {
        Array[Map[String, String]] ambiguous
        Int timeout = 1
        Int memory = 1
        Int threads = 1
        String modules = "jq/1.6"
    }

    # Necessary as Cromwell 44 has bug that prevents Array being used in write_json. Fixed in Cromwell 54
    File input_ambiguous = write_json(object {dummy: ambiguous})

    command <<<
        set -euo pipefail
        jq '[.dummy[] | {pair: [.first_pair, .second_pair], upper: (.upper | tonumber), lower: (.lower | tonumber)}]' ~{input_ambiguous} > "ambiguous.json"
    >>>

    output {
        File out = "ambiguous.json"
    }

    parameter_meta {
        ambiguous: "The ambiguous LOD ranges for each library design pair"
        timeout: "The hours until the task is killed."
        memory: "The GB of memory provided to the task."
        threads: "The number of threads the task has access to."
        modules: "The modules that will be loaded."
    }

    meta {
        out_metadata: {
            out: "A file that's storing the ambiguous JSON string"
        }
    }

    runtime {
        modules: "~{modules}"
        memory:  "~{memory} GB"
        cpu:     "~{threads}"
        timeout: "~{timeout}"
    }
}

task writeMetadata {
    input {
        Array[Map[String, String]] metadata
        Int timeout = 1
        Int memory = 1
        Int threads = 1
        String modules = "jq/1.6"
    }

    # Necessary as Cromwell 44 has bug that prevents Array being used in write_json. Fixed in Cromwell 54
    File out_metadata = write_json(object {dummy: metadata})

    command <<<
        set -euo pipefail
        # -S sorts the keys. different ordering created issue in different environment, see ticket: GP-5853 
        jq -S '.dummy' ~{out_metadata} > metadata.json
    >>>

    output {
        File out = "metadata.json"
    }

    parameter_meta {
        metadata: "Metadata to add to the CrosscheckFingerprints data"
        timeout: "The hours until the task is killed."
        memory: "The GB of memory provided to the task."
        threads: "The number of threads the task has access to."
        modules: "The modules that will be loaded."
    }

    meta {
        out_metadata: {
            out: "A file that's storing the metadata JSON string"
        }
    }

    runtime {
        modules: "~{modules}"
        memory:  "~{memory} GB"
        cpu:     "~{threads}"
        timeout: "~{timeout}"
    }
}

task runMain {
    input {
        Array[File] crosscheckFingerprints
        File metadata
        File ambiguous
        String seperator
        String outputFileNamePrefix
        Int timeout = 1
        Int memory = 1
        Int threads = 1
        String modules = "crosscheck-fingerprint-caller/1.0.0"
    }

    command <<<
        set -euo pipefail
        crosscheck-fingerprint-caller \
            --ambiguous-lod ~{ambiguous} \
            --seperator '~{seperator}' \
            --output-calls ~{outputFileNamePrefix}.calls.csv \
            --output-detailed ~{outputFileNamePrefix}.detailed.csv \
            ~{metadata} \
            ~{sep=" " crosscheckFingerprints}
    >>>

    output {
        File calls = "~{outputFileNamePrefix}.calls.csv"
        File detailed = "~{outputFileNamePrefix}.detailed.csv"
    }

    parameter_meta {
        crosscheckFingerprints: "CrosscheckFingerprints input files"
        metadata: "Metadata to add to the CrosscheckFingerprints data"
        ambiguous: "The ambiguous LOD ranges for each library design pair"
        seperator: "Which character is used to seperate multiple batches"
        outputFileNamePrefix: "String to add to the output file names"
        timeout: "The hours until the task is killed."
        memory: "The GB of memory provided to the task."
        threads: "The number of threads the task has access to."
        modules: "The modules that will be loaded."
    }

    meta {
        out_metadata: {
            calls: "CSV file with metadata and swap calls for each library",
            detailed: "CSV file with metadata and detailed swap calls for each library pair"
        }
    }

    runtime {
        modules: "~{modules}"
        memory:  "~{memory} GB"
        cpu:     "~{threads}"
        timeout: "~{timeout}"
    }
}