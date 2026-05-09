#!/usr/bin/env python3
"""Summarize duplicate read concentration from SAM records."""

from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path
from typing import TextIO


READ1_FLAG = 0x40
DUPLICATE_FLAG = 0x400
UNMAPPED_FLAG = 0x4


def _is_duplicate_read1(flag: int) -> bool:
    return bool(flag & DUPLICATE_FLAG) and bool(flag & READ1_FLAG) and not bool(flag & UNMAPPED_FLAG)


def summarize_duplicate_sam(handle: TextIO) -> dict[str, float | int]:
    fragment_counts: Counter[tuple[str, int, int, int]] = Counter()
    duplicate_read1_records = 0

    for line in handle:
        if not line.strip() or line.startswith("@"):
            continue
        fields = line.rstrip("\n").split("\t")
        if len(fields) < 9:
            continue
        flag = int(fields[1])
        if not _is_duplicate_read1(flag):
            continue

        rname = fields[2]
        pos = int(fields[3])
        pnext = int(fields[7]) if fields[7].isdigit() else 0
        template_length = abs(int(fields[8]))
        left_pos = min(pos, pnext) if pnext > 0 else pos
        fragment_counts[(rname, left_pos, template_length, flag & 0x30)] += 1
        duplicate_read1_records += 1

    counts = sorted(fragment_counts.values(), reverse=True)
    top10_total = sum(counts[:10])

    return {
        "duplicate_read1_records": duplicate_read1_records,
        "duplicate_fragment_keys": len(fragment_counts),
        "top_fragment_duplicate_read1_count": counts[0] if counts else 0,
        "top10_fragment_duplicate_read1_count": top10_total,
        "top10_fragment_fraction": round(top10_total * 100.0 / duplicate_read1_records, 4)
        if duplicate_read1_records
        else 0.0,
    }


def write_summary(summary: dict[str, float | int], output_path: Path) -> None:
    with Path(output_path).open("w", encoding="utf-8", newline="") as handle:
        handle.write("metric\tvalue\n")
        for key, value in summary.items():
            handle.write(f"{key}\t{value}\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sam", type=Path, help="duplicate-only SAM records; stdin if omitted")
    parser.add_argument("--output", required=True, type=Path, help="summary TSV")
    args = parser.parse_args()

    if args.sam:
        with args.sam.open(encoding="utf-8") as handle:
            summary = summarize_duplicate_sam(handle)
    else:
        summary = summarize_duplicate_sam(sys.stdin)

    write_summary(summary, args.output)


if __name__ == "__main__":
    main()

