cd /scratch
module load StdEnv/2020
module load apptainer/1.1.8

apptainer shell  --bind /home/amarinei,/cvmfs,/scratch/amarinei,/project/6071458,/tmp/.X11-unix:/tmp/.X11-unix,$HOME/.Xauthority:$HOME/.Xauthority --ipc --pid /cvmfs/singularity.opensciencegrid.org/fermilab/fnal-dev-sl7:latest

source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

lar -n 1 -c evd_dune10kt_1x2x6.fcl /scratch/amarinei/ROI/reco_sigproc_b8_bkg_noroi.root

lar -n 1 -c evd_dune10kt_1x2x6.fcl /scratch/amarinei/data/Atmospherics/TauCC_1_1/reco/prodgenie_atmnTauCC_max_weighted_dune10kt_1x2x6_1evts_gen_g4_detsim_reco_001.root

lar -n 1 -c evd_dune10kt_1x2x6.fcl /scratch/amarinei/data/Atmospherics/TauCC_10_1/reco/prodgenie_atmnTauCC_max_weighted_dune10kt_1x2x6_10evts_gen_g4_detsim_reco_001.root