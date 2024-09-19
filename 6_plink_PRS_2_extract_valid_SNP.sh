#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=1


awk 'NR!=1{print $3}' CPHS_GBMI_meta_clump.clumped >  valid.snp

awk '{print $1,$13}' METAANALYSIS2.both_have.TBL.with_pos > SNP.pvalue   ### SNP	P

# diff p-value cutoff: 5e-8, 1e-7, 5e-7, 1e-6, 5e-6, 1e-5, 5e-5, 1e-4, 5e-4, 1e-3, 0.01, 0.05, 0.1, 0.2, 0.5, 1

echo "5e-8 0 5e-8" > range_list
echo "1e-7 0 1e-7" >> range_list
echo "1e-6 0 1e-6" >> range_list
echo "1e-5 0 1e-5" >> range_list
echo "1e-4 0 1e-4" >> range_list
echo "0.001 0 0.001" >> range_list
echo "0.01 0 0.01" >> range_list
echo "0.05 0 0.05" >> range_list
echo "0.1 0 0.1" >> range_list
echo "0.5 0 0.5" >> range_list
echo "1 0 1" >> range_list
 
