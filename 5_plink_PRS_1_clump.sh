#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=1

### we took CPH genome as LD ref #######

plink \
    --bfile CPH_variants \
    --clump-p1 1 \
    --clump-r2 0.1 \
    --clump-kb 250 \
    --clump METAANALYSIS2.both_have.TBL.with_pos \
    --clump-snp-field SNP \
    --clump-field P \
    --out CPHS_GBMI_meta_clump
