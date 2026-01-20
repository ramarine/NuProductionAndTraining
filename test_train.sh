#!/bin/bash

# Positional arguments
OUTPUT_NAME=$1
VERSION=$2
INFILE_DIR=$3
INPUT_NAME=$4
EPOCHS=$5
LOG_DIR=$6

# Validation
if [ -z "$OUTPUT_NAME" ] || [ -z "$VERSION" ] || [ -z "$INFILE_DIR" ] || [ -z "$INPUT_NAME" ] || [ -z "$EPOCHS" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: $0 OUTPUT_NAME VERSION INFILE_DIR INPUT_NAME EPOCHS"
  exit 1
fi

USERNAME="amarinei"
module load apptainer/1.3.5

PATH_TO_IMAGE_FILE="/project/6071458/neutrino_ml"
PATH_TO_NUGRAPH="/project/6071458/neutrino_ml/nugraph"

# Configure environment
export APPTAINERENV_PYTHONPATH=/project/6071458/neutrino_ml/nugraph/nugraph:/project/6071458/neutrino_ml/nugraph/pynuml
export APPTAINERENV_NUGRAPH_DIR=/project/6071458/neutrino_ml/nugraph
export APPTAINERENV_NUGRAPH_DATA=${INFILE_DIR}
export APPTAINERENV_NUGRAPH_LOG=${LOG_DIR}
export APPTAINERENV_REQUESTS_CA_BUNDLE="/opt/numl/lib/python3.10/site-packages/certifi/cacert.pem"

# Run training
apptainer exec --bind /project/6079563 --bind /project/6071458 --bind /scratch/${USERNAME} --nv ${PATH_TO_IMAGE_FILE}/numl_h100.sif python ${PATH_TO_NUGRAPH}/scripts/train.py --name ${OUTPUT_NAME} --version ${VERSION} --data-path ${INFILE_DIR}/${INPUT_NAME} --batch-size 64 --event --semantic --epochs ${EPOCHS} --device 0 --in-feats 8 --offline
