#!/bin/bash

# Directories and user info
INFILE_DIR="/scratch/amarinei/data/Atmospherics/NC_10_10/hdf5"
OUT_NAME="10f_10e"
USERNAME="amarinei"
LOG_DIR="${INFILE_DIR}/logs"
mkdir -p "$LOG_DIR"

# Common SLURM options
COMMON_OPTS="--account=def-nilic --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"

# Concatenate sbatch options
STEP1_OPTS="--time=1:30:00 --mem=3G --nodes=1 --ntasks=32 $COMMON_OPTS"
# Add key sbatch options
STEP2_OPTS="--time=1:30:00 --mem=3G $COMMON_OPTS"
#  sbatch options
STEP3_OPTS="--time=1:30:00 --mem=3G --nodes=1 --ntasks=32 $COMMON_OPTS"

# echo "Submitting concatenation (combine_hdf5.sh) ..."
job1=$(sbatch $STEP1_OPTS --output=${LOG_DIR}/ph5_concat_%j.out --error=${LOG_DIR}/ph5_concat_%j.err ./combine_hdf5.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')
# echo "Concatenate job ID: $job1"

# echo "Submitting add_key, dependent on step 1 ..."
# job2=$(sbatch $STEP2_OPTS --dependency=afterok:$job1 --output=${LOG_DIR}/add_key_%j.out --error=${LOG_DIR}/add_key_%j.err ./add_key.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')
# echo "Add_key job ID: $job2"

# echo "Submitting process_hdf5.sh, dependent on step 2 ..."
# job3=$(sbatch $STEP3_OPTS --output=${LOG_DIR}/process_%j.out --error=${LOG_DIR}/process_%j.err ./process_hdf5.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')
# job3=$(sbatch $STEP3_OPTS --dependency=afterok:$job2 --output=${LOG_DIR}/process_%j.out --error=${LOG_DIR}/process_%j.err -- ./run_process.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')



