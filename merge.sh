#! /bin/bash

#SBATCH --time=01:30:00
#SBATCH --account=def-nilic
#SBATCH --mail-user=robert.mihai.amarinei@cern.ch
#SBATCH --mail-type=ALL
#SBATCH --mem=20G
#SBATCH --nodes=1
#SBATCH --ntasks=32
# Paths for files


# Paths for files
USERNAME="amarinei"
PATH_TO_IMAGE_FILE="/home/${USERNAME}/projects/rpp-nilic/neutrino_ml/Numl_Image"
PATH_TO_NUGRAPH="/home/${USERNAME}/numl"
filename=${1%.h5}


echo "Combining Processed Files ..."
singularity exec --bind /project/6079563 --bind /scratch/${USERNAME} ${PATH_TO_IMAGE_FILE}/numl:v23.11.0.sif python ${PATH_TO_NUGRAPH}/NuGraph/scripts/merge.py -f /scratch/${USERNAME}/${filename}_processed

echo "Done"
