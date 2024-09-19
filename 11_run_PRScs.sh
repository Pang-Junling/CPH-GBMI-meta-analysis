#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -l p=10

PATH_TO_REFERENCE="path_to_ref/ldblk_1kg_chr"
VALIDATION_BIM_PREFIX="BCY_cohort_variants"
SUM_STATS_FILE="METAANALYSIS2.both_have.for_PRScs"
GWAS_SAMPLE_SIZE="1398050"

OUTPUT_DIR="./PRScs_auto"
N_THREADS="10"


export MKL_NUM_THREADS=$N_THREADS
export NUMEXPR_NUM_THREADS=$N_THREADS
export OMP_NUM_THREADS=$N_THREADS

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR 

####################
OUTPUT_DIR="./PRScs_phi_1e-6"
PARAM_PHI="1e-6"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI 

###########

OUTPUT_DIR="./PRScs_phi_1e-5"
PARAM_PHI="1e-5"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI 

############

OUTPUT_DIR="./PRScs_phi_1e-4"
PARAM_PHI="1e-4"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI

############

OUTPUT_DIR="./PRScs_phi_1e-3"
PARAM_PHI="1e-3"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI

##############

OUTPUT_DIR="./PRScs_phi_1e-2"
PARAM_PHI="1e-2"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI

##############
OUTPUT_DIR="./PRScs_phi_1e-1"
PARAM_PHI="1e-1"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI

###############
OUTPUT_DIR="./PRScs_phi_1"
PARAM_PHI="1"

python3 /data/wangj/software/PRS-CS/PRScs.py --ref_dir=$PATH_TO_REFERENCE \
--bim_prefix=$VALIDATION_BIM_PREFIX \
--sst_file=$SUM_STATS_FILE --n_gwas=$GWAS_SAMPLE_SIZE \
--out_dir=$OUTPUT_DIR \
--phi=$PARAM_PHI

