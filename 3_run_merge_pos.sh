#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=1

perl merge_pos.pl CPH_variants.bim METAANALYSIS2.both_have.TBL METAANALYSIS2.both_have.TBL.with_pos

############# modify the header name ##############
sed -i '1s/P-value/P/' METAANALYSIS2.both_have.TBL.with_pos
sed -i '1s/MarkerName/SNP/' METAANALYSIS2.both_have.TBL.with_pos
