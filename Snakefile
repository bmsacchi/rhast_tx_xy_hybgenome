samples = ['TxF6f6', 'TxF6m23']
ref = "index/merged_TX_noMatPAR"
### workflow ###

# This rule establishes the names of output files from other rules 
rule all:
     input:
          bwaidx = "index/merged_TX_noMatPAR",
         # bam = expand("DNAmapped/{sample}.bam", sample = samples),
          markdup = expand("DNAmapped/{sample}_merged_sorted_dupsMarked.bam", sample = samples),
          stats = expand("DNAmapped/duplication_stats/{sample}_dupStats.txt", sample = samples),
          bamidx = expand("DNAmapped/{sample}_merged_sorted_dupsMarked.bam.bai", sample = samples),
          txt = expand("bamqc/{sample}/genome_results.txt", sample = samples),
          html = expand("bamqc/{sample}/qualimapReport.html", sample = samples)
# This rule creates the bwa index folder
rule bwa_index:
    input:
        database="merged_TX_noMatPAR.fa"
    output:
        done=touch("index/merged_TX_noMatPAR")
    log:
       "logs/bwa_mem2/index.log"
    resources:
        tmpdir="/ohta2/bianca.sacchi/tmp/"
    shell:
        "bwa-mem2 index -p index/merged_TX_noMatPAR {input.database}"

# This rule 
#rule bwa_mem2:
#    """
#    Map pe reads to the reference genome using bwa-mem2. Output as BAM
#    """
#    input:
#        r1 = "DNAreads/{sample}_R1.fastq.gz",
#        r2 = "DNAreads/{sample}_R2.fastq.gz",
#        bwa_index_done = ref
#    output:
#        temp('DNAmapped/{sample}.bam')
#    params:
#        r"-R '@RG\tID:{sample}\tSM:{sample}'"
#    log: 'logs/bwa_mem2/{sample}.pe.log'
#    threads: 8
#    resources:
#        tmpdir="/ohta2/bianca.sacchi/tmp"
#    shell:
#        """
#        ( bwa-mem2 mem -t {threads} {input.bwa_index_done} {input.r1} {input.r2} {params} |\
#            samtools view -hb -o {output} - ) 2> {log}
#        """

# This rule runs samtools fixmate, samtools sort, and samtools markduplicates

rule samtools_markdup:
    """
    Mark duplicate reads using samtools. Output sorted BAM.
    """
    input:
       'DNAmapped/{sample}.bam' 
       #rules.bwa_mem2.output
    output:
        bam = 'DNAmapped/{sample}_merged_sorted_dupsMarked.bam',
        stats = 'DNAmapped/duplication_stats/{sample}_dupStats.txt'
    log: 'logs/samtools_markdup/{sample}_samtools_markdup.log'
    threads: 8
    resources:
        tmpdir="/ohta2/bianca.sacchi/tmp"
    shell:
        """
        ( samtools fixmate --threads {threads} -m {input} - |\
            samtools sort --threads {threads} -T {wildcards.sample} -o - |\
            samtools markdup --threads {threads} -T {wildcards.sample} -f {output.stats} - {output.bam} ) 2> {log}
        """
# This rule indexes final bams
rule index_bam:
    """
    Index sorted BAM with marked duplicates
    """
    input:
        rules.samtools_markdup.output.bam
    output:
         bamidx = 'DNAmapped/{sample}_merged_sorted_dupsMarked.bam.bai',
    log: 'logs/index_bam/{sample}_index_bam.log'
    threads: 8
    resources:
          tmpdir="/ohta2/bianca.sacchi/tmp"
    shell:
        """
        samtools index -@ {threads} {input} 2> {log}
        """
# This rule runs bamqc and creates depth plots
rule bamqc:
    input:
        rules.samtools_markdup.output.bam
    output:
        txt = "bamqc/{sample}/genome_results.txt",
        html = "bamqc/{sample}/qualimapReport.html"
    params:
        outdir = "bamqc/{sample}",
    log:
        out = "logs/bamqc/{sample}.qc.out",
        err = "logs/bamqc/{sample}.qc.err"
    threads: 8
    resources:
        tmpdir="/ohta2/bianca.sacchi/tmp/"
    shell:
        "unset DISPLAY && "
        "qualimap bamqc "
        "--java-mem-size=16G "
        "--bam {input} "
        "--paint-chromosome-limits "
        "-nt {threads} "
        "--outdir {params.outdir} "
        "> {log.out} 2> {log.err}"


