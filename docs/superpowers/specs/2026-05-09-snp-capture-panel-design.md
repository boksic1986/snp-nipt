# SNP Capture Panel QC Design

## Summary

This project is a local-first SNP capture panel and future NIPT workflow
repository. Phase 1 implements a SNP capture panel QC workflow on the YFY node.

## Architecture

The local repository contains code, configuration, documentation, and workflow
definitions. YFY contains raw data, reference data, conda environments, GATK,
and analysis outputs. Snakemake coordinates the workflow through focused rule
files.

## Inputs

- FASTQ files: `/home/user/raw_data/panal/`
- design report and BED files: `/home/user/raw_data/panal/panel_report/`
- reference: `/home/user/reference/hg38.fa`
- sample sheet: `config/samples.tsv`

## BED Roles

- `probeCov.bed`: bait/probe intervals for Picard hybrid-selection metrics.
- `probeCov.predict.bed`: expected captured insert coverage region for capture
  depth, uniformity, 50X, and 100X metrics.
- `loci.bed`: SNP loci for loci-level depth QC.

## Outputs

All workflow results are written under `/home/user/analysis`, grouped into BAM,
QC, log, and derived-resource directories.

## Error Handling

Snakemake stops at the first failed rule and preserves logs under
`/home/user/analysis/logs`. The dry-run command is the first validation step
before execution.

## Testing Strategy

Local unit tests cover the custom QC summary scripts. Runtime testing happens on
YFY with `snakemake -n --cores 8` followed by a real run after software and
paths are confirmed.

