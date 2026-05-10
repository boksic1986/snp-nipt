# Current State

Snapshot time: 2026-05-10 13:51 CST on YFY.

## Repository

- GitHub repository: `https://github.com/boksic1986/snp-nipt.git`
- GitHub default branch: `main`
- Confirmed via GitHub plugin: repository `boksic1986/snp-nipt` is public and
  the authenticated account has push/admin permissions.
- Local project workspace is `D:\pipeline\wes-nipt`.
- Deprecated local split copy `D:\pipeline\snp-nipt` was migrated into
  `D:\pipeline\wes-nipt` and should stay deleted.
- Before local directory consolidation, GitHub `main` contained handoff commit
  `664d6e5b662864e1ecedca0173d47cf84bc7e976`.

## Implemented Workflow Scope

Phase 1 implements SNP capture panel QC:

- sample discovery and fixed sample sheet in `config/samples.tsv`
- hg38 reference configuration
- BWA index and `bwa mem` alignment
- samtools sort, index, flagstat, and stats
- GATK/Picard MarkDuplicates, insert-size metrics, and HS metrics
- FastQC
- Qualimap BAM QC
- capture-region and loci-level depth summaries
- duplicate-fragment concentration summaries

NIPT-specific analysis is intentionally deferred.

## Current YFY Run

- Snakemake PID: `1518695`
- PID file: `/home/user/analysis/logs/snp-nipt.snakemake.pid`
- Main log: `/home/user/analysis/logs/snp-nipt.snakemake.run.log`
- Command shape:

```bash
cd /home/user/snp-nipt
nohup env PATH=/home/user/anaconda3/envs/snp-nipt-snakemake/bin:$PATH \
  /home/user/anaconda3/envs/snp-nipt-snakemake/bin/snakemake \
  --snakefile /home/user/snp-nipt/Snakefile \
  --configfile /home/user/snp-nipt/config/config.yaml \
  --directory /home/user/snp-nipt \
  --cores 96 \
  --resources mem_mb=96000 \
  --rerun-incomplete \
  --rerun-triggers mtime \
  --printshellcmds \
  --latency-wait 60 \
  > /home/user/analysis/logs/snp-nipt.snakemake.run.log 2>&1 &
```

Current resource controls:

- `threads.bwa: 16`
- `threads.samtools: 16`
- `threads.picard: 32`
- `threads.bamqc: 16`
- `resources.total_mem_mb: 96000`
- `resources.picard_mem_mb: 32000`
- `resources.bamqc_mem_mb: 24000`
- `java_mem: 16G`

Recent runtime note:

- The previous `--cores 96` run failed in `picard_markduplicates` with exit
  status `137`, caused by too many high-memory Picard jobs running
  concurrently.
- Picard now uses `JAVA_TOOL_OPTIONS` for `-Xmx16G` because the YFY `gatk4`
  wrapper does not support front-loaded `--java-options`.
- Dry-run and post-launch checks confirmed the memory resources are visible in
  Snakemake, and Picard entered `CollectHsMetrics` normally after restart.

## Known Runtime Context

- A stale `conda install` process was killed before this snapshot.
- An unrelated GATK HaplotypeCaller job was present and left untouched.
- Some YFY non-interactive shell utilities have locale/alias quirks; keep status
  checks simple and avoid relying on piped `head`/`sed` when not necessary.
