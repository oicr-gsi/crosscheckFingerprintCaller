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
`inputs`|Array[File]|A list of SAM/BAM/VCF files to fingerprint.
`haplotypeMapFileName`|String|The file name that lists a set of SNPs, optionally arranged in high-LD blocks, to be used for fingerprinting.
`metadata`|Array[Map[String,String]]|Metadata to add to the CrosscheckFingerprints data
`ambiguous`|Array[Map[String,String]]|The ambiguous LOD ranges for each library design pair
`outputFileNamePrefix`|String|String to add to the output file names


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`compareAgainst`|Array[String]?|None|If defined, inputs are compared against these files. Ignored if cachedFilePath is defined.
`cachedFilePath`|String?|None|Previous output of this workflow. If given, only new comparisons will be calculated.
`haplotypeMapDir`|String|"$CROSSCHECKFINGERPRINTS_HAPLOTYPE_MAP_ROOT"|The directory that contains haplotype map files. By default the modulator data directory.
`crosscheckBy`|String|"SAMPLE"|Specificies which data-type should be used as the basic comparison unit. Fingerprints from readgroups can be rolled-up to the LIBRARY, SAMPLE, or FILE level before being compared. Fingerprints from VCF can be be compared by SAMPLE or FILE.
`calculateTumorAwareResults`|Boolean|false|Specifies whether the Tumor-aware result should be calculated. These are time consuming and can roughly double the runtime of the tool. When crosschecking many groups not calculating the tumor-aware results can result in a significant speedup.
`seperator`|String|";"|Which character is used to seperate multiple batches


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`crosscheckFingerprints.createNewCrosscheckFingerprints_timeout`|Int|1|Number of hours before task timeout.
`crosscheckFingerprints.createNewCrosscheckFingerprints_jobMemory`|Int|1|Memory (GB) allocated for this job.
`crosscheckFingerprints.createNewCrosscheckFingerprints_threads`|Int|1|Requested CPU threads.
`crosscheckFingerprints.runCachedInverse_timeout`|Int|6|Number of hours before task timeout.
`crosscheckFingerprints.runCachedInverse_jobMemory`|Int|6|Memory (GB) allocated for this job.
`crosscheckFingerprints.runCachedInverse_threads`|Int|4|Requested CPU threads.
`crosscheckFingerprints.runCachedInverse_modules`|String|"picard/3.1.0 crosscheckfingerprints-haplotype-map/20230324"|Modules to load for this workflow.
`crosscheckFingerprints.runCachedInverse_validationStringency`|String|"SILENT"|Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded. See https://jira.oicr.on.ca/browse/GC-8372 for why this is set to SILENT for OICR purposes.
`crosscheckFingerprints.runCachedInverse_lodThreshold`|Float|0.0|If any two groups (with the same sample name) match with a LOD score lower than the threshold the tool will exit with a non-zero code to indicate error. Program will also exit with an error if it finds two groups with different sample name that match with a LOD score greater than -LOD_THRESHOLD. LOD score 0 means equal likelihood that the groups match vs. come from different individuals, negative LOD score -N, mean 10^N time more likely that the groups are from different individuals, and +N means 10^N times more likely that the groups are from the same individual.
`crosscheckFingerprints.runCachedInverse_exitCodeWhenNoValidChecks`|Int|0|When all LOD score are zero, exit with this value.
`crosscheckFingerprints.runCachedInverse_exitCodeWhenMismatch`|Int|0|When one or more mismatches between groups is detected, exit with this value instead of 0.
`crosscheckFingerprints.runCachedInverse_picardMaxMemMb`|Int|3000|Passed to Java -Xmx (in Mb).
`crosscheckFingerprints.runCached_timeout`|Int|6|Number of hours before task timeout.
`crosscheckFingerprints.runCached_jobMemory`|Int|6|Memory (GB) allocated for this job.
`crosscheckFingerprints.runCached_threads`|Int|4|Requested CPU threads.
`crosscheckFingerprints.runCached_modules`|String|"picard/3.1.0 crosscheckfingerprints-haplotype-map/20230324"|Modules to load for this workflow.
`crosscheckFingerprints.runCached_validationStringency`|String|"SILENT"|Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded. See https://jira.oicr.on.ca/browse/GC-8372 for why this is set to SILENT for OICR purposes.
`crosscheckFingerprints.runCached_lodThreshold`|Float|0.0|If any two groups (with the same sample name) match with a LOD score lower than the threshold the tool will exit with a non-zero code to indicate error. Program will also exit with an error if it finds two groups with different sample name that match with a LOD score greater than -LOD_THRESHOLD. LOD score 0 means equal likelihood that the groups match vs. come from different individuals, negative LOD score -N, mean 10^N time more likely that the groups are from different individuals, and +N means 10^N times more likely that the groups are from the same individual.
`crosscheckFingerprints.runCached_exitCodeWhenNoValidChecks`|Int|0|When all LOD score are zero, exit with this value.
`crosscheckFingerprints.runCached_exitCodeWhenMismatch`|Int|0|When one or more mismatches between groups is detected, exit with this value instead of 0.
`crosscheckFingerprints.runCached_picardMaxMemMb`|Int|3000|Passed to Java -Xmx (in Mb).
`crosscheckFingerprints.usePowerOfCache_timeout`|Int|1|Number of hours before task timeout.
`crosscheckFingerprints.usePowerOfCache_jobMemory`|Int|1|Memory (GB) allocated for this job.
`crosscheckFingerprints.usePowerOfCache_threads`|Int|1|Requested CPU threads.
`crosscheckFingerprints.runCrosscheckFingerprints_timeout`|Int|6|Number of hours before task timeout.
`crosscheckFingerprints.runCrosscheckFingerprints_jobMemory`|Int|6|Memory (GB) allocated for this job.
`crosscheckFingerprints.runCrosscheckFingerprints_threads`|Int|4|Requested CPU threads.
`crosscheckFingerprints.runCrosscheckFingerprints_modules`|String|"picard/3.1.0 crosscheckfingerprints-haplotype-map/20230324"|Modules to load for this workflow.
`crosscheckFingerprints.runCrosscheckFingerprints_validationStringency`|String|"SILENT"|Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded. See https://jira.oicr.on.ca/browse/GC-8372 for why this is set to SILENT for OICR purposes.
`crosscheckFingerprints.runCrosscheckFingerprints_lodThreshold`|Float|0.0|If any two groups (with the same sample name) match with a LOD score lower than the threshold the tool will exit with a non-zero code to indicate error. Program will also exit with an error if it finds two groups with different sample name that match with a LOD score greater than -LOD_THRESHOLD. LOD score 0 means equal likelihood that the groups match vs. come from different individuals, negative LOD score -N, mean 10^N time more likely that the groups are from different individuals, and +N means 10^N times more likely that the groups are from the same individual.
`crosscheckFingerprints.runCrosscheckFingerprints_exitCodeWhenNoValidChecks`|Int|0|When all LOD score are zero, exit with this value.
`crosscheckFingerprints.runCrosscheckFingerprints_exitCodeWhenMismatch`|Int|0|When one or more mismatches between groups is detected, exit with this value instead of 0.
`crosscheckFingerprints.runCrosscheckFingerprints_picardMaxMemMb`|Int|3000|Passed to Java -Xmx (in Mb).
`crosscheckFingerprints.compareAgainstFile_timeout`|Int|1|Number of hours before task timeout.
`crosscheckFingerprints.compareAgainstFile_jobMemory`|Int|1|Memory (GB) allocated for this job.
`crosscheckFingerprints.compareAgainstFile_threads`|Int|1|Requested CPU threads.
`crosscheckFingerprints.inputsToFile_timeout`|Int|1|Number of hours before task timeout.
`crosscheckFingerprints.inputsToFile_jobMemory`|Int|1|Memory (GB) allocated for this job.
`crosscheckFingerprints.inputsToFile_threads`|Int|1|Requested CPU threads.
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
`runMain.modules`|String|"crosscheck-fingerprint-caller/1.0.0"|The modules that will be loaded.


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
