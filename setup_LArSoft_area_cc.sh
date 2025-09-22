#! /bin/bash


#
#
# This is a script for setting up a new LArSoft area on compute canada. Some important notes are below:
#
#
# To run the script make sure you request an interactive job by doing the following from your scratch area
#
# salloc --time=2:00:00 --account=def-nilic --mem=8G
#
# Now open up the container using the following
#
# module load StdEnv/2020
# module load apptainer/1.1.8
# apptainer shell --bind /home/<your_username>,/cvmfs,/scratch/<your_username>,/project/6071458 -C --cleanenv /project/6071458/neutrino_ml/trjsl7
#
# Now you can run the script ... make sure to update the dunesw version and the qualifiers if needed. You run the script using the following
#
# ./setup_LArSoft_area_cc.sh <path/to/LArSoft/Installation/to/setup>
#


# DUNESW versions and username change these to fit your uses
DUNE_VERSION=v10_09_00d00
QUALS=e26:prof
# ^^^

# Don't touch these parts will setup the dunesw for running
export LANG="C"
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
source $1/localProducts_larsoft__*/setup
setup dunesw ${DUNE_VERSION} -q ${QUALS}
mrbslp
#^^^
