#! /bin/bash

#SBATCH --time=48:00:00
#SBATCH --account=def-nilic
#SBATCH --mail-user=william.dallaway@mail.utoronto.ca
#SBATCH --mail-type=ALL
#SBATCH --mem 5G


# Paths for files
USERNAME="willy99"
PATH_TO_IMAGE_FILE="/home/${USERNAME}/projects/rpp-nilic/neutrino_ml/Numl_Image"
PATH_TO_NUGRAPH="/home/${USERNAME}/numl"
filename=${1%.h5}


echo "Combining Processed Files ..."
singularity exec --bind /project/6079563 --bind /scratch/${USERNAME} ${PATH_TO_IMAGE_FILE}/numl:v23.11.0.sif python ${PATH_TO_NUGRAPH}/NuGraph/scripts/merge.py -f /scratch/${USERNAME}/${filename}_processed

echo "Done"
