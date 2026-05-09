rule fastqc:
    input:
        fastq_1=fastq_1,
        fastq_2=fastq_2
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

