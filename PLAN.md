# Plan

## Done

- Reframed the repository around SNP capture panel QC.
- Added configuration for hg38 and iGeneTech `T2574V1hg38` BED roles.
- Added custom QC summary scripts and unit tests.
- Split Snakemake rules by tool family under `workflow/rules/`.
- Added FastQC, BWA, samtools, GATK/Picard, Qualimap, depth, and duplicate
  fragment summary outputs.
- Created the YFY conda runtime environment.
- Installed or wired the GATK 4 wrapper at `/home/user/software/bin/gatk4`.
- Synced the repository to GitHub at `boksic1986/snp-nipt`.
- Started the full YFY Snakemake run in the background.

## In Progress

- Full YFY workflow execution.
- Current Snakemake PID: `1272575`
- Watch log: `/home/user/analysis/logs/snp-nipt.snakemake.run.log`

## Next Checks

1. Check whether the run is still active:

```bash
ssh YFY "ps -p 1272575 -o pid,ppid,stat,etime,pcpu,pmem,cmd"
```

2. Check recent workflow events:

```bash
ssh YFY "tail -80 /home/user/analysis/logs/snp-nipt.snakemake.run.log"
```

3. If the run fails, inspect the rule-specific log named in the Snakemake error
   under `/home/user/analysis/logs/`.

4. After completion, verify the expected final output groups under:

```text
/home/user/analysis/bam
/home/user/analysis/qc/fastqc
/home/user/analysis/qc/samtools
/home/user/analysis/qc/picard
/home/user/analysis/qc/depth
/home/user/analysis/qc/duplicates
/home/user/analysis/qc/qualimap
```

## Deferred

- Provider confirmation that `probeCov.predict.bed` is the correct expected
  captured insert region for PE150 capture QC.
- Phase 2 NIPT-specific workflow design.
- Optional MultiQC rollup after the full run completes.
