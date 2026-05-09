# WES-NIPT Pipeline

This repository contains a local-first WES/NIPT analysis project. The local git
repository is the source of truth; any remote repository should be treated as a
mirror only.

Phase 1 implements the WES panel workflow:

1. discover panel FASTQ files under `/home/user/raw_data/panal/`
2. align reads with `bwa mem`
3. sort and index BAM files with `samtools`
4. produce BAM QC reports with `samtools` and `qualimap bamqc`
5. write all analysis outputs under `/home/user/analysis/`

NIPT-specific workflow design is intentionally left for a later phase.

## Repository Layout

```text
config/
  config.yaml          # YFY paths, reference, output directory, resources
  samples.tsv          # sample sheet template
Snakefile              # Snakemake entry point from repository root
workflow/
  Snakefile            # workflow implementation
  rules/               # workflow modules
  envs/snakemake.yaml  # conda environment definition for YFY
scripts/
  discover_panel_inputs.sh
docs/
  project_plan.md
  yfy_runbook.md
```

## Quick Start on YFY

```bash
cd /path/to/wes-nipt

/home/user/anaconda3/bin/conda env create -f workflow/envs/snakemake.yaml
/home/user/anaconda3/bin/conda activate wes-nipt-snakemake

bash scripts/discover_panel_inputs.sh
snakemake -n --cores 8
snakemake --cores 8 --use-conda
```

Before running, confirm `config/config.yaml` points to the real reference FASTA
under `/home/user/reference`.
