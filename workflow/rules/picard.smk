rule gatk_sequence_dictionary:
    input:
        ref=REFERENCE_FASTA
    output:
        dict=REFERENCE_DICT
    conda:
        "../envs/snakemake.yaml"
    params:
        gatk=GATK
    log:
        f"{ANALYSIS_DIR}/logs/gatk_sequence_dictionary.log"
    shell:
        """
        mkdir -p $(dirname {log})
        {params.gatk} CreateSequenceDictionary \
          -R {input.ref} \
          -O {output.dict} > {log} 2>&1
        """


rule bed_to_interval_lists:
    input:
        dict=REFERENCE_DICT,
        bait_bed=BAIT_BED,
        capture_bed=CAPTURE_BED,
        loci_bed=LOCI_BED
    output:
        bait=BAIT_INTERVAL_LIST,
        capture=CAPTURE_INTERVAL_LIST,
        loci=LOCI_INTERVAL_LIST
    conda:
        "../envs/snakemake.yaml"
    params:
        gatk=GATK
    log:
        f"{ANALYSIS_DIR}/logs/bed_to_interval_lists.log"
    shell:
        """
        mkdir -p $(dirname {output.bait}) $(dirname {log})
        {params.gatk} BedToIntervalList -I {input.bait_bed} -O {output.bait} -SD {input.dict} > {log} 2>&1
        {params.gatk} BedToIntervalList -I {input.capture_bed} -O {output.capture} -SD {input.dict} >> {log} 2>&1
        {params.gatk} BedToIntervalList -I {input.loci_bed} -O {output.loci} -SD {input.dict} >> {log} 2>&1
        """


rule picard_markduplicates:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.sorted.bam"
    output:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        metrics=f"{ANALYSIS_DIR}/qc/picard/{{sample}}.markduplicates.metrics.txt"
    threads:
        config["threads"]["picard"]
    resources:
        mem_mb=config["resources"]["picard_mem_mb"]
    conda:
        "../envs/snakemake.yaml"
    params:
        gatk=GATK,
        java_mem=config["java_mem"],
        tmp_dir=config["picard_tmp_dir"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.markduplicates.log"
    shell:
        """
        mkdir -p $(dirname {output.bam}) $(dirname {output.metrics}) $(dirname {log}) {params.tmp_dir}
        JAVA_TOOL_OPTIONS="-Xmx{params.java_mem} -Djava.io.tmpdir={params.tmp_dir}" \
          {params.gatk} MarkDuplicates \
          -I {input.bam} \
          -O {output.bam} \
          -M {output.metrics} \
          --CREATE_INDEX false \
          --TMP_DIR {params.tmp_dir} > {log} 2>&1
        """


rule picard_insert_size:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai"
    output:
        metrics=f"{ANALYSIS_DIR}/qc/picard/{{sample}}.insert_size.metrics.txt",
        pdf=f"{ANALYSIS_DIR}/qc/picard/{{sample}}.insert_size.pdf"
    threads:
        config["threads"]["picard"]
    resources:
        mem_mb=config["resources"]["picard_mem_mb"]
    conda:
        "../envs/snakemake.yaml"
    params:
        gatk=GATK,
        java_mem=config["java_mem"],
        tmp_dir=config["picard_tmp_dir"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.insert_size.log"
    shell:
        """
        mkdir -p $(dirname {output.metrics}) $(dirname {log}) {params.tmp_dir}
        JAVA_TOOL_OPTIONS="-Xmx{params.java_mem} -Djava.io.tmpdir={params.tmp_dir}" \
          {params.gatk} CollectInsertSizeMetrics \
          -I {input.bam} \
          -O {output.metrics} \
          -H {output.pdf} \
          -M 0.5 \
          --TMP_DIR {params.tmp_dir} > {log} 2>&1
        """


rule picard_hs_metrics:
    input:
        bam=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam",
        bai=f"{ANALYSIS_DIR}/bam/{{sample}}.markdup.bam.bai",
        bait_intervals=BAIT_INTERVAL_LIST,
        target_intervals=CAPTURE_INTERVAL_LIST,
        ref=REFERENCE_FASTA
    output:
        metrics=f"{ANALYSIS_DIR}/qc/picard/{{sample}}.hs_metrics.txt",
        per_target=f"{ANALYSIS_DIR}/qc/picard/{{sample}}.per_target_coverage.txt"
    threads:
        config["threads"]["picard"]
    resources:
        mem_mb=config["resources"]["picard_mem_mb"]
    conda:
        "../envs/snakemake.yaml"
    params:
        gatk=GATK,
        java_mem=config["java_mem"],
        tmp_dir=config["picard_tmp_dir"]
    log:
        f"{ANALYSIS_DIR}/logs/{{sample}}.hs_metrics.log"
    shell:
        """
        mkdir -p $(dirname {output.metrics}) $(dirname {log}) {params.tmp_dir}
        JAVA_TOOL_OPTIONS="-Xmx{params.java_mem} -Djava.io.tmpdir={params.tmp_dir}" \
          {params.gatk} CollectHsMetrics \
          -I {input.bam} \
          -O {output.metrics} \
          -R {input.ref} \
          --BAIT_INTERVALS {input.bait_intervals} \
          --TARGET_INTERVALS {input.target_intervals} \
          --PER_TARGET_COVERAGE {output.per_target} \
          --TMP_DIR {params.tmp_dir} > {log} 2>&1
        """
