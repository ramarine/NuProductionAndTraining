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
## apptainer shell --bind /home/amarinei,/cvmfs,/scratch/amarinei,/project/6071458 -C --cleanenv /project/6071458/neutrino_ml/trjsl7 
# Now you can run the script ... make sure to update the dunesw version and the qualifiers if needed. You run the script using the following 
#

# ./make_newLArSoft_area.sh <path/where/you/want/the/area/(problaby /home/your_username>)


# Change these fields to fit your needs
DUNE_VERSION=v10_09_00d00
NUML_VERSION=v09_83_01
QUALS=e26:prof
USERNAME="amarinei"
# ^^^^



# Don't touch these parts
#
export LANG="C"
export TMPDIR="/scratch/$USERNAME"


# mkdir /home/amarinei/Software/LArSoft_$DUNE_VERSION
cd /home/amarinei/Software/LArSoft_$DUNE_VERSION


source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh



# echo "*******************************************************"
# echo "mrb newDev -q $QUALS"
# echo "*******************************************************"
# mrb newDev -q $QUALS

# cd /home/amarinei/Software/LArSoft_$DUNE_VERSION
# echo "*******************************************************"
# echo "/home/amarinei/Software/LArSoft_$DUNE_VERSION/localProducts_larsoft__*/setup"
# echo "*******************************************************"
source /home/amarinei/Software/LArSoft_$DUNE_VERSION/localProducts_larsoft__*/setup

# cd /home/amarinei/Software/LArSoft_$DUNE_VERSION/srcs
# #
# # ^^^ 

# # Install the DUNESW code from github ... might need to use specific tags for Matthew's ROI.
# # 
# echo "*******************************************************"
# echo "mrb g -t $DUNE_VERSION dune_suite"
# echo "*******************************************************"
# mrb g -t $DUNE_VERSION dune_suite
# # echo "*******************************************************"
# # echo "mrb g -t $DUNE_VERSION dunesw"
# # echo "*******************************************************"
# # mrb g -t $DUNE_VERSION dunesw
# # echo "*******************************************************"

# # echo "mrb g -t $DUNE_VERSION dunesim"
# # echo "*******************************************************"
# # mrb g -t $DUNE_VERSION dunesim
# # mrb g -t $DUNE_VERSION duneana # installed
# # mrb g -t $DUNE_VERSION dunereco #installed

# echo "*******************************************************"
# echo "mrb g -t $NUML_VERSION https://github.com/nugraph/numl"
# echo "*******************************************************"
# mrb g https://github.com/nugraph/numl # If this gives an error message Will I might need to make a new tag of the repo for you 
# #
# # ^^^ 


# Don't touch this part builds all of the repositories 
#



echo "*******************************************************"
echo "cd $MRB_BUILDDIR"
echo "*******************************************************"
cd $MRB_BUILDDIR
echo "*******************************************************"
echo "mrbsetenv"
echo "*******************************************************"
mrbsetenv
#mrb z#do this in case it need a fresh rebuild
echo "*******************************************************"
echo "mrb i -j8"
echo "*******************************************************"
mrb i -j8
#
# ^^^ 



  





