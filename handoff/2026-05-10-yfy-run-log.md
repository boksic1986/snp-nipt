# YFY Run Log - 2026-05-10

## Snapshot

- Time: 2026-05-10 00:57:57 CST
- Runtime host: `YFY`
- Runtime repo: `/home/user/snp-nipt`
- Analysis directory: `/home/user/analysis`
- Snakemake PID: `1272575`
- PID file: `/home/user/analysis/logs/snp-nipt.snakemake.pid`
- Main log: `/home/user/analysis/logs/snp-nipt.snakemake.run.log`

## Launch Command

```bash
cd /home/user/snp-nipt
mkdir -p /home/user/analysis/logs
nohup env PATH=/home/user/anaconda3/envs/snp-nipt-snakemake/bin:$PATH \
  /home/user/anaconda3/envs/snp-nipt-snakemake/bin/snakemake \
  --cores 8 --rerun-incomplete --printshellcmds --latency-wait 60 \
  > /home/user/analysis/logs/snp-nipt.snakemake.run.log 2>&1 &
echo $! > /home/user/analysis/logs/snp-nipt.snakemake.pid
```

The PID file was later corrected to the actual Snakemake Python process:
`1272575`.

## Process Snapshot

```text
PID      PPID    STAT  ELAPSED  %CPU  %MEM  CMD
1272575  1272572 Sl    12:41    2.4   0.0   /home/user/anaconda3/envs/snp-nipt-snakemake/bin/python -m snakemake --cores 8 --rerun-incomplete --printshellcmds --latency-wait 60
```

## Progress Snapshot

The main log showed:

```text
Finished jobid: 3 (Rule: fastqc)
4 of 123 steps (3%) done
Execute 1 jobs...
```

The next scheduled job was FastQC for:

```text
JZ26089875-SSL-4-Sample12A
```

FastQC output count:

```text
16 zip/html files under /home/user/analysis/qc/fastqc
```

## Notes

- A stale `conda install` process from earlier setup was terminated.
- The active Snakemake run was left running.
- An unrelated GATK HaplotypeCaller process was left untouched.
- The run is expected to continue through BWA, Picard, samtools, depth,
  duplicates, and Qualimap after FastQC and prerequisite resources complete.

## Quick Commands

Check the process:

```bash
ssh YFY "ps -p 1272575 -o pid,ppid,stat,etime,pcpu,pmem,cmd"
```

Read recent workflow log:

```bash
ssh YFY "tail -80 /home/user/analysis/logs/snp-nipt.snakemake.run.log"
```

List failed or recent rule logs if Snakemake stops:

```bash
ssh YFY "ls -lt /home/user/analysis/logs | head"
```

## Cores 96 Switch

At 2026-05-10 08:49 CST the workflow was still running with `--cores 8`.
YFY had 112 CPUs and low load, so a background switch script was started to
raise Snakemake to `--cores 96` after the active `Sample4A` BWA/sort job
finishes.

- Switch watcher PID: `1391617`
- Switch watcher PID file:
  `/home/user/analysis/logs/snp-nipt.switch-to-96.pid`
- Switch log: `/home/user/analysis/logs/snp-nipt.switch-to-96.log`
- Switch script: `/home/user/analysis/logs/snp-nipt.switch-to-96.sh`
- Current old Snakemake PID before switch: `1272575`

The watcher waits for:

```text
/home/user/analysis/bam/JZ26089875-SSL-4-Sample4A.sorted.bam
```

Then it stops the old `--cores 8` Snakemake process and restarts:

```bash
cd /home/user/snp-nipt
nohup env PATH=/home/user/anaconda3/envs/snp-nipt-snakemake/bin:$PATH \
  /home/user/anaconda3/envs/snp-nipt-snakemake/bin/snakemake \
  --snakefile /home/user/snp-nipt/Snakefile \
  --configfile /home/user/snp-nipt/config/config.yaml \
  --directory /home/user/snp-nipt \
  --cores 96 --rerun-incomplete --printshellcmds --latency-wait 60 \
  > /home/user/analysis/logs/snp-nipt.snakemake.run.log 2>&1 &
```

Check switch progress:

```bash
ssh YFY "cat /home/user/analysis/logs/snp-nipt.switch-to-96.pid; tail -80 /home/user/analysis/logs/snp-nipt.switch-to-96.log"
```

## Tool Thread Tuning

At 2026-05-10 09:06 CST, Snakemake was restarted again after increasing
per-tool thread settings in `config/config.yaml` and syncing the updated
workflow files to YFY.

Updated thread settings:

```yaml
threads:
  bwa: 16
  samtools: 16
  fastqc: 4
  picard: 16
  bamqc: 16
  depth: 16
```

`workflow/rules/bwa.smk` now declares each `bwa_mem_sort` job as 32 Snakemake
threads and runs:

```bash
bwa mem -t 16 ... | samtools sort -@ 16 ...
```

Picard rules now declare `threads: 16` for Snakemake scheduling. Picard
MarkDuplicates itself is not meaningfully multithreaded here; this thread
declaration is used to limit how many memory-heavy Picard jobs Snakemake runs at
once.

Important: after changing rule code/thread parameters, Snakemake initially tried
to rerun already completed BWA outputs. That restart was stopped quickly. The
active restart uses:

```bash
--rerun-triggers mtime
```

so completed outputs are not rerun merely because rule code or thread parameters
changed. Three completed sorted BAMs had already been touched by the short
wrong restart and are being regenerated:

```text
JZ26085885-SSL-2-Sample6.sorted.bam
JZ26089875-SSL-4-Sample14A.sorted.bam
JZ26089875-SSL-4-Sample10A.sorted.bam
```

Active tuned Snakemake PID:

```text
1401337
```

Active tuned launch command:

```bash
cd /home/user/snp-nipt
nohup env PATH=/home/user/anaconda3/envs/snp-nipt-snakemake/bin:$PATH \
  /home/user/anaconda3/envs/snp-nipt-snakemake/bin/snakemake \
  --snakefile /home/user/snp-nipt/Snakefile \
  --configfile /home/user/snp-nipt/config/config.yaml \
  --directory /home/user/snp-nipt \
  --cores 96 --rerun-incomplete --rerun-triggers mtime \
  --printshellcmds --latency-wait 60 \
  > /home/user/analysis/logs/snp-nipt.snakemake.run.log 2>&1 &
```
