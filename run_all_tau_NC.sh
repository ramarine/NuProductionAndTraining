#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts
NUM_EVENTS=1000
DATA_DIR="/scratch/amarinei/data/Atmospherics/TauNC"
FCL_FILE_NAME="prodgenie_atmnutauNC_max_dune10kt_1x2x6"


# Submit the first job and capture its job ID
# job1=$(sbatch run_gen_events.sh $NUM_EVENTS "$FCL_FILE_NAME" "$DATA_DIR" | awk '{print $4}')

# Submit the second job dependent on the first job finishing successfully
# job2=$(sbatch --dependency=afterok:$job1 run_g4.sh $NUM_EVENTS "$DATA_DIR" "$FCL_FILE_NAME" | awk '{print $4}')

# Submit the third job dependent on the second
job3=$(sbatch run_detsim.sh $NUM_EVENTS "$DATA_DIR" "$FCL_FILE_NAME" | awk '{print $4}')

# Submit the fourth job dependent on the third
job4=$(sbatch --dependency=afterok:$job3 run_reco.sh $NUM_EVENTS "$DATA_DIR" "$FCL_FILE_NAME" | awk '{print $4}')

# Submit the fifth job dependent on the fourth
sbatch --dependency=afterok:$job4 run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" "$FCL_FILE_NAME"