#! /bin/bash

#SBATCH --time=1:30:00
#SBATCH --account=def-nilic
#SBATCH --mail-user=robert.mihai.amarinei@cern.ch
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --mem=20G
#SBATCH --ntasks=32

# path to files to concat = /scratch/amarinei/data/Atmospherics/TauCC_new/hdf5
# path to output 
# INFILE_DIR=$1 
# OUT_NAME=$2

module load StdEnv/2020
module load apptainer/1.1.8
# source /project/6079563/neutrino_ml/LArSoft_scripts/setup_LArSoft_area_cc.sh /project/6071458/neutrino_ml/LArSoft_v09_83_01d00
source /home/amarinei/Software/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

INFILE_DIR="/scratch/amarinei/data/Atmospherics/TauCC_10/hdf5"
OUT_NAME="10f_10e"

PATH_TO_NUML="/project/6079563/neutrino_ml/Numl_Image/numl:v23.11.0.sif"
USERNAME="amarinei"


for f in ${INFILE_DIR}/*.h5
do
	echo $f >> ${INFILE_DIR}/files_to_concat.txt
done

echo "Running ph5_concat ..."

singularity exec --cleanenv --bind ${INFILE_DIR}:/numl_data --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_NUML} mpiexec -n 9 ph5_concat -i ${INFILE_DIR}/files_to_concat.txt -o ${INFILE_DIR}/${OUT_NAME}.gnn.h5

echo "ph5_concat done"

rm  ${INFILE_DIR}/files_to_concat.txt
echo "Done" 


