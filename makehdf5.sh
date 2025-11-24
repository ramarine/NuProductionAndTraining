#!/bin/bash

IN_FILE_PATH=$3
OUT_DIR1="$3/hdf5/LL_reco"
OUT_DIR2="$3/hdf5/HL_reco"
RUN_NUM=$2
NUM_EVENTS=$1
FCL_FILE_NAME=$4
DUNE_VERSION=v10_09_00d00
QUALS=e26:prof


source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source /home/amarinei/Software/LArSoft_v10_09_00d00/localProducts_larsoft__*/setup
# source /project/6071458/neutrino_ml/LArSoft_v09_83_01d00/localProducts_larsoft__*/setup
setup dunesw ${DUNE_VERSION} -q ${QUALS}
mrbslp

if [[ ! -d "$OUT_DIR1" ]]; then
    mkdir -p "$OUT_DIR1"
    echo "Created directory: $OUT_DIR1"
else
    echo "Directory already exists: $OUT_DIR1"
fi

if [[ ! -d "$OUT_DIR2" ]]; then
    mkdir -p "$OUT_DIR2"
    echo "Created directory: $OUT_DIR2"
else
    echo "Directory already exists: $OUT_DIR2"
fi

cd ${OUT_DIR1}
lar -c hdf5maker_dune10kt.fcl -s ${IN_FILE_PATH}/reco/${FCL_FILE_NAME}_${NUM_EVENTS}evts_gen_g4_detsim_reco1_${RUN_NUM}.root
cd ${OUT_DIR2}
lar -c hdf5maker_dune10kt.fcl -s ${IN_FILE_PATH}/reco/${FCL_FILE_NAME}_${NUM_EVENTS}evts_gen_g4_detsim_reco2_${RUN_NUM}.root