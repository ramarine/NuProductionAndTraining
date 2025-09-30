# Atmospheric Neutrino Creation Scripts

## Overview

This repository contains scripts for generating atmospheric neutrinos using the **DUNE LArSoft suite**.  
**Note:** You must have LArSoft installed on your machine to use these tools.

Useful paths:

Latest installed LArSoft:
`source /scratch/amarinei/LArSoft_scripts/setup_LArSoft_area_cc.sh /home/amarinei/Software/LArSoft_v10_09_00d00`
Latest installed nugraph:
`PATH_TO_NUGRAPH="/project/6071458/neutrino_ml"`
NuMl image:
`PATH_TO_IMAGE_FILE="/project/6079563/neutrino_ml/Numl_Image"`

---



## A. Interaction pre-production: h5 files containing diverse interactions with diverse number of particles


The following scripts will run atmospheric neutrino event generation for charged current interactions (CC):

- `run_all_e_CC.sh` &mdash; for electron neutrinos
- `run_all_mu_CC.sh` &mdash; for muon neutrinos
- `run_all_tau_CC.sh` &mdash; for tau neutrinos

**Features:**
- All logs are saved in `data/logs/`, with meaningful names for easy debugging.
- `job_times.log` records each job's runtime and peak memory usage, useful for future resource planning.

---

## B. NuGraph pre-processing: Adapt your h5 file until they are ready to be trained

### 1. Concatenate HDF5 Files

`sbatch --acount=def-nilic combine_hdf5.sh`

!!This script needs a lot of memory ~comparable with the total size of the h5 files!!
This scripts concatenates all h5 files produced earlier in step A (`run_makehdf5.sh`). It is normal that it will compress the total size of events. for example the total individual files were 120G while the concatenated one was 60G.

### 2. Add Event Keys

`sbatch --acount=def-nilic add_key.sh`

!!This script will take a longer time to run than the previous!!
After concatenation, each HDF5 file will have several tables (event, edep, etc.). A provided binary will take the `event_id` key from the event table and copy it into all other tables if missing.  
This enables every table to be accessed by event ID during downstream processing and training.


### 3. Convert Hits to Graph

**Warning:**  
Upon starting this step, files will be merged and the originals deleted.  
**Be sure to save Step 3 outputs in a separate folder!**

Exit your current container and start the following one:
/project/6079563/neutrino_ml/Numl_Image/numl.sif

- Adds feature normalization (range [0, 1]) for all variables.
- Uses MPI for parallel graph processing (default: 32 tasks requested).

---

## C. Run Training

Once graphs are produced, proceed with your favorite training scripts or frameworks.

---

## Additional Notes

- If you have suggestions for improving these scripts or the workflow, please open an issue or submit a pull request.
