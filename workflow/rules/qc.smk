rule qualimap_bamqc:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai",
        bed=CAPTURE_BED
    output:
        directory(f"{ANALYSIS_DIR}/qc/qualimap/{{sample}}")
    threads:
        config["threads"]["bamqc"]
    resources:
        mem_mb=config["resources"]["bamqc_mem_mb"]
    conda:
        "../envs/snakemake.yaml"
    params:
        java_mem=config["java_mem"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.qualimap_bamqc.log"
    shell:
        """
        mkdir -p {output} $(dirname {log})
        qualimap bamqc \
          -bam {input.bam} \
          -gff {input.bed} \
          -outdir {output} \
          -outformat PDF:HTML \
          --java-mem-size={params.java_mem} \
          -nt {threads} > {log} 2>&1
        """
