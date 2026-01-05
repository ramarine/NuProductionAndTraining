
NUM_EVENTS=$1
NUM_FILES=$2

echo "eCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/eCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "muCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/muCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "tauCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/tauCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "e_barCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/e_barCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "mu_barCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/mu_barCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "tau_barCC"
ls -ltrhh /scratch/amarinei/data/Atmospherics/tau_barCC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
echo "eNCC"
ls -ltrh /scratch/amarinei/data/Atmospherics/eNC_"${NUM_EVENTS}"_"${NUM_FILES}"/hdf5_reco1/hdf5_proc/concatenate_processed
