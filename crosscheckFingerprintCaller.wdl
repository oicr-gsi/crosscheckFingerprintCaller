version 1.0

workflow crosscheckFingerprintCaller {
    input {
        Array[File] crosscheckFingerprints
        Array[Map[String, String]] metadata
        Array[Map[String, String]] ambiguous
        String outputFileNamePrefix
        String seperator = ";"
    }

    parameter_meta {
        crosscheckFingerprints: "CrosscheckFingerprints input files"
        metadata: "Metadata to add to the CrosscheckFingerprints data"
        ambiguous: "The ambiguous LOD ranges for each library design pair"
        seperator: "Which character is used to seperate multiple batches"
        outputFileNamePrefix: "String to add to the output file names"
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
            crosscheckFingerprints = crosscheckFingerprints,
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
            calls: "CSV file with metadata and swap calls for each library",
            detailed: "CSV file with metadata and detailed swap calls for each library pair"
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
    Object dummy = object {dummy: ambiguous}
    File input_ambiguous = write_json(dummy)

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
    Object dummy = object {dummy: metadata}
    File out_metadata = write_json(dummy)

    command <<<
        set -euo pipefail
        jq '.dummy' ~{out_metadata} > metadata.json
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
        String modules = "crosscheck-fingerprint-caller/0.2.0"
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