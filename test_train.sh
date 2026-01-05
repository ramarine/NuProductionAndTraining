#! /bin/bash

#SBATCH --time=6-00:00:00
#SBATCH --account=def-nilic
#SBATCH --mail-user=william.dallaway@mail.utoronto.ca
#SBATCH --mail-type=ALL
#SBATCH --mem=20G
#
# ONLY FOR TESTING USE THE MIG TO REDUCE GPU USED WHEN WE RUN TEST 
#SBATCH --gpus=nvidia_h100_80gb_hbm3_1g.10gb:1	
#orignal code here: code /project/6071458/neutrino_ml/test_train.sh 


USERNAME="amarinei"
module load apptainer/1.3.5

PATH_TO_IMAGE_FILE="/project/6071458/neutrino_ml"
PATH_TO_NUGRAPH="/project/6071458/neutrino_ml/nugraph"

#### RMA: CHANGE THESE EXPORTS TO WHERE YOUR FILES NEED TO BE EXCEPT THE LAST ONE 
export APPTAINERENV_PYTHONPATH=/project/6071458/neutrino_ml/nugraph/nugraph:/project/6071458/neutrino_ml/nugraph/pynuml
export APPTAINERENV_NUGRAPH_DIR=/project/6071458/neutrino_ml/nugraph
#this is the path which contains the h5_processed.h5 file. 
export APPTAINERENV_NUGRAPH_DATA=${INFILE_DIR}
export APPTAINERENV_NUGRAPH_LOG=""
export APPTAINERENV_REQUESTS_CA_BUNDLE="/opt/numl/lib/python3.10/site-packages/certifi/cacert.pem"

#### RMA: CHANGE PATHS AS REQUIRED, KEEP OFFLINE FLAG UNTIL WANDB IS SETUP  
singularity  exec --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_IMAGE_FILE}/numl_h100.sif python ${PATH_TO_NUGRAPH}/scripts/train.py --name $1 --version $2 --data-path $3 --batch-size 64 --event --semantic --epochs $4 --device 0 --in-feats 8 --offline 
