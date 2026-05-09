#!/usr/bin/env python3
"""Summarize duplicate read concentration from SAM records."""

from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path
from typing import Any, TextIO


READ1_FLAG = 0x40
DUPLICATE_FLAG = 0x400
UNMAPPED_FLAG = 0x4


def _is_duplicate_read1(flag: int) -> bool:
    return bool(flag & DUPLICATE_FLAG) and bool(flag & READ1_FLAG) and not bool(flag & UNMAPPED_FLAG)


def summarize_duplicate_sam(handle: TextIO) -> dict[str, Any]:
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
    top_fragments = [
        (*fragment, count)
        for fragment, count in sorted(
            fragment_counts.items(),
            key=lambda item: (-item[1], item[0][0], item[0][1], item[0][2], item[0][3]),
        )
    ]
    duplicate_count_histogram = Counter(fragment_counts.values())

    return {
        "duplicate_read1_records": duplicate_read1_records,
        "duplicate_fragment_keys": len(fragment_counts),
        "top_fragment_duplicate_read1_count": counts[0] if counts else 0,
        "top10_fragment_duplicate_read1_count": top10_total,
        "top10_fragment_fraction": round(top10_total * 100.0 / duplicate_read1_records, 4)
        if duplicate_read1_records
        else 0.0,
        "_top_fragments": top_fragments,
        "_duplicate_count_histogram": duplicate_count_histogram,
    }


def write_summary(summary: dict[str, Any], output_path: Path) -> None:
    with Path(output_path).open("w", encoding="utf-8", newline="") as handle:
        handle.write("metric\tvalue\n")
        for key, value in summary.items():
            if key.startswith("_"):
                continue
            handle.write(f"{key}\t{value}\n")


def write_top_fragments(summary: dict[str, Any], output_path: Path, limit: int = 1000) -> None:
    with Path(output_path).open("w", encoding="utf-8", newline="") as handle:
        handle.write("rank\tchrom\tleft_pos\ttemplate_length\torientation\tduplicate_read1_count\n")
        for rank, (chrom, left_pos, template_length, orientation, count) in enumerate(
            summary.get("_top_fragments", [])[:limit],
            start=1,
        ):
            handle.write(f"{rank}\t{chrom}\t{left_pos}\t{template_length}\t{orientation}\t{count}\n")


def write_duplicate_histogram(summary: dict[str, Any], output_path: Path) -> None:
    histogram = summary.get("_duplicate_count_histogram", Counter())
    with Path(output_path).open("w", encoding="utf-8", newline="") as handle:
        handle.write("duplicate_read1_count\tfragment_keys\tduplicate_read1_records\n")
        for duplicate_count in sorted(histogram, reverse=True):
            fragment_keys = histogram[duplicate_count]
            handle.write(f"{duplicate_count}\t{fragment_keys}\t{duplicate_count * fragment_keys}\n")


def write_duplicate_reports(
    summary: dict[str, Any],
    summary_path: Path,
    top_path: Path,
    histogram_path: Path,
    top_limit: int = 1000,
) -> None:
    write_summary(summary, summary_path)
    write_top_fragments(summary, top_path, top_limit)
    write_duplicate_histogram(summary, histogram_path)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sam", type=Path, help="duplicate-only SAM records; stdin if omitted")
    parser.add_argument("--output", required=True, type=Path, help="summary TSV")
    parser.add_argument("--top-output", required=True, type=Path, help="top duplicate fragments TSV")
    parser.add_argument("--histogram-output", required=True, type=Path, help="duplicate count histogram TSV")
    parser.add_argument("--top-limit", default=1000, type=int, help="number of top fragments to report")
    args = parser.parse_args()

    if args.sam:
        with args.sam.open(encoding="utf-8") as handle:
            summary = summarize_duplicate_sam(handle)
    else:
        summary = summarize_duplicate_sam(sys.stdin)

    write_duplicate_reports(
        summary,
        summary_path=args.output,
        top_path=args.top_output,
        histogram_path=args.histogram_output,
        top_limit=args.top_limit,
    )


if __name__ == "__main__":
    main()
