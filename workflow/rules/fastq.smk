rule fastp_trim:
    input:
        fastq_1=fastq_1,
        fastq_2=fastq_2
    output:
        fastq_1=f"{ANALYSIS_DIR}/fastq/fastp/{{sample}}.R1.fastq.gz",
        fastq_2=f"{ANALYSIS_DIR}/fastq/fastp/{{sample}}.R2.fastq.gz",
        html=f"{ANALYSIS_DIR}/qc/fastp/{{sample}}.fastp.html",
        json=f"{ANALYSIS_DIR}/qc/fastp/{{sample}}.fastp.json"
    threads:
        config["threads"]["fastp"]
    conda:
        "../envs/snakemake.yaml"
    params:
        qualified_quality_phred=config["fastp"]["qualified_quality_phred"],
        length_required=config["fastp"]["length_required"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.fastp.log"
    shell:
        """
        mkdir -p $(dirname {output.fastq_1}) $(dirname {output.html}) $(dirname {log})
        fastp \
          --in1 {input.fastq_1} \
          --in2 {input.fastq_2} \
          --out1 {output.fastq_1} \
          --out2 {output.fastq_2} \
          --html {output.html} \
          --json {output.json} \
          --thread {threads} \
          --detect_adapter_for_pe \
          --qualified_quality_phred {params.qualified_quality_phred} \
          --length_required {params.length_required} > {log} 2>&1
        """


rule fastqc:
    input:
        fastq_1=clean_fastq_1,
        fastq_2=clean_fastq_2
    output:
        directory(f"{ANALYSIS_DIR}/qc/fastqc/{{sample}}")
    threads:
        config["threads"]["fastqc"]
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.fastqc.log"
    shell:
        """
        mkdir -p {output} $(dirname {log})
        fastqc --threads {threads} --outdir {output} {input.fastq_1} {input.fastq_2} > {log} 2>&1
        """
