# Agents

This repository is a local-first SNP capture panel workflow. Treat local git as
the source of truth and GitHub as the remote mirror.

## Operating Rules

- Use `D:\pipeline\wes-nipt` as the only local project workspace.
- Do not create, read from, or save new project files under
  `D:\pipeline\snp-nipt`; that directory was a temporary split copy and must
  stay deleted after migration.
- Root-level handoff and agent documents must use `.md` suffixes, for example
  `AGENTS.md`, `CURRENT_STATE.md`, `PLAN.md`, `REP_MAP.md`, and
  `AGENT_SKILLS.md`.
- Keep edits small, reviewable, and aligned with the existing Snakemake layout.
- Do not revert user changes unless the user explicitly asks.
- Prefer `rg` for search and focused shell commands for inspection.
- Use `apply_patch` for manual edits.
- Keep runtime data on YFY. Do not commit raw FASTQ, BAM, QC output, conda
  environments, or generated logs.
- Long-running workflow jobs should be started in the background and reported by
  PID plus log path.

## Runtime Host

- Local workspace: `D:\pipeline\wes-nipt`
- Runtime host alias: `YFY`
- Runtime repo copy: `/home/user/snp-nipt`
- Raw data: `/home/user/raw_data/panal`
- Analysis output: `/home/user/analysis`
- Main Snakemake log: `/home/user/analysis/logs/snp-nipt.snakemake.run.log`
- Main Snakemake PID file: `/home/user/analysis/logs/snp-nipt.snakemake.pid`

## Plugin Expectations

- Use the GitHub plugin for remote repository checks, PRs, issues, and comments.
- Use the Superpowers project docs under `docs/superpowers/` for plan/spec
  continuity. If a callable Superpower plugin is available in a future session,
  load the matching skill before executing substantial plan work.

## Safety Notes

- A separate GATK HaplotypeCaller process may be running on YFY. It is not part
  of this Snakemake workflow and should not be killed or modified.
- The current Snakemake run was started with conda environments ignored because
  the required tools are already available through the runtime environment.
