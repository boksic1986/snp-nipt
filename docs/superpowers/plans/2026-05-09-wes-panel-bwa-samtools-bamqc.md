# WES Panel BWA-Samtools-BAMQC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the initial WES panel Snakemake workflow using BWA, samtools, and BAM QC.

**Architecture:** The repository is local-first and uses Snakemake as the workflow engine. Configuration is isolated in `config/config.yaml` and `config/samples.tsv`; rules are split by tool family under `workflow/rules`.

**Tech Stack:** Snakemake, conda, BWA, samtools, qualimap, bash, local git.

---

### Task 1: Repository Skeleton

**Files:**
- Create: `.gitignore`
- Create: `README.md`
- Create: `docs/project_plan.md`
- Create: `docs/yfy_runbook.md`

- [ ] Create the documentation and ignore files.
- [ ] Initialize local git with `git init`.
- [ ] Commit the project skeleton with `git commit -m "chore: initialize wes nipt pipeline skeleton"`.

### Task 2: Configuration

**Files:**
- Create: `config/config.yaml`
- Create: `config/samples.tsv`

- [ ] Add YFY runtime paths to `config/config.yaml`.
- [ ] Add reference and BED configuration fields.
- [ ] Add a sample sheet template with `sample`, `fastq_1`, and `fastq_2` columns.

### Task 3: Snakemake Workflow

**Files:**
- Create: `workflow/Snakefile`
- Create: `Snakefile`
- Create: `workflow/rules/bwa.smk`
- Create: `workflow/rules/samtools.smk`
- Create: `workflow/rules/qc.smk`
- Create: `workflow/envs/snakemake.yaml`

- [ ] Implement sample-sheet loading in `workflow/Snakefile`.
- [ ] Implement BWA index and alignment rules.
- [ ] Implement BAM indexing and samtools QC rules.
- [ ] Implement qualimap BAM QC rule.
- [ ] Add conda environment dependencies.

### Task 4: YFY Runtime Validation

**Files:**
- Create: `scripts/discover_panel_inputs.sh`

- [ ] Add an input discovery script for FASTQ, BED, and reference FASTA files.
- [ ] On YFY, run `bash scripts/discover_panel_inputs.sh`.
- [ ] Update `config/samples.tsv`, `reference_fasta`, and `target_bed`.
- [ ] Run `snakemake -n --cores 8`.
- [ ] Run `snakemake --cores 8 --use-conda` after dry-run succeeds.
