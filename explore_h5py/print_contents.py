import h5py
import numpy as np
import sys

#  module load StdEnv/2020
# module load apptainer/1.1.8
# apptainer shell --bind /home/amarinei,/cvmfs,/scratch/amarinei,/project/6071458 -C --cleanenv /project/6079563/neutrino_ml/Numl_Image/numl:v23.11.0.sif


def print_help():
    print(f"Usage: {sys.argv[0]} <absolute_path_to_h5_file>")
    print("Prints basic information about the HDF5 file and the 'event_table'.")
    print("Example:")
    print(f"  python {sys.argv[0]} /absolute/path/to/file.h5")

if len(sys.argv) != 2 or sys.argv[1] in ('-h', '--help'):
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00497_s00000_ts230414.h5"
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00498_s00000_ts562468.h5"
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00499_s00000_ts138774.h5"
    # filename = "/scratch/amarinei/data/Atmospherics/NC_5_5/hdf5/NeutrinoML_r00004_s00000_ts707582.h5"
    # filename =  "/scratch/amarinei/data/Atmospherics/TauCC_250_1000/hdf5/NeutrinoML_r00501_s00000_ts477622.h5"
    filename =  "/scratch/amarinei/data/Atmospherics/ECC_250_1000/hdf5/NeutrinoML_r00501_s00000_ts793244.h5"
    filename = "/scratch/amarinei/data/Atmospherics/TauCC_100_50/hdf5/NeutrinoML_r00050_s00000_ts786689.h5"
    filename = "/scratch/amarinei/data/Atmospherics/TauCC_3_1/hdf5/NeutrinoML_r00012_s00000_ts813206.h5"
    
    # filename =  "/scratch/amarinei/data/Atmospherics/ECC_250_1000/hdf5/NeutrinoML_r00495_s00000_ts993214.h5"
    
else:
    filename = sys.argv[1]


lines = 5

    

with h5py.File(filename, 'r') as f:
    print("Keys in the file:", list(f.keys()))

    if "event_table" in f:
        event_table = f["event_table"]
        print("\nColumns in event_table:")
        print(np.array(event_table))

        nu_pdg_data = np.array(event_table["nu_pdg"])
        nu_id_data = np.array(event_table["event_id"])
        print("\nSample 'nu_pdg' ")
        print(nu_pdg_data[:lines])
        print("\nSample 'event_id' ")
        print(nu_id_data[:lines])

        nu_pdg_data = np.array(event_table["nu_pdg"])
        print("\nUnique values and their counts in 'nu_pdg':")
        unique_vals, counts = np.unique(nu_pdg_data, return_counts=True)
        for val, count in zip(unique_vals, counts):
            print(f"Value: {val}, Count: {count}")
        # is_cc_data = np.array(event_table["is_cc"])
        # print(is_cc_data[:lines])
