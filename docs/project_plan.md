# WES-NIPT Project Plan

## Goal

Build a local-first WES/NIPT analysis repository. Phase 1 delivers a minimal,
testable WES panel workflow using BWA, samtools, and BAM QC. NIPT analysis will
be designed after the WES panel workflow is stable.

## Operating Model

- Local path: `D:\pipeline\wes-nipt`
- Local git is the source of truth.
- Any remote git repository is a mirror for backup or sharing.
- Code testing and workflow execution happen on the YFY node through SSH.
- Raw data remains on YFY under `/home/user/raw_data/panal/`.
- Results are written to `/home/user/analysis/`.

## Phase 1 Workflow

Input:

- paired FASTQ files from `/home/user/raw_data/panal/`
- BED file from `/home/user/raw_data/panal/panel_report/`
- reference FASTA from `/home/user/reference`

Processing:

1. Create or activate the conda environment.
2. Confirm the sample sheet in `config/samples.tsv`.
3. Confirm `reference_fasta` and `target_bed` in `config/config.yaml`.
4. Build BWA index if it is missing.
5. Run `bwa mem`.
6. Pipe alignments to `samtools sort`.
7. Build BAM index with `samtools index`.
8. Generate `samtools flagstat` and `samtools stats`.
9. Generate `qualimap bamqc` reports using the panel BED.

Output:

```text
/home/user/analysis/
  bam/
    <sample>.sorted.bam
    <sample>.sorted.bam.bai
  qc/
    samtools/
      <sample>.flagstat.txt
      <sample>.stats.txt
    qualimap/
      <sample>/
  logs/
```

## Design Decisions

- Snakemake is used because it records dependencies, supports dry-runs, and can
  be resumed safely after failures.
- The top-level `Snakefile` lets operators run `snakemake` from the repository
  root without remembering the workflow implementation path.
- Rules are split by tool family so WES and NIPT can grow separately later.
- `config/config.yaml` owns environment-specific paths.
- `config/samples.tsv` owns sample identity and FASTQ pairing.
- The first phase avoids MultiQC, duplicate marking, BQSR, variant calling, and
  NIPT-specific metrics to keep the initial pipeline small and verifiable.

## Open Items

- Confirm whether the panel BED was built for hg19 or hg38. The current default
  is `/home/user/reference/hg19.fa` because it was discovered on YFY.
- Confirm whether `/home/user/raw_data/panal/panel_report/loci.bed` is the
  intended target interval BED for BAM QC.
- Decide later whether Phase 2 should add GATK variant calling, CNV, MultiQC,
  or NIPT-specific low-depth whole-genome analysis.
