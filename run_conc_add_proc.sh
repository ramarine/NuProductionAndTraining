#!/bin/bash

usage() {
  echo ""
  echo "Usage: $0 -i INFILE_DIR -o OUT_NAME"
  echo "Example: sbatch --account=def-nilic $0 -i /scratch/amarinei/data/Atmospherics/TauCC_1_50/hdf5_reco1 -o concatenated"
  echo ""
  exit 1
}

# Exit if no arguments provided
if [ $# -eq 0 ]; then
  usage
fi

# Parse command line options
while getopts ":i:o:h" opt; do
  case $opt in
    i) INFILE_DIR="$OPTARG" ;;
    o) OUT_NAME="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Check for required options
if [ -z "$INFILE_DIR" ] || [ -z "$OUT_NAME" ]; then
  echo "Error: Missing required arguments."
  usage
fi

# Directories and user info
USERNAME="amarinei"
LOG_DIR="${INFILE_DIR}/logs_proc"
mkdir -p "$LOG_DIR"

# Common SLURM options
COMMON_OPTS="--account=def-nilic --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"

STEP1_OPTS="--time=0:30:00 --mem=3G --nodes=1 --ntasks=32 $COMMON_OPTS"
STEP2_OPTS="--time=1:30:00 --mem=3G $COMMON_OPTS"
STEP3_OPTS="--time=1:30:00 --mem=3G --nodes=1 --ntasks=32 $COMMON_OPTS"

# Submit job 1
job1=$(sbatch $STEP1_OPTS --output=${LOG_DIR}/ph5_concat_%j.out --error=${LOG_DIR}/ph5_concat_%j.err ./combine_hdf5.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# Submit job 2, dependent on step 1
job2=$(sbatch $STEP2_OPTS --dependency=afterok:$job1 --output=${LOG_DIR}/add_key_%j.out --error=${LOG_DIR}/add_key_%j.err ./add_key.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# Submit job 3, dependent on step 2
job3=$(sbatch $STEP3_OPTS --dependency=afterok:$job2 --output=${LOG_DIR}/process_%j.out --error=${LOG_DIR}/process_%j.err ./process_hdf5.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# Submit job 4, dependent on step 3
job4=$(sbatch $STEP3_OPTS --dependency=afterok:$job3 --output=${LOG_DIR}/process_%j.out --error=${LOG_DIR}/process_%j.err ./merge.sh "$INFILE_DIR" "$OUT_NAME" | awk '{print $4}')
