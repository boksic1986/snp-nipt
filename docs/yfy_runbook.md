# YFY Runbook

## 1. Copy or Pull Code

Develop locally in `D:\pipeline\snp-nipt`. Sync the repository to YFY using the
team's preferred local-to-node method. Treat YFY as the runtime copy, not the
primary repository.

## 2. Install GATK 4

GATK 4 is installed under `/home/user/software` so later SNP workflows can reuse it:

```bash
mkdir -p /home/user/software
/home/user/anaconda3/bin/conda create -y -p /home/user/software/gatk4 -c conda-forge -c bioconda gatk4
mkdir -p /home/user/software/bin
cat > /home/user/software/bin/gatk4 <<'SH'
#!/usr/bin/env bash
set -euo pipefail
export PATH=/home/user/software/gatk4/bin:${PATH}
exec /home/user/software/gatk4/bin/gatk "$@"
SH
chmod +x /home/user/software/bin/gatk4
/home/user/software/bin/gatk4 --list
```

## 3. Create Conda Environment

```bash
cd /path/to/snp-nipt
/home/user/anaconda3/bin/conda env create -f workflow/envs/snakemake.yaml
/home/user/anaconda3/bin/conda activate snp-nipt-snakemake
```

If the environment already exists:

```bash
/home/user/anaconda3/bin/conda activate snp-nipt-snakemake
```

## 4. Inspect Inputs

```bash
bash scripts/discover_panel_inputs.sh
```

Use the output to confirm:

- `config/samples.tsv`
- `reference_fasta` in `config/config.yaml`
- `bait_bed`, `capture_bed`, and `loci_bed` in `config/config.yaml`

## 5. Dry Run

```bash
snakemake -n --cores 8
```

The dry run should list planned jobs without executing them.

## 6. Execute

```bash
snakemake --cores 8 --use-conda
```

Results are written under `/home/user/analysis`.

## 7. Resume After Failure

Fix the reported problem, then rerun the same command:

```bash
snakemake --cores 8 --use-conda
```

Snakemake will continue from completed outputs.
