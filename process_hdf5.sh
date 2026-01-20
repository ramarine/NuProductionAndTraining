#! /bin/bash

module load StdEnv/2020
module load apptainer/1.1.8
source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

USERNAME="amarinei"
PATH_TO_IMAGE_FILE="/project/6079563/neutrino_ml/Numl_Image"
# PATH_TO_NUGRAPH="/project/6071458/neutrino_ml/LArSoft_v09_83_01d00/srcs/numl"
PATH_TO_NUGRAPH="/project/6071458/neutrino_ml"

APPTAINERENV_PYTHONPATH=/project/6071458/neutrino_ml/nugraph/nugraph:/project/6071458/neutrino_ml/nugraph/pynuml
export APPTAINERENV_PYTHONPATH
export APPTAINERENV_NUGRAPH_DIR=/project/6071458/neutrino_ml/nugraph

INFILE_DIR=$1
OUT_NAME=$2
OUT_DIR="${INFILE_DIR}/hdf5_proc"
FILENAME=${OUT_NAME}
INPUT_FILE_PATH="${INFILE_DIR}/${FILENAME}"
# singularity shell --cleanenv --bind /project/6079563 --bind /project/6071458 --bind /scratch/${USERNAME} ${PATH_TO_IMAGE_FILE}/numl:v23.11.0.sif

echo "Started process_hdf5.sh | Processing File: ${INPUT_FILE_PATH}.gnn.h5"

if [[ ! -d "$OUT_DIR" ]]; then
    mkdir -p "$OUT_DIR"
    echo "Created directory: $OUT_DIR"
else
    echo "Directory already exists: $OUT_DIR"
fi
OUTPUT_FILE_PATH="${OUT_DIR}/${FILENAME}"

echo "singularity exec --cleanenv --bind /project/6079563 --bind /project/6071458 --bind /scratch/${USERNAME} ${PATH_TO_IMAGE_FILE}/numl:v23.11.0.sif python ${PATH_TO_NUGRAPH}/nugraph/scripts/process.py -i ${INPUT_FILE_PATH}.gnn.h5 -o ${OUTPUT_FILE_PATH}_processed"
singularity exec --cleanenv --bind /project/6079563 --bind /project/6071458 --bind /scratch/${USERNAME} ${PATH_TO_IMAGE_FILE}/numl:v23.11.0.sif python ${PATH_TO_NUGRAPH}/nugraph/scripts/process.py -i ${INPUT_FILE_PATH}.gnn.h5 -o ${OUTPUT_FILE_PATH}_processed