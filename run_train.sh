#! /bin/bash

#SBATCH --time=6-00:00:00
#SBATCH --account=def-nilic
#SBATCH --mail-type=ALL
#SBATCH --mem=60G
#SBATCH --gpus-per-node=h100:1

USERNAME="amarinei"
module load StdEnv/2020
module load apptainer/1.1.8

# export APPTAINERENV_PYTHONPATH="/home/willy99/numl/nugraph/nugraph:/home/willy99/numl/nugraph/pynuml"
# export APPTAINERENV_NUGRAPH_DIR="/home/willy99/numl/nugraph/nugraph"
# export APPTAINERENV_NUGRAPH_DATA="/project/6079563/MCprod_new/training_hdf5"
# export APPTAINERENV_NUGRAPH_LOG="/scratch/willy99/logs_willy99"
# export APPTAINERENV_REQUESTS_CA_BUNDLE="/opt/numl/lib/python3.10/site-packages/certifi/cacert.pem"

export APPTAINERENV_PYTHONPATH=/project/6071458/neutrino_ml/nugraph/nugraph:/project/6071458/neutrino_ml/nugraph/pynuml
export APPTAINERENV_NUGRAPH_DIR=/project/6071458/neutrino_ml/nugraph
export APPTAINERENV_NUGRAPH_DATA=${INFILE_DIR}
export APPTAINERENV_NUGRAPH_LOG="/scratch/willy99/logs_willy99"
export APPTAINERENV_REQUESTS_CA_BUNDLE="/opt/numl/lib/python3.10/site-packages/certifi/cacert.pem"


singularity  exec --bind /project/6079563 --bind /scratch/${USERNAME} --nv /scratch/willy99/nugraph/numl_h100.sif python /home/$USERNAME/numl/nugraph/scripts/train.py --name $1 --version $2 --data-path $3 --batch-size 64 --event --semantic --epochs $4 --device 0 --in-feats 9
