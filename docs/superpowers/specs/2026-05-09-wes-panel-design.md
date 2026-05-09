# WES Panel BWA-Samtools-BAMQC Design

## Summary

This project is a local-first WES/NIPT workflow repository. Phase 1 implements a
minimal WES panel workflow on the YFY node using BWA, samtools, and BAM QC.

## Architecture

The local repository contains code, configuration, documentation, and workflow
definitions. YFY contains raw data, reference data, conda environments, and
analysis outputs. Snakemake coordinates the workflow through a small set of
tool-focused rule files.

## Inputs

- FASTQ files: `/home/user/raw_data/panal/`
- BED files: `/home/user/raw_data/panal/panel_report/`
- reference directory: `/home/user/reference`
- sample sheet: `config/samples.tsv`

## Outputs

All workflow results are written under `/home/user/analysis`, grouped into BAM,
QC, and log directories.

## Error Handling

Snakemake stops at the first failed rule and preserves logs under
`/home/user/analysis/logs`. The dry-run command is the first validation step
before execution.

## Testing Strategy

Local testing validates repository structure and Snakefile parsing where
possible. Runtime testing happens on YFY with `snakemake -n --cores 8` followed
by a real run after sample, BED, and reference paths are confirmed.

