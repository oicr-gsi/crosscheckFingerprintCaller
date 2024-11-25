# crosscheckFingerprintCaller

To call sequencing library swaps and matches from CrosscheckFingerprints output given OICR metadata.

## Overview

## Dependencies

* [crosscheck_fingerprint_caller](https://github.com/oicr-gsi/crosscheck_fingerprint_caller)
* [jq](https://jqlang.github.io/jq/)


## Usage

### Cromwell
```
java -jar cromwell.jar run crosscheckFingerprintCaller.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`crosscheckFingerprints`|Array[File]|CrosscheckFingerprints input files
`metadata`|Array[Map[String,String]]|Metadata to add to the CrosscheckFingerprints data
`ambiguous`|Array[Map[String,String]]|The ambiguous LOD ranges for each library design pair
`outputFileNamePrefix`|String|String to add to the output file names


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`seperator`|String|";"|Which character is used to seperate multiple batches


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`writeAmbiguousRange.timeout`|Int|1|The hours until the task is killed.
`writeAmbiguousRange.memory`|Int|1|The GB of memory provided to the task.
`writeAmbiguousRange.threads`|Int|1|The number of threads the task has access to.
`writeAmbiguousRange.modules`|String|"jq/1.6"|The modules that will be loaded.
`writeMetadata.timeout`|Int|1|The hours until the task is killed.
`writeMetadata.memory`|Int|1|The GB of memory provided to the task.
`writeMetadata.threads`|Int|1|The number of threads the task has access to.
`writeMetadata.modules`|String|"jq/1.6"|The modules that will be loaded.
`runMain.timeout`|Int|1|The hours until the task is killed.
`runMain.memory`|Int|1|The GB of memory provided to the task.
`runMain.threads`|Int|1|The number of threads the task has access to.
`runMain.modules`|String|"crosscheck-fingerprint-caller/0.2.0"|The modules that will be loaded.


### Outputs

Output | Type | Description | Labels
---|---|---|---
`calls`|File|CSV file with metadata and swap calls for each library|vidarr_label: calls
`detailed`|File|CSV file with metadata and detailed swap calls for each library pair|vidarr_label: detailed


## Commands
 See WDL
 
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
