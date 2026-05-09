rule samtools_index:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam"
    output:
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai"
    threads:
        config["threads"]["samtools"]
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.samtools_index.log"
    shell:
        """
        mkdir -p $(dirname {log})
        samtools index -@ {threads} {input.bam} {output.bai} > {log} 2>&1
        """


rule samtools_flagstat:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam"
    output:
        flagstat=f"{ANALYSIS_DIR}/qc/samtools/{{sample}}.flagstat.txt"
    threads:
        config["threads"]["samtools"]
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.samtools_flagstat.log"
    shell:
        """
        mkdir -p $(dirname {output.flagstat}) $(dirname {log})
        samtools flagstat -@ {threads} {input.bam} > {output.flagstat} 2> {log}
        """


rule samtools_stats:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam"
    output:
        stats=f"{ANALYSIS_DIR}/qc/samtools/{{sample}}.stats.txt"
    threads:
        config["threads"]["samtools"]
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.samtools_stats.log"
    shell:
        """
        mkdir -p $(dirname {output.stats}) $(dirname {log})
        samtools stats -@ {threads} {input.bam} > {output.stats} 2> {log}
        """
