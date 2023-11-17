#!/bin/bash
awk '{if (($1 == "X") && ($4 < 220000000)) print}' maternal_liftoff.gff  > justX.gff
sed -E 's/NChap2_final_/X_NChap2_final_/g' justX.gff > justX_rename.gff
