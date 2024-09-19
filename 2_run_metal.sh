#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=1

### run metal software

metal metal.txt

### choose overlapped loci in the two studies

more METAANALYSIS2.TBL |awk '{if($11 !~ /?/){print $0}}' > METAANALYSIS2.both_have.TBL