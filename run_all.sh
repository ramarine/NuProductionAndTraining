#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts

PARTICLE_TYPE=$1
INTERACTION_TYPE=$2
NUM_EVENTS=10
NUM_FILES=10
MEMORY=6

if [ "$PARTICLE_TYPE" == "--help" ]; then
  echo ""
  echo "Usage: ./run_all.sh [PARTICLE_TYPE] [INTERACTION_TYPE]"
  echo "Try:   ./run_all.sh tau CC"
  echo ""
  echo "------------------------------------------------------"
  echo "  Available PARTICLE_TYPE values:"
  echo "    tau      for Tau particles"
  echo "    mu       for Muon particles"
  echo "    e        for Electron particles"
  echo "  Available INTERACTION_TYPE values:"
  echo "    CC      for CC interactions"
  echo ""
  exit 0
fi

if [ $PARTICLE_TYPE == "tau" ]; then
    DATA_DIR="/scratch/amarinei/data/Atmospherics/Tau"${INTERACTION_TYPE}"_${NUM_EVENTS}_${NUM_FILES}"
    FCL_FILE_NAME="prodgenie_atmnTauCC_max_weighted_dune10kt_1x2x6"
elif [ $PARTICLE_TYPE == "e" ]; then
    DATA_DIR="/scratch/amarinei/data/Atmospherics/E"${INTERACTION_TYPE}"_${NUM_EVENTS}_${NUM_FILES}"
    FCL_FILE_NAME="prodgenie_atmnECC_max_weighted_dune10kt_1x2x6"
elif [ $PARTICLE_TYPE == "mu" ]; then
    DATA_DIR="/scratch/amarinei/data/Atmospherics/Mu"${INTERACTION_TYPE}"_${NUM_EVENTS}_${NUM_FILES}"
    FCL_FILE_NAME="prodgenie_atmnMuCC_max_weighted_dune10kt_1x2x6"
fi

LOG_DIR="$DATA_DIR/logs"
GENERAL_LOG_DIR="$LOG_DIR/general"


mkdir -p "$DATA_DIR" "$LOG_DIR" "$GENERAL_LOG_DIR"

LOG_SBATCH_OPTS="--account=def-nilic --time=0:35:00 --mem=1G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"
COMMON_SBATCH_OPTS="--account=def-nilic --time=1:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"
DETSIM_SBATCH_OPTS="--account=def-nilic --time=1:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL --array=1-$NUM_FILES"

# General log (start)
echo "Run started at $(date)" >> "$GENERAL_LOG_DIR/general.log"
echo "Working directory: $(pwd)" >> "$GENERAL_LOG_DIR/general.log"
echo "Data directory: $DATA_DIR" >> "$GENERAL_LOG_DIR/general.log"
echo "Log directory: $LOG_DIR" >> "$GENERAL_LOG_DIR/general.log"


job1=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_gen_events --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_gen_events.sh $NUM_EVENTS $FCL_FILE_NAME "$DATA_DIR" | awk '{print $4}')
job2=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_g4 --dependency=afterok:$job1 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_g4.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job2_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_gen_events --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_gen_events.sh "$DATA_DIR" | awk '{print $4}')
job3=$(sbatch $DETSIM_SBATCH_OPTS -J ${PARTICLE_TYPE}_detsim --dependency=afterok:$job2_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_detsim.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job3_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_g4 --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_g4.sh "$DATA_DIR" | awk '{print $4}')
job4=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_reco --dependency=afterok:$job3_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job4_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_detsim --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_detsim.sh "$DATA_DIR" | awk '{print $4}')
job5=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_makehdf5 --dependency=afterok:$job4_a --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')



# Retrieve and log timing info for all jobs after completion
# sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log
job6=$(sbatch $LOG_SBATCH_OPTS --dependency=afterany:$job5 --output=$LOG_DIR/jobtime_%j.out --error=$LOG_DIR/jobtime_%j.err --wrap="sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS > $LOG_DIR/job_times.log && cat $LOG_DIR/job_times.log" | awk '{print $4}')


