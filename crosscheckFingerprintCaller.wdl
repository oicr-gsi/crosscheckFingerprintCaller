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
    }

    File input_ambiguous = write_json(ambiguous)

    command <<<
        set -euo pipefail
        jq '[.[] | {pair: [.first_pair, .second_pair], upper: (.upper | tonumber), lower: (.lower | tonumber)}]' ~{input_ambiguous} > "ambiguous.json"
    >>>

    output {
        File out = "ambiguous.json"
    }
}

task writeMetadata {
    input {
        Array[Map[String, String]] metadata
    }

    File out_metadata = write_json(metadata)

    command <<<
        set -euo pipefail
        cat ~{out_metadata} > metadata.json
    >>>

    output {
        File out = "metadata.json"
    }
}

task runMain {
    input {
        Array[File] crosscheckFingerprints
        File metadata
        File ambiguous
        String seperator
        String outputFileNamePrefix
    }

    command <<<
        set -euo pipefail
        source activate cfc
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
}