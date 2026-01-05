#!/bin/bash

cd /scratch/amarinei/LArSoft_scripts


MEMORY=32

usage() {
  echo ""
  echo "Usage: $0 -p PARTICLE_TYPE -i INTERACTION_TYPE -e NUM_EVENTS -f NUM_FILES"
  echo "Example: sbatch --account=def-nilic $0 -p tau -i CC -e 1 -f 1"
  echo ""
  echo "Available PARTICLE_TYPE values:"
  echo "  tau      for Tau particles"
  echo "  mu       for Muon particles"
  echo "  e        for Electron particles"
  echo ""
  echo "Available INTERACTION_TYPE values:"
  echo "  CC       for CC interactions"
  echo ""
  exit 1
}

# Parse command line options
while getopts ":p:i:e:f:h" opt; do
  case $opt in
    p) PARTICLE_TYPE="$OPTARG" ;;
    i) INTERACTION_TYPE="$OPTARG" ;;
    e) NUM_EVENTS="$OPTARG" ;;
    f) NUM_FILES="$OPTARG" ;;
    h) usage ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
  esac
done

# Check for required options
if [ -z "$PARTICLE_TYPE" ] || [ -z "$INTERACTION_TYPE" ] || [ -z "$NUM_EVENTS" ] || [ -z "$NUM_FILES" ]; then
  echo "Error: Missing required arguments."
  usage
fi

DATA_DIR="/scratch/amarinei/data/Atmospherics/"${PARTICLE_TYPE}${INTERACTION_TYPE}"_${NUM_EVENTS}_${NUM_FILES}"
FCL_FILE_NAME="prodgenie_atmnu_max_weighted_randompolicy_dune10kt_"${PARTICLE_TYPE}"_"${INTERACTION_TYPE}

case "$PARTICLE_TYPE" in
    "e")     ARRAY_MIN=1 ;;
    "mu")       ARRAY_MIN=300 ;;
    "tau")      ARRAY_MIN=600 ;;
    "e_bar")   ARRAY_MIN=900 ;;
    "mu_bar") ARRAY_MIN=1200 ;;
    "tau_bar")  ARRAY_MIN=1500 ;;
    *)
        if [[ "$INTERACTION_TYPE" == "NC" ]]; then
            ARRAY_MIN=1800
        else
            echo "Error: Unknown particle type '$PARTICLE_TYPE'"
            exit 1
        fi
        ;;
esac

# Calculate ARRAY_MAX once (same for all cases)
ARRAY_MAX=$((ARRAY_MIN + NUM_FILES - 1))

LOG_DIR="$DATA_DIR/logs"
GENERAL_LOG_DIR="$LOG_DIR/general"

LOG_SBATCH_OPTS="--account=def-nilic --time=0:35:00 --mem=1G --mail-user=robert.mihai.amarinei@cern.ch --mail-type=BEGIN,END,FAIL"
COMMON_SBATCH_OPTS="--account=def-nilic --time=1:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --array=$ARRAY_MIN-$ARRAY_MAX"
DETSIM_SBATCH_OPTS="--account=def-nilic --time=1:30:00 --mem=${MEMORY}G --mail-user=robert.mihai.amarinei@cern.ch --array=$ARRAY_MIN-$ARRAY_MAX"


mkdir -p "$DATA_DIR" "$LOG_DIR" "$GENERAL_LOG_DIR"


# General log (start)
echo "Run started at $(date)" >> "$GENERAL_LOG_DIR/general.log"
echo "Working directory: $(pwd)" >> "$GENERAL_LOG_DIR/general.log"
echo "Data directory: $DATA_DIR" >> "$GENERAL_LOG_DIR/general.log"
echo "Log directory: $LOG_DIR" >> "$GENERAL_LOG_DIR/general.log"


# job1=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_gen_events --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_gen_events.sh $NUM_EVENTS $FCL_FILE_NAME "$DATA_DIR" | awk '{print $4}')
# job2=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_g4 --dependency=afterok:$job1 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_g4.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
# job2_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_gen_events --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_gen_events.sh "$DATA_DIR" | awk '{print $4}')
# job3=$(sbatch $DETSIM_SBATCH_OPTS -J ${PARTICLE_TYPE}_detsim --dependency=afterok:$job2 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_detsim.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
# job3_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_g4 --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_g4.sh "$DATA_DIR" | awk '{print $4}')
# job4=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_reco --dependency=afterok:$job3 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
# job4_a=$(sbatch $LOG_SBATCH_OPTS -J ${PARTICLE_TYPE}_del_detsim --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err delete_detsim.sh "$DATA_DIR" | awk '{print $4}')

# job5=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_reco2 --dependency=afterok:$job4 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_reco2.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}') 
# job6=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_makehdf5 --dependency=afterok:$job5 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')

# # Retrieve and log timing info for all jobs after completion
# job7=$(sbatch $LOG_SBATCH_OPTS --dependency=afterany:$job6 --output=$LOG_DIR/jobtime_%j.out --error=$LOG_DIR/jobtime_%j.err --wrap="sacct -j $job1,$job2,$job3,$job4,$job5 --format=JobID,JobName,Start,End,Elapsed,MaxRSS --noheader | grep -v '\+' > $LOG_DIR/job_times.log && cat $LOG_DIR/job_times.log" | awk '{print $4}')
# job8=$(sbatch $LOG_SBATCH_OPTS --dependency=afterok:$job7 --output=$LOG_DIR/clean_%j.out --error=$LOG_DIR/clean_%j.err --wrap="python3 explocode jo re_logs/clean_job_times.py $LOG_DIR job_times.log" | awk '{print $4}')

# job9=$(sbatch --account=def-nilic --dependency=afterok:$job8 run_conc_add_proc.sh -i ${DATA_DIR}/hdf5_reco1 -o concatenate | awk '{print $4}')


job6=$(sbatch $COMMON_SBATCH_OPTS -J ${PARTICLE_TYPE}_makehdf5 --output=$LOG_DIR/slurm-%x-%j.out --error=$LOG_DIR/slurm-%x-%j.err run_makehdf5.sh $NUM_EVENTS "$DATA_DIR" $FCL_FILE_NAME | awk '{print $4}')
job9=$(sbatch --dependency=afterok:$job6 --account=def-nilic run_conc_add_proc.sh -i ${DATA_DIR}/hdf5_reco1 -o concatenate | awk '{print $4}')

