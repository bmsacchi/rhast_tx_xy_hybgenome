#!/bin/bash
awk '{if (($1 == "X") && ($4 < 220000000)) print}' maternal_liftoff.gff  > justX.gff
sed -E 's/NChap2_final_/X_NChap2_final_/g' justX.gff > justX_rename.gff
cat paternal_liftoff.gff justX_rename.gff > merged_TX_combined.gff
gffread merged_TX_combined.gff -T -o merged_TX_combined.gtf
