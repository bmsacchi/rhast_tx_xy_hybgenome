#!/usr/bin/env python3

# modified from James Santangelo's snakemake rule: 
# https://github.com/James-S-Santangelo/hcn_metab/blob/main/workflow/rules/deg_analysis.smk 

import re

with open("merged_TX_combined.saf", "w") as fout:
    with open("merged_TX_combined.gff", "r") as fin:
        fout.write("GeneID\tChr\tStart\tEnd\tStrand\n")
        lines = fin.readlines()
        for l in lines:
            if not l.startswith("#"):
                sl = l.strip().split("\t")
                feat = sl[2]
                if feat =="gene":
                    chr = sl[0]
                    start = sl[3]
                    end = sl[4]
                    strand = sl[6]
                    id_old = sl[8]
                    id_new = (id_old.strip("ID=").split(";"))[0]
                    fout.write(f"{id_new}\t{chr}\t{start}\t{end}\t{strand}\n")
