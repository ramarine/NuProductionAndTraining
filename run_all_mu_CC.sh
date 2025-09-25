#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts
NUM_EVENTS=250
NUM_FILES=1000
MEMORY=35
DATA_DIR="/scratch/amarinei/data/Atmospherics/MuCC_${NUM_EVENTS}_${NUM_FILES}"
LOG_DIR="$DATA_DIR/logs"
GENERAL_LOG_DIR="$LOG_DIR/general"
FCL_FILE_NAME="prodgenie_atmnMuCC_max_weighted_dune10kt_1x2x6"

mkdir -p "$DATA_DIR" "$LOG_DIR" "$GENERAL_LOG_DIR"

LOG_SBATCH_OPTS="--account=def-nilic --time=0:35:00 --mem=1G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"
COMMON_SBATCH_OPTS="--account=def-nilic --time=20:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"
DETSIM_SBATCH_OPTS="--account=def-nilic --time=20:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"

# General log (start)
echo "Run started at $(date)" >> "$GENERAL_LOG_DIR/general.log"
echo "Working directory: $(pwd)" >> "$GENERAL_LOG_DIR/general.log"
echo "Data directory: $DATA_DIR" >> "$GENERAL_LOG_DIR/general.log"
echo "Log directory: $LOG_DIR" >> "$GENERAL_LOG_DIR/general.log"


job1=$(sbatch $COMMON_SBATCH_OPTS -J mu_gen_events --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_gen_events.sh $NUM_EVENTS $FCL_FILE_NAME "$DATA_DIR" | awk '{print $4}')
job2=$(sbatch $COMMON_SBATCH_OPTS -J mu_g4 --dependency=afterok:$job1 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_g4.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job2_a=$(sbatch $LOG_SBATCH_OPTS -J mu_del_gen_events --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_gen_events.sh "$DATA_DIR" | awk '{print $4}')
job3=$(sbatch $DETSIM_SBATCH_OPTS -J mu_detsim --dependency=afterok:$job2_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_detsim.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job3_a=$(sbatch $LOG_SBATCH_OPTS -J mu_del_g4 --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_g4.sh "$DATA_DIR" | awk '{print $4}')
job4=$(sbatch $COMMON_SBATCH_OPTS -J mu_reco --dependency=afterok:$job3_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job4_a=$(sbatch $LOG_SBATCH_OPTS -J mu_del_detsim --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_detsim.sh "$DATA_DIR" | awk '{print $4}')
job5=$(sbatch $COMMON_SBATCH_OPTS -J mu_makehdf5 --dependency=afterok:$job4_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')



# Retrieve and log timing info for all jobs after completion
# sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log
job6=$(sbatch $LOG_SBATCH_OPTS --dependency=afterany:$job5 --output=$LOG_DIR/jobtime_%j.out --error=$LOG_DIR/jobtime_%j.err --wrap="sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log && cat $LOG_DIR/job_times.log" | awk '{print $4}')


