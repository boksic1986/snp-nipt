rule bwa_index:
    input:
        ref=REFERENCE_FASTA
    output:
        BWA_INDEX
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/bwa_index.log"
    shell:
        """
        mkdir -p $(dirname {log})
        bwa index {input.ref} > {log} 2>&1
        """


rule bwa_mem_sort:
    input:
        ref=REFERENCE_FASTA,
        index=BWA_INDEX,
        fastq_1=fastq_1,
        fastq_2=fastq_2
    output:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.sorted.bam"
    threads:
        config["threads"]["bwa"]
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.bwa_mem_sort.log"
    shell:
        r"""
        mkdir -p $(dirname {output.bam}) $(dirname {log})
        bwa mem \
          -t {threads} \
          -R '@RG\tID:{wildcards.sample}\tSM:{wildcards.sample}\tPL:ILLUMINA' \
          {input.ref} {input.fastq_1} {input.fastq_2} 2> {log} \
        | samtools sort -@ {threads} -o {output.bam} - 2>> {log}
        """
