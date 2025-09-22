#!/bin/bash




# This is a script for running the LArSoft event generator on cedar. The numbers in the sbatch array line are the run number and they should be unique for each event that will be processed so change it as nessisary the script can be run by the following way
# sbatch run_gen_events.sh <num_events_to_gen> <fcl_file_to_use_for_generation> <output_directory_for_files>

NUM_EVENTS=$1
RUN_NUM=${SLURM_ARRAY_TASK_ID}
FCL_FILE_NAME=$2
OUT_DIR=$3
USERNAME="amarinei" # Change this to your username


if [ ${RUN_NUM} -lt 10 ]
then
        RUN_NUM=0${RUN_NUM}

fi


if [ ${RUN_NUM} -lt 100 ]
then

        RUN_NUM=0${RUN_NUM}

fi

module load StdEnv/2020
module load apptainer/1.1.8
source /home/amarinei/Software/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

cd /scratch/$USERNAME/LArSoft_scripts
singularity exec  --bind /home/$USERNAME,/scratch/$USERNAME,/cvmfs,/project/6071458 /project/6071458/neutrino_ml/trjsl7  `pwd`/gen_events.sh ${NUM_EVENTS} ${RUN_NUM} ${FCL_FILE_NAME} ${OUT_DIR}

echo "DONE RUN ${RUN_NUM}"
