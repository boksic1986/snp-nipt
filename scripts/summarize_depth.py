#!/usr/bin/env python3
"""Summarize samtools depth output for capture-panel QC."""

from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path
from typing import TextIO


def _percent(numerator: int, denominator: int) -> float:
    if denominator == 0:
        return 0.0
    return round(numerator * 100.0 / denominator, 4)


def _median_from_histogram(histogram: Counter[int], total: int) -> float:
    if total == 0:
        return 0.0

    left_index = (total - 1) // 2
    right_index = total // 2
    running = 0
    left_value = None
    right_value = None

    for depth in sorted(histogram):
        running += histogram[depth]
        if left_value is None and running > left_index:
            left_value = depth
        if right_value is None and running > right_index:
            right_value = depth
            break

    return round((left_value + right_value) / 2.0, 4)


def summarize_depth_stream(handle: TextIO, thresholds: list[int]) -> dict[str, float | int]:
    total_bases = 0
    total_depth = 0
    histogram: Counter[int] = Counter()
    threshold_counts = {threshold: 0 for threshold in thresholds}

    for line in handle:
        if not line.strip():
            continue
        fields = line.rstrip("\n").split("\t")
        if len(fields) < 3:
            continue
        depth = int(fields[2])
        total_bases += 1
        total_depth += depth
        histogram[depth] += 1
        for threshold in thresholds:
            if depth >= threshold:
                threshold_counts[threshold] += 1

    summary: dict[str, float | int] = {
        "bases": total_bases,
        "mean_depth": round(total_depth / total_bases, 4) if total_bases else 0.0,
        "median_depth": _median_from_histogram(histogram, total_bases),
        "zero_depth_bases": histogram.get(0, 0),
    }

    for threshold in thresholds:
        summary[f"bases_ge_{threshold}x"] = threshold_counts[threshold]
        summary[f"pct_ge_{threshold}x"] = _percent(threshold_counts[threshold], total_bases)

    return summary


def summarize_depth_file(depth_path: Path, thresholds: list[int]) -> dict[str, float | int]:
    with Path(depth_path).open(encoding="utf-8") as handle:
        return summarize_depth_stream(handle, thresholds)


def write_summary(summary: dict[str, float | int], output_path: Path) -> None:
    with Path(output_path).open("w", encoding="utf-8", newline="") as handle:
        handle.write("metric\tvalue\n")
        for key, value in summary.items():
            handle.write(f"{key}\t{value}\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--depth", required=True, help="samtools depth TSV, or '-' for stdin")
    parser.add_argument("--output", required=True, type=Path, help="summary TSV")
    parser.add_argument(
        "--thresholds",
        default="1,10,20,30,50,100",
        help="comma-separated depth thresholds",
    )
    args = parser.parse_args()

    thresholds = [int(item) for item in args.thresholds.split(",") if item]
    if args.depth == "-":
        import sys

        summary = summarize_depth_stream(sys.stdin, thresholds)
    else:
        summary = summarize_depth_file(Path(args.depth), thresholds)
    write_summary(summary, args.output)


if __name__ == "__main__":
    main()
