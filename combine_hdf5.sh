#! /bin/bash

###THIS SCRIPT WILL CONCATENATE HDF5 FILES FROM MULTIPLE DIRECTORIES

module load StdEnv/2020
module load apptainer/1.1.8
source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00

# Parse arguments: all directories are passed first, then OUT_NAME and OUTFILE_DIR
NUM_ARGS=$#

# Extract OUT_NAME and OUTFILE_DIR (last two arguments)
OUT_NAME="${@: -2:1}"
OUTFILE_DIR="${@: -1}"

# Build array of input directories (all but last two arguments)
INFILE_DIRS=("${@:1:$((NUM_ARGS-2))}")

PATH_TO_NUML="/project/6079563/neutrino_ml/Numl_Image/numl:v23.11.0.sif"
USERNAME="amarinei"

# Create temporary file list in output directory
CONCAT_LIST="${OUTFILE_DIR}/files_to_concat.txt"
> "$CONCAT_LIST"  # Clear file if it exists

echo "Collecting HDF5 files from ${#INFILE_DIRS[@]} directories:"

# Loop through all input directories and collect .h5 files
for INFILE_DIR in "${INFILE_DIRS[@]}"; do
  echo "  - Scanning: $INFILE_DIR"
  
  # Check if directory exists
  if [ ! -d "$INFILE_DIR" ]; then
    echo "Warning: Directory does not exist: $INFILE_DIR"
    continue
  fi
  
  # Count and add files from this directory
  file_count=0
  for f in "${INFILE_DIR}"/*.h5; do
    # Check if glob matched any files
    [ -e "$f" ] || continue
    echo "$f" >> "$CONCAT_LIST"
    ((file_count++))
  done
  
  echo "    Found $file_count files"
done

# Check if we found any files
total_files=$(wc -l < "$CONCAT_LIST")
if [ "$total_files" -eq 0 ]; then
  echo "Error: No HDF5 files found in any of the input directories"
  rm "$CONCAT_LIST"
  exit 1
fi

echo ""
echo "Total files to concatenate: $total_files"
echo "Output file: ${OUTFILE_DIR}/${OUT_NAME}.gnn.h5"
echo ""
echo "Running ph5_concat ..."

# Build bind mount arguments for all unique parent directories
BIND_ARGS=""
for INFILE_DIR in "${INFILE_DIRS[@]}"; do
  BIND_ARGS="${BIND_ARGS} --bind ${INFILE_DIR}:/numl_data_$(basename ${INFILE_DIR})"
done

[ -f "${OUTFILE_DIR}/${OUT_NAME}.gnn.h5" ] && rm "${OUTFILE_DIR}/${OUT_NAME}.gnn.h5"

echo "singularity exec --cleanenv ${BIND_ARGS} --bind ${OUTFILE_DIR}:/numl_output --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_NUML} mpiexec -n 32 ph5_concat -i ${CONCAT_LIST} -o ${OUTFILE_DIR}/${OUT_NAME}.gnn.h5"
singularity exec --cleanenv ${BIND_ARGS} --bind ${OUTFILE_DIR}:/numl_output --bind /project/6079563 --bind /scratch/${USERNAME} --nv ${PATH_TO_NUML} mpiexec -n 32 ph5_concat -i ${CONCAT_LIST} -o ${OUTFILE_DIR}/${OUT_NAME}.gnn.h5

echo "ph5_concat done"

rm "$CONCAT_LIST"
echo "Done"
