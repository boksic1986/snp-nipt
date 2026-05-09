# SNP Capture Panel QC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the initial SNP capture panel Snakemake workflow using BWA, samtools, GATK/Picard, Qualimap, FastQC, and custom QC summaries.

**Architecture:** The repository is local-first and uses Snakemake as the workflow engine. Configuration is isolated in `config/config.yaml` and `config/samples.tsv`; rules are split by tool family under `workflow/rules`.

**Tech Stack:** Snakemake, conda, BWA, samtools, GATK 4/Picard, Qualimap, FastQC, Python, bash, local git.

---

### Task 1: Reframe Project

**Files:**
- Modify: `README.md`
- Modify: `docs/project_plan.md`
- Modify: `docs/yfy_runbook.md`
- Modify: `config/config.yaml`

- [ ] Rename project documentation from WES panel to SNP capture panel.
- [ ] Set hg38 as the default reference.
- [ ] Configure `probeCov.bed`, `probeCov.predict.bed`, and `loci.bed` with distinct roles.

### Task 2: Add Custom QC Summaries

**Files:**
- Create: `scripts/summarize_depth.py`
- Create: `scripts/summarize_duplicate_fragments.py`
- Create: `tests/test_qc_scripts.py`

- [ ] Test depth threshold summaries.
- [ ] Test duplicate-fragment concentration summaries.
- [ ] Implement the scripts and verify tests pass.

### Task 3: Extend Snakemake Workflow

**Files:**
- Modify: `workflow/Snakefile`
- Create: `workflow/rules/fastq.smk`
- Create: `workflow/rules/picard.smk`
- Create: `workflow/rules/coverage.smk`
- Modify: `workflow/rules/samtools.smk`
- Modify: `workflow/rules/qc.smk`
- Modify: `workflow/envs/snakemake.yaml`

- [ ] Add FastQC.
- [ ] Add GATK/Picard MarkDuplicates, CollectInsertSizeMetrics, and CollectHsMetrics.
- [ ] Add capture-region and loci-level depth summaries.
- [ ] Add duplicate-fragment concentration summary.
- [ ] Keep Qualimap as a broad BAM QC layer using `probeCov.predict.bed`.

### Task 4: YFY Runtime Validation

**Files:**
- Modify: `docs/yfy_runbook.md`

- [ ] Install GATK 4 under `/home/user/software`.
- [ ] Create or update the `snp-nipt-snakemake` conda environment.
- [ ] Sync the local repository to YFY.
- [ ] Run `snakemake -n --cores 8`.
- [ ] Run `snakemake --cores 8 --use-conda` after dry-run succeeds.
