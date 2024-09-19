### download GRCh38_LDblocks
https://github.com/jmacdon/LDblocks_GRCh38/blob/master/data/pyrho_EAS_LD_blocks.bed

### build references referred to FinnGen pipelines
https://github.com/getian107/PRScs/issues/61
https://github.com/FINNGEN/CS-PRS-pipeline

### filter SNPs' MAF before building LD matrix
plink --bfile CPH_variants --maf 0.01 --make-bed --out CPH_variants_maf01
if we don't filter MAF, the LDmatrix will generate some "nan" for rare alleles, while will cause error when running PRScs software 
