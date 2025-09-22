#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts
NUM_EVENTS=5
DATA_DIR="/scratch/amarinei/data/Atmospherics/TauCC_5"
LOG_DIR="$DATA_DIR/logs"
FCL_FILE_NAME="prodgenie_atmnECC_max_weighted_dune10kt_1x2x6"

mkdir -p "$DATA_DIR" "$LOG_DIR"

COMMON_SBATCH_OPTS="--account=def-nilic --time=0:30:00 --mem=20G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=ALL --array=1-5"

job1=$(sbatch $COMMON_SBATCH_OPTS -J mu_gen_events --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_gen_events.sh $NUM_EVENTS $FCL_FILE_NAME "$DATA_DIR" | awk '{print $4}')
job2=$(sbatch $COMMON_SBATCH_OPTS -J mu_g4 --dependency=afterok:$job1 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_g4.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job3=$(sbatch $COMMON_SBATCH_OPTS -J mu_detsim --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_detsim.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job4=$(sbatch $COMMON_SBATCH_OPTS -J mu_reco --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
sbatch $COMMON_SBATCH_OPTS -J mu_makehdf5 --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME
