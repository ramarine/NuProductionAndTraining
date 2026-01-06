#!/bin/bash

usage() {
  echo ""
  echo "Usage: $0 -i INFILE_DIR [-i INFILE_DIR ...] -o OUT_NAME -n OUT_NAME"
  echo "Example: sbatch --account=def-nilic $0 -i /scratch/amarinei/data/Atmospherics/TauCC_1_50/hdf5_reco1 -i /scratch/amarinei/data/Atmospherics/TauCC_1_50/hdf5_reco2 -n concatenated -o /scratch/amarinei/data/Atmospherics/TauCC_1_50/output"
  echo ""
  echo "Options:"
  echo "  -i INFILE_DIR    Input directory (can be specified multiple times)"
  echo "  -n OUT_NAME      Output name"
  echo "  -o OUTFILE_DIR   Output directory"
  echo "  -h               Show this help message"
  echo ""
  exit 1
}

# Exit if no arguments provided
if [ $# -eq 0 ]; then
  usage
fi

# Initialize array for input directories
INFILE_DIRS=()

# Parse command line options
while getopts ":i:o:n:h" opt; do
  case $opt in
    i) INFILE_DIRS+=("$OPTARG") ;;
    n) OUT_NAME="$OPTARG" ;;
    o) OUTFILE_DIR="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Validation
if [ ${#INFILE_DIRS[@]} -eq 0 ] || [ -z "${OUT_NAME:-}" ] || [ -z "${OUTFILE_DIR:-}" ]; then
  echo "Error: Missing required arguments."
  usage
fi

echo "Processing ${#INFILE_DIRS[@]} input directories:"
for dir in "${INFILE_DIRS[@]}"; do
  echo "  - $dir"
done

# Directories and user info
USERNAME="amarinei"
mkdir -p "$OUTFILE_DIR"
LOG_DIR="${OUTFILE_DIR}/logs_proc"
mkdir -p "$LOG_DIR"

# Common SLURM options
COMMON_OPTS="--account=def-nilic --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"

STEP1_OPTS="--time=0:30:00 --mem=32G --nodes=1 --ntasks=32 $COMMON_OPTS"
STEP2_OPTS="--time=1:30:00 --mem=32G $COMMON_OPTS"
STEP3_OPTS="--time=1:30:00 --mem=32G --nodes=1 --ntasks=32 $COMMON_OPTS"

# Submit job 1 - pass all directories as arguments
job1=$(sbatch $STEP1_OPTS --output=${LOG_DIR}/combine_hdf5_%j.out --error=${LOG_DIR}/combine_hdf5_%j.err ./combine_hdf5.sh "${INFILE_DIRS[@]}" "$OUT_NAME" "$OUTFILE_DIR" | awk '{print $4}')

# Submit job 2, dependent on step 1
job2=$(sbatch $STEP2_OPTS --dependency=afterok:$job1 --output=${LOG_DIR}/add_key_%j.out --error=${LOG_DIR}/add_key_%j.err ./add_key.sh "$OUTFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# Submit job 3, dependent on step 2
job3=$(sbatch $STEP3_OPTS --dependency=afterok:$job2 --output=${LOG_DIR}/process_%j.out --error=${LOG_DIR}/process_%j.err ./process_hdf5.sh "$OUTFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# Submit job 4, dependent on step 3
job4=$(sbatch $STEP3_OPTS --dependency=afterok:$job3 --output=${LOG_DIR}/merge_%j.out --error=${LOG_DIR}/merge_%j.err ./merge.sh "$OUTFILE_DIR" "$OUT_NAME" | awk '{print $4}')

# echo ""
# echo "Jobs submitted:"
# echo "  Job 1 (combine_hdf5): $job1"
# echo "  Job 2 (add_key):      $job2"
# echo "  Job 3 (process):      $job3"
# echo "  Job 4 (merge):        $job4"
