#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=10
 
plink \
    --bfile BCY_cohort_variants \
    --score METAANALYSIS2.both_have.TBL.with_pos 1 5 11 header sum \
    --q-score-range range_list SNP.pvalue \
    --extract valid.snp \
    --out PRS


### METAANALYSIS2.both_have.TBL.with_pos 1 5 11 to get the SNP, effect allele, beta for calculating PRS