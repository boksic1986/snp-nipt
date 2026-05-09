include: "workflow/Snakefile"

rule default:
    default_target: True
    input:
        rules.all.input
