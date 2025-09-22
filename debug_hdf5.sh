#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts
NUM_EVENTS=1
DATA_DIR="/scratch/amarinei/data/Atmospherics/TauCC_new"
FCL_FILE_NAME="prodgenie_atmnTauCC_max_weighted_dune10kt_1x2x6"


sbatch run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME
