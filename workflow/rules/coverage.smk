rule capture_depth_summary:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai",
        bed=CAPTURE_BED,
        script="scripts/summarize_depth.py"
    output:
        summary=f"{ANALYSIS_DIR}/qc/depth/{{sample}}.capture_depth.summary.tsv"
    threads:
        config["threads"]["depth"]
    conda:
        "../envs/snakemake.yaml"
    params:
        thresholds=config["depth_thresholds"],
        min_base_quality=config["depth_min_base_quality"],
        min_mapping_quality=config["depth_min_mapping_quality"],
        exclude_flags=config["depth_exclude_flags"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.capture_depth.log"
    shell:
        """
        mkdir -p $(dirname {output.summary}) $(dirname {log})
        samtools depth -a \
          -@ {threads} \
          -b {input.bed} \
          -Q {params.min_base_quality} \
          -q {params.min_mapping_quality} \
          -G {params.exclude_flags} \
          {input.bam} 2> {log} \
        | python {input.script} --depth - --thresholds {params.thresholds} --output {output.summary} 2>> {log}
        """


rule loci_depth_summary:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai",
        bed=LOCI_BED,
        script="scripts/summarize_depth.py"
    output:
        summary=f"{ANALYSIS_DIR}/qc/depth/{{sample}}.loci_depth.summary.tsv"
    threads:
        config["threads"]["depth"]
    conda:
        "../envs/snakemake.yaml"
    params:
        thresholds=config["depth_thresholds"],
        min_base_quality=config["depth_min_base_quality"],
        min_mapping_quality=config["depth_min_mapping_quality"],
        exclude_flags=config["depth_exclude_flags"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.loci_depth.log"
    shell:
        """
        mkdir -p $(dirname {output.summary}) $(dirname {log})
        samtools depth -a \
          -@ {threads} \
          -b {input.bed} \
          -Q {params.min_base_quality} \
          -q {params.min_mapping_quality} \
          -G {params.exclude_flags} \
          {input.bam} 2> {log} \
        | python {input.script} --depth - --thresholds {params.thresholds} --output {output.summary} 2>> {log}
        """


rule duplicate_fragment_summary:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai",
        script="scripts/summarize_duplicate_fragments.py"
    output:
        summary=f"{ANALYSIS_DIR}/qc/duplicates/{{sample}}.duplicate_fragments.summary.tsv",
        top=f"{ANALYSIS_DIR}/qc/duplicates/{{sample}}.duplicate_fragments.top.tsv",
        histogram=f"{ANALYSIS_DIR}/qc/duplicates/{{sample}}.duplicate_fragments.histogram.tsv"
    conda:
        "../envs/snakemake.yaml"
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.duplicate_fragments.log"
    shell:
        """
        mkdir -p $(dirname {output.summary}) $(dirname {log})
        samtools view -f 1024 -f 64 -F 4 {input.bam} 2> {log} \
        | python {input.script} \
            --output {output.summary} \
            --top-output {output.top} \
            --histogram-output {output.histogram} 2>> {log}
        """
