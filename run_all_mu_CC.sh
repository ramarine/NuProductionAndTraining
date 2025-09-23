#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts
NUM_EVENTS=250
NUM_FILES=1000
MEMORY=35
DATA_DIR="/scratch/amarinei/data/Atmospherics/MuCC_$NUM_EVENTS"
LOG_DIR="$DATA_DIR/logs"
FCL_FILE_NAME="prodgenie_atmnMuCC_max_weighted_dune10kt_1x2x6"

mkdir -p "$DATA_DIR" "$LOG_DIR"

COMMON_SBATCH_OPTS="--account=def-nilic --time=0:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"
DETSIM_SBATCH_OPTS="--account=def-nilic --time=0:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"

job1=$(sbatch $COMMON_SBATCH_OPTS -J mu_gen_events --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_gen_events.sh $NUM_EVENTS $FCL_FILE_NAME "$DATA_DIR" | awk '{print $4}')
job2=$(sbatch $COMMON_SBATCH_OPTS -J mu_g4 --dependency=afterok:$job1 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_g4.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job3=$(sbatch $DETSIM_SBATCH_OPTS -J mu_detsim --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_detsim.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job4=$(sbatch $COMMON_SBATCH_OPTS -J mu_reco --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job5=$(sbatch $COMMON_SBATCH_OPTS -J mu_makehdf5 --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')

# Optional: Wait for final job to complete before querying
# while squeue -j $job5 > /dev/null 2>&1; do sleep 10; done

# Retrieve and log timing info for all jobs after completion
# sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log
job6=$(sbatch --dependency=afterok:$job5 --output=$LOG_DIR/jobtime_%j.out --error=$LOG_DIR/jobtime_%j.err --wrap="sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log && cat $LOG_DIR/job_times.log" | awk '{print $4}')

# Print the timing log to terminal
cat $LOG_DIR/job_times.log