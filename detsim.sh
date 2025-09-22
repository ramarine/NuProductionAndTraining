#!/bin/bash

NUM_EVENTS=$1
RUN_NUM=$2
IN_FILE_PATH=$3
OUT_DIR="$3/detsim"
FCL_FILE_NAME=$4
DUNE_VERSION=v10_09_00d00
QUALS=e26:prof

### To run Will's verson of LArSoft comment out the line below and uncomment
cd /home/amarinei/Software/LArSoft_v10_09_00d00
####
# cd /project/6071458/neutrino_ml/LArSoft_v09_83_01d00

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source localProducts_larsoft__e26_prof/setup
setup dunesw ${DUNE_VERSION} -q ${QUALS}
mrbslp

if [[ ! -d "$OUT_DIR" ]]; then
    mkdir -p "$OUT_DIR"
    echo "Created directory: $OUT_DIR"
else
    echo "Directory already exists: $OUT_DIR"
fi

lar -c standard_detsim_dune10kt_1x2x6.fcl -s ${IN_FILE_PATH}/g4/${FCL_FILE_NAME}_${NUM_EVENTS}evts_gen_g4_${RUN_NUM}.root -n ${NUM_EVENTS} -o ${OUT_DIR}/${FCL_FILE_NAME}_${NUM_EVENTS}evts_gen_g4_detsim_${RUN_NUM}.root -e ${RUN_NUM}:0:1
 

