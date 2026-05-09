# SNP-NIPT Pipeline

This repository contains a local-first SNP capture panel and future NIPT
analysis project. The local git repository is the source of truth; any remote
repository should be treated as a mirror only.

Phase 1 implements the SNP capture panel workflow:

1. discover paired-end 150 bp FASTQ files under `/home/user/raw_data/panal/`
2. align reads to hg38 with `bwa mem`
3. mark duplicates and inspect library complexity with GATK/Picard
4. generate BAM, insert-size, hybrid-capture, depth, and duplicate-fragment QC
5. write all analysis outputs under `/home/user/analysis/`

NIPT-specific workflow design is intentionally left for a later phase.

## Repository Layout

```text
config/
  config.yaml          # YFY paths, reference, panel BEDs, output directory
  samples.tsv          # sample sheet
Snakefile              # Snakemake entry point from repository root
workflow/
  Snakefile            # workflow implementation
  rules/               # workflow modules
  envs/snakemake.yaml  # conda environment definition for YFY
scripts/
  discover_panel_inputs.sh
  summarize_depth.py
  summarize_duplicate_fragments.py
docs/
  project_plan.md
  yfy_runbook.md
```

## Design Files

The iGeneTech report identifies the panel as `T2574V1hg38`, so the default
reference is `/home/user/reference/hg38.fa`.

Panel BED roles:

- `probeCov.bed`: bait/probe covered intervals
- `probeCov.predict.bed`: expected captured insert coverage, used as the main
  capture QC target
- `loci.bed`: SNP loci, used for loci-specific depth QC

## Quick Start on YFY

```bash
cd /path/to/snp-nipt

/home/user/anaconda3/bin/conda env create -f workflow/envs/snakemake.yaml
/home/user/anaconda3/bin/conda activate snp-nipt-snakemake

bash scripts/discover_panel_inputs.sh
snakemake -n --cores 8
snakemake --cores 8 --use-conda
```

GATK 4 is expected at `/home/user/software/bin/gatk4`.
