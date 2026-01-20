#!/bin/bash

usage() {
  echo ""
  echo "Usage: sbatch [SLURM_OPTS] $0 -o OUTPUT_NAME -v VERSION -i INFILE_DIR -n INPUT_NAME -e EPOCHS"
  echo "Example: $0 -o test -v CC -i /scratch/amarinei/data/Atmospherics/e_mu_tau_CC_output/hdf5_proc -n concatenated_processed -e 10"
  echo ""
  echo "Options:"
  echo "  -o OUTPUT_NAME   Output name"
  echo "  -v VERSION       Version"
  echo "  -i INFILE_DIR    Input directory"
  echo "  -n INPUT_NAME    Input file name"
  echo "  -e EPOCHS        Number of epochs"
  echo "  -h               Show this help message"
  echo ""
  exit 1
}

# Exit if no arguments provided
if [ $# -eq 0 ]; then
  usage
fi

# Parse command line options
while getopts ":i:o:n:v:e:h" opt; do
  case $opt in
    i) INFILE_DIR="$OPTARG" ;;
    o) OUTPUT_NAME="$OPTARG" ;;
    n) INPUT_NAME="$OPTARG" ;;
    v) VERSION="$OPTARG" ;;
    e) EPOCHS="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Validation
if [ -z "${INFILE_DIR:-}" ] || [ -z "${OUTPUT_NAME:-}" ] || [ -z "${INPUT_NAME:-}" ] || [ -z "${VERSION:-}" ] || [ -z "${EPOCHS:-}" ]; then
  echo "Error: Missing required arguments."
  usage
fi

echo "Training configuration:"
echo "  Output name: $OUTPUT_NAME"
echo "  Version:     $VERSION"
echo "  Data dir:    $INFILE_DIR"
echo "  Input name:  $INPUT_NAME"
echo "  Epochs:      $EPOCHS"

OUTFILE_DIR=${INFILE_DIR}
USERNAME="amarinei"
mkdir -p "$OUTFILE_DIR"
LOG_DIR="${OUTFILE_DIR}/logs_train"
mkdir -p "$LOG_DIR"

# Common SLURM options
COMMON_OPTS="--account=def-nilic"
TRAIN_OPTS="--time=1:30:00 --mem=32G --gpus=nvidia_h100_80gb_hbm3_1g.10gb:1 $COMMON_OPTS"

# Submit training job
job_id=$(sbatch $TRAIN_OPTS --output=${LOG_DIR}/train_%j.out --error=${LOG_DIR}/train_%j.err ./test_train.sh "$OUTPUT_NAME" "$VERSION" "$INFILE_DIR" "$INPUT_NAME" "$EPOCHS" "$LOG_DIR" | awk '{print $4}')

echo "Submitted training job: $job_id"
