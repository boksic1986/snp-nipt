# Agent Skills

## Primary Agent: Codex

Use for:

- repo inspection and maintenance
- Snakemake workflow edits
- Python/bash script edits
- test execution and debugging
- YFY runtime orchestration through SSH
- GitHub repository checks through the GitHub plugin

Required skills:

- `repo-map-reading`
- `snakemake-workflow-development`
- `python-qc-script-maintenance`
- `yfy-runtime-operations`
- `github-plugin-operations`
- `superpowers:executing-plans`

Recommended Superpowers skill:

- `superpowers:subagent-driven-development` for larger implementation work
- `superpowers:executing-plans` for continuing the existing plan

## GitHub Plugin

Use for:

- confirming repository metadata
- checking branches and permissions
- opening PRs or issues if needed
- adding PR/issue comments for handoff

Confirmed repository:

- `boksic1986/snp-nipt`
- clone URL: `https://github.com/boksic1986/snp-nipt.git`
- default branch: `main`

## Superpower / Superpowers Context

Current callable tools in this session did not expose a separate `superpower`
plugin. The repository already contains Superpowers-compatible plan/spec files:

- `docs/superpowers/specs/2026-05-09-snp-capture-panel-design.md`
- `docs/superpowers/plans/2026-05-09-snp-capture-panel-qc.md`

If a future session has a callable Superpower plugin, load the matching plan or
skill before continuing substantial implementation. Until then, treat the files
under `docs/superpowers/` as the authoritative Superpowers handoff.

## Worker Guidance

- For workflow changes, own only the relevant rule/script files.
- For runtime work, report PID and log path instead of waiting for completion.
- For failures, read the Snakemake error and the specific rule log before
  editing code.
- For documentation-only updates, keep runtime facts in `handoff/`.
