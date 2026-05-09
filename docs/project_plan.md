# SNP-NIPT Project Plan

## Goal

Build a local-first SNP capture panel and future NIPT analysis repository.
Phase 1 delivers a testable SNP capture panel QC workflow using BWA, samtools,
GATK/Picard, Qualimap, FastQC, and custom depth summaries.

## Operating Model

- Local path: `D:\pipeline\snp-nipt`
- Local git is the source of truth.
- Any remote git repository is a mirror for backup or sharing.
- Code testing and workflow execution happen on the YFY node through SSH.
- Raw data remains on YFY under `/home/user/raw_data/panal/`.
- Results are written to `/home/user/analysis/`.
- Reusable bioinformatics software is installed under `/home/user/software`.

## Phase 1 Workflow

Input:

- paired FASTQ files from `/home/user/raw_data/panal/`
- iGeneTech design report and BED files from `/home/user/raw_data/panal/panel_report/`
- hg38 reference FASTA from `/home/user/reference`

Processing:

1. Create or activate the conda environment.
2. Confirm the sample sheet in `config/samples.tsv`.
3. Confirm `reference_fasta`, `bait_bed`, `capture_bed`, and `loci_bed`.
4. Build BWA index if it is missing.
5. Run `bwa mem`.
6. Pipe alignments to `samtools sort`.
7. Run GATK/Picard `MarkDuplicates`.
8. Build BAM index with `samtools index`.
9. Generate FastQC, samtools flagstat/stats, Qualimap BAM QC, Picard insert-size
   metrics, Picard hybrid-selection metrics, capture depth summary, loci depth
   summary, and duplicate-fragment concentration summary.

Output:

```text
/home/user/analysis/
  bam/
    <sample>.sorted.bam
    <sample>.markdup.bam
    <sample>.markdup.bam.bai
  qc/
    fastqc/
    samtools/
    picard/
    depth/
    duplicates/
    qualimap/
  logs/
  resources/
```

## QC Interpretation

- `probeCov.predict.bed` is the main expected capture region for coverage,
  uniformity, 50X, and 100X metrics.
- `loci.bed` is the SNP/loci level target and is summarized separately because
  each locus being covered deeply enough is clinically and analytically
  important.
- Duplicate rate is assessed both with Picard `MarkDuplicates` metrics and a
  duplicate-fragment concentration summary. A high duplicate rate concentrated
  in a few fragment coordinates suggests local over-amplification; a broad
  distribution suggests low library complexity across the library.

## Open Items

- Confirm with the panel provider whether `probeCov.predict.bed` is the intended
  expected insert coverage region for PE150 data.
- Decide later whether Phase 2 should add SNP genotyping, CNV, MultiQC, or
  NIPT-specific low-depth whole-genome analysis.
