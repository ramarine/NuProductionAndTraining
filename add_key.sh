#! /bin/bash

module load StdEnv/2020
module load apptainer/1.1.8
# source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

INFILE_DIR=$1
OUT_NAME=$2

PATH_TO_NUML="/project/6079563/neutrino_ml/Numl_Image/numl:v23.11.0.sif"
USERNAME="amarinei"

echo "Running add_key ..."
echo "singularity exec --bind /scratch/${USERNAME} ${PATH_TO_NUML} add_key -c -f -r detector_table -k event_table/event_id ${INFILE_DIR}/${OUT_NAME}.gnn.h5"
singularity exec --bind /scratch/${USERNAME} ${PATH_TO_NUML} add_key -c -f -r detector_table -k event_table/event_id ${INFILE_DIR}/${OUT_NAME}.gnn.h5


echo "DONE" 
