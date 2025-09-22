#!/bin/bash

IN_FILE_PATH=$3
OUT_DIR="$3/hdf5"
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

if [[ ! -d "$OUT_DIR" ]]; then
    mkdir -p "$OUT_DIR"
    echo "Created directory: $OUT_DIR"
else
    echo "Directory already exists: $OUT_DIR"
fi

cd ${OUT_DIR}
lar -c hdf5maker_dune.fcl -s ${IN_FILE_PATH}/reco/${FCL_FILE_NAME}_${NUM_EVENTS}evts_gen_g4_detsim_reco_${RUN_NUM}.root