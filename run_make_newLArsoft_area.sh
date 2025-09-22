#!/bin/bash

#SBATCH --array=1
#SBATCH --account=def-nilic
#SBATCH --time=02:30:00
#SBATCH --mem=6G
#SBATCH --mail-user=robert.mihai.amarinei@cern.ch
#SBATCH --mail-type=ALL


module load StdEnv/2020
module load apptainer/1.1.8
# source /project/6079563/neutrino_ml/LArSoft_scripts/setup_LArSoft_area_cc.sh /project/6071458/neutrino_ml/LArSoft_v09_83_01d00
source /home/amarinei/Software/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

USERNAME='amarinei'

singularity exec  --bind /home/$USERNAME,/scratch/$USERNAME,/cvmfs,/project/6071458 /project/6071458/neutrino_ml/trjsl7 `pwd`/make_newLArSoft_area.sh /home/amarinei/Software/LArSoft_v10_09_00d00