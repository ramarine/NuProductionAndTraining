#! /bin/bash

#SBATCH --time=0:30:00
#SBATCH --account=def-nilic
#SBATCH --mail-user=robert.mihai.amarinei@cern.ch
#SBATCH --mail-type=ALL
#SBATCH --mem=20G

module load StdEnv/2020
module load apptainer/1.1.8
source /home/amarinei/Software/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

# FILENAME=$1
INFILE_DIR="/scratch/amarinei/data/Atmospherics/TauCC_10/hdf5"
OUT_NAME="10f_10e"
FILENAME=${OUT_NAME}


PATH_TO_NUML="/project/6079563/neutrino_ml/Numl_Image/numl:v23.11.0.sif"
USERNAME="amarinei"

echo "Running add_key ..."

singularity exec --bind /scratch/${USERNAME} ${PATH_TO_NUML} add_key -c -f -r detector_table -k event_table/event_id ${INFILE_DIR}/${FILENAME}.gnn.h5


echo "DONE" 
