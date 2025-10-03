import h5py
import numpy as np
import sys

# /scratch/amarinei/data/Atmospherics/NC_5_5/hdf5/NeutrinoML_r00004_s00000_ts707582.h5
# /scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00499_s00000_ts138774.h5
def print_help():
    print(f"Usage: {sys.argv[0]} <absolute_path_to_h5_file>")
    print("Prints basic information about the HDF5 file and the 'event_table'.")
    print("Example:")
    print(f"  python {sys.argv[0]} /absolute/path/to/file.h5")

if len(sys.argv) != 2 or sys.argv[1] in ('-h', '--help'):
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00497_s00000_ts230414.h5"
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00498_s00000_ts562468.h5"
    # filename = "/scratch/amarinei/data/Atmospherics/MuCC_250_1000/hdf5/NeutrinoML_r00499_s00000_ts138774.h5"
    filename = "/scratch/amarinei/data/Atmospherics/NC_5_5/hdf5/NeutrinoML_r00004_s00000_ts707582.h5"
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
        print("\nSample 'nu_pdg' ")
        print(nu_pdg_data[:lines])

        nu_pdg_data = np.array(event_table["nu_pdg"])
        print("\nUnique values and their counts in 'nu_pdg':")
        unique_vals, counts = np.unique(nu_pdg_data, return_counts=True)
        for val, count in zip(unique_vals, counts):
            print(f"Value: {val}, Count: {count}")
        # is_cc_data = np.array(event_table["is_cc"])
        # print(is_cc_data[:lines])
