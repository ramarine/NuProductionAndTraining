#! /bin/bash

module load StdEnv/2020
module load apptainer/1.1.8
# source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

USERNAME="amarinei"
#PATH_TO_IMAGE_FILE="/home/${USERNAME}/projects/rpp-nilic/neutrino_ml/Numl_Image"

PATH_TO_IMAGE_FILE="/project/6071458/neutrino_ml"
PATH_TO_NUGRAPH="/project/6071458/neutrino_ml/nugraph"
#filename=${1%.h5}
INFILE_DIR=$1
OUT_NAME=$2

APPTAINERENV_PYTHONPATH=/project/6071458/neutrino_ml/nugraph/nugraph:/project/6071458/neutrino_ml/nugraph/pynuml
export APPTAINERENV_PYTHONPATH
export APPTAINERENV_NUGRAPH_DIR=/project/6071458/neutrino_ml/nugraph
export APPTAINERENV_NUGRAPH_DATA=${INFILE_DIR}

echo "Running merge..."
echo "singularity exec --bind /project/6071458 --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_IMAGE_FILE}/numl_h100.sif python ${PATH_TO_NUGRAPH}/scripts/merge.py -f ${INFILE_DIR}/hdf5_proc/${OUT_NAME}_processed"
singularity exec --bind /project/6071458 --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_IMAGE_FILE}/numl_h100.sif python ${PATH_TO_NUGRAPH}/scripts/merge.py -f ${INFILE_DIR}/hdf5_proc/${OUT_NAME}_processed

echo "Done"