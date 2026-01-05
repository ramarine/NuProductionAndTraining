import h5py
import numpy as np
import sys
import matplotlib.pyplot as plt

def print_help():
    print(f"Usage: {sys.argv[0]} <absolute_path_to_h5_file>")
    print("Prints basic information about the HDF5 file, 'event_table' statistics,")
    print("and generates energy distribution plots saved as EnergyDistribution.pdf")
    print("Example:")
    print(f"  python {sys.argv[0]} /scratch/amarinei/data/Atmospherics/tauCC_30_100/hdf5_reco1/concatenate.gnn.h5")

if len(sys.argv) != 2 or sys.argv[1] in ('-h', '--help'):
    print("No filename provided. Using default file:")
    filename = "/scratch/amarinei/data/Atmospherics/tauCC_30_100/hdf5_reco1/concatenate.gnn.h5"
    print(f"  {filename}")
else:
    filename = sys.argv[1]
    print(f"Using provided filename: {filename}")

lines = 5

try:
    with h5py.File(filename, 'r') as f:
        print(f"\n{'='*60}")
        print(f"ANALYSIS OF: {filename}")
        print(f"{'='*60}")
        print("Keys in the file:", list(f.keys()))

        if "event_table" in f:
            event_table = f["event_table"]
            print("\nColumns in event_table:")
            print(list(event_table.keys()))

            # Extract relevant columns
            nu_pdg_data = np.array(event_table["nu_pdg"])
            nu_id_data = np.array(event_table["event_id"])
            nu_energy_data = np.array(event_table["nu_energy"])
            lep_energy_data = np.array(event_table["lep_energy"])
            
            print("\nSample data (first {}):".format(lines))
            print("Sample 'nu_pdg':")
            print(nu_pdg_data[:lines])
            print("Sample 'event_id':")
            print(nu_id_data[:lines])
            print("Sample 'nu_energy' (GeV):")
            print(nu_energy_data[:lines])

            print("\nUnique values and their counts in 'nu_pdg':")
            unique_vals, counts = np.unique(nu_pdg_data, return_counts=True)
            for val, count in zip(unique_vals, counts):
                print(f"  Value: {val}, Count: {count}")

            print(f"\nEnergy statistics:")
            print(f"  Neutrino energy range: {nu_energy_data.min():.2f} - {nu_energy_data.max():.2f} GeV")
            print(f"  Lepton energy range:   {lep_energy_data.min():.2f} - {lep_energy_data.max():.2f} GeV")
            print(f"  Total events:          {len(nu_energy_data)}")

            # Create energy distribution plots
            print("\nGenerating energy distribution plots...")
            fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
            
            # Neutrino energy distribution
            n_nu = len(nu_energy_data)
            ax1.hist(nu_energy_data, bins=50, alpha=0.7, color='royalblue', 
                    edgecolor='navy', density=True, label=f'N={n_nu:}')
            ax1.set_xlabel('Neutrino Energy (GeV)', fontsize=12)
            ax1.set_ylabel('Density', fontsize=12)
            ax1.set_title('Neutrino Energy Distribution', fontsize=14, fontweight='bold')
            ax1.grid(True, alpha=0.3)
            ax1.legend(loc='upper right')
            ax1.tick_params(axis='x', rotation=0)
            
            # Add stats box
            stats_text = f'Mean: {nu_energy_data.mean():.1f} GeV\nStd: {nu_energy_data.std():.1f} GeV'
            ax1.text(0.02, 0.98, stats_text, transform=ax1.transAxes, 
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
            
            # Lepton energy distribution
            n_lep = len(lep_energy_data)
            ax2.hist(lep_energy_data, bins=50, alpha=0.7, color='crimson', 
                    edgecolor='darkred', density=True, label=f'N={n_lep:}')
            ax2.set_xlabel('Lepton Energy (GeV)', fontsize=12)
            ax2.set_ylabel('Density', fontsize=12)
            ax2.set_title('Lepton Energy Distribution', fontsize=14, fontweight='bold')
            ax2.grid(True, alpha=0.3)
            ax2.legend(loc='upper right')
            ax2.tick_params(axis='x', rotation=0)
            
            # Add stats box
            stats_text = f'Mean: {lep_energy_data.mean():.1f} GeV\nStd: {lep_energy_data.std():.1f} GeV'
            ax2.text(0.02, 0.98, stats_text, transform=ax2.transAxes, 
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

            plt.tight_layout()
            plt.savefig('EnergyDistribution.pdf', bbox_inches='tight', dpi=300, format='pdf')
            plt.show()
            
            print("✓ Energy distribution plot saved as 'EnergyDistribution.pdf'")

        else:
            print("ERROR: 'event_table' not found in file!")
            
except FileNotFoundError:
    print(f"ERROR: File not found: {filename}")
    print_help()
    sys.exit(1)
except KeyError as e:
    print(f"ERROR: Missing required column in event_table: {e}")
    sys.exit(1)
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)

print(f"\n✓ Analysis complete!")
