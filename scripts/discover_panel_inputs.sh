#!/usr/bin/env bash
set -euo pipefail

RAW_DIR="${1:-/home/user/raw_data/panal}"
BED_DIR="${2:-/home/user/raw_data/panal/panel_report}"

echo "FASTQ files under ${RAW_DIR}:"
find "${RAW_DIR}" -maxdepth 2 -type f \( \
  -name "*.fastq.gz" -o -name "*.fq.gz" -o -name "*.fastq" -o -name "*.fq" \
\) | sort

echo
echo "BED files under ${BED_DIR}:"
find "${BED_DIR}" -maxdepth 2 -type f \( -name "*.bed" -o -name "*.BED" \) | sort

echo
echo "Reference FASTA candidates under /home/user/reference:"
find /home/user/reference -maxdepth 2 -type f \( -name "*.fa" -o -name "*.fasta" -o -name "*.fna" \) | sort

