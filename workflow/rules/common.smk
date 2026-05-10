import csv

ANALYSIS_DIR = config["analysis_dir"].rstrip("/")
REFERENCE_FASTA = config["reference_fasta"]
REFERENCE_DICT = config["reference_dict"]
GATK = config["gatk"]
BAIT_BED = config["bait_bed"]
CAPTURE_BED = config["capture_bed"]
LOCI_BED = config["loci_bed"]
BWA_INDEX = [REFERENCE_FASTA + ext for ext in [".amb", ".ann", ".bwt", ".pac", ".sa"]]
BAIT_INTERVAL_LIST = f"{ANALYSIS_DIR}/resources/probeCov.interval_list"
CAPTURE_INTERVAL_LIST = f"{ANALYSIS_DIR}/resources/probeCov.predict.interval_list"
LOCI_INTERVAL_LIST = f"{ANALYSIS_DIR}/resources/loci.interval_list"


def load_samples(sample_sheet):
    samples = {}
    with open(sample_sheet, newline="") as handle:
        reader = csv.DictReader(
            (row for row in handle if row.strip() and not row.startswith("#")),
            delimiter="\t",
        )
        required = {"sample", "fastq_1", "fastq_2"}
        missing = required.difference(reader.fieldnames or [])
        if missing:
            raise ValueError(f"Sample sheet is missing columns: {', '.join(sorted(missing))}")

        for row in reader:
            sample = row["sample"].strip()
            if not sample:
                continue
            samples[sample] = {
                "fastq_1": row["fastq_1"].strip(),
                "fastq_2": row["fastq_2"].strip(),
            }

    if not samples:
        raise ValueError("No samples found in sample sheet")

    return samples


SAMPLES = load_samples(config["samples"])
SAMPLE_NAMES = sorted(SAMPLES)


def fastq_1(wildcards):
    return SAMPLES[wildcards.sample]["fastq_1"]


def fastq_2(wildcards):
    return SAMPLES[wildcards.sample]["fastq_2"]


def clean_fastq_1(wildcards):
    return f"{ANALYSIS_DIR}/fastq/fastp/{wildcards.sample}.R1.fastq.gz"


def clean_fastq_2(wildcards):
    return f"{ANALYSIS_DIR}/fastq/fastp/{wildcards.sample}.R2.fastq.gz"
