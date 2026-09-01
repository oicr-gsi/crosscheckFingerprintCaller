# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)

## [Unreleased]

### Fixed
* The CSV column order no longer depends on the workflow engine. `metadata` is a WDL `Map`,
  which has no defined ordering, so `write_json` emitted its keys in whatever order the engine
  iterated the map; that order reached the output columns unchanged, because the caller builds
  its DataFrame with `from_records` and takes the keys as it first meets them. A Cromwell
  upgrade was enough to reorder every column. `writeMetadata` now sorts the keys, so the
  columns are alphabetical and stable. Existing baselines must be regenerated once.

## [3.0.0] - 2026-05-28

### Changed
* `compareAgainst` changed to `File` type to ensure Vidarr tracks them

## [2.0.0] - 2025-12-02

### Changed
* Workflow now includes the `crosscheckFingerprint` as a subworkflow. 

## [1.0.0] - 2025-04-16
* v1 release with crosscheck_fingerprint_caller v1.0.0

## [0.3.0] - 2024-11-26

### Changed
* Actually bumped default crosscheck_fingerprint_caller to v0.3.0. Never trust autosafe.

## [0.2.0] - 2024-11-26

### Changed
* Bumped default crosscheck_fingerprint_caller to v0.3.0

## [0.1.0] - 2024-11-25

### Added
* Version that passes tests and can be tested in stage
