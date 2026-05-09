# YFY Runbook

## 1. Copy or Pull Code

Develop locally in `D:\pipeline\wes-nipt`. Sync the repository to YFY using the
team's preferred local-to-node method. Treat YFY as the runtime copy, not the
primary repository.

## 2. Create Conda Environment

```bash
cd /path/to/wes-nipt
/home/user/anaconda3/bin/conda env create -f workflow/envs/snakemake.yaml
/home/user/anaconda3/bin/conda activate wes-nipt-snakemake
```

If the environment already exists:

```bash
/home/user/anaconda3/bin/conda activate wes-nipt-snakemake
```

## 3. Inspect Inputs

```bash
bash scripts/discover_panel_inputs.sh
```

Use the output to update:

- `config/samples.tsv`
- `reference_fasta` in `config/config.yaml`
- `target_bed` in `config/config.yaml`

## 4. Dry Run

```bash
snakemake -n --cores 8
```

The dry run should list planned jobs without executing them.

## 5. Execute

```bash
snakemake --cores 8 --use-conda
```

Results are written under `/home/user/analysis`.

## 6. Resume After Failure

Fix the reported problem, then rerun the same command:

```bash
snakemake --cores 8 --use-conda
```

Snakemake will continue from completed outputs.

## 7. Useful Checks

```bash
ls -lh /home/user/analysis/bam
ls -lh /home/user/analysis/qc/samtools
find /home/user/analysis/qc/qualimap -maxdepth 2 -type f | sort
```

