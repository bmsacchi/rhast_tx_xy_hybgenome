#!/usr/bin/env python3

## Python script to fix GFF
## 1. append "X" to the gene names of the X gametologs
## 2. add corrected X only gff to the paternal liftover gff (contains Y)
# (note the X gff already has the PAR bits removed.

import gffutils

# upload database from file
#db = gffutils.create_db(data='justX.gff',
#                        dbfn='justX.db',
#                        id_spec='ID', 
#                        merge_strategy ="create_unique")
db = gffutils.FeatureDB('justX.db')
