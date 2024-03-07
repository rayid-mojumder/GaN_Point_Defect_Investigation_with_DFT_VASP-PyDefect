# ECUT Convergence Test Script Using VASP and SLURM
This script facilitates performing an ENCUT (plane-wave cutoff energy) convergence test with the VASP (Vienna Ab initio Simulation Package) within a SLURM-managed high-performance computing environment. It systematically adjusts the ENCUT value across a series of VASP calculations, subsequently extracting the total energy from each to assist in determining the optimal cutoff energy for your computational model.

## Overview
The script executes the following operations:

### Parameter Setting:
 - Defines the range of ENCUT values to test.

### Creating Directory for Each ENCUT Value:
 - Iterates over a specified range of ENCUT values.
 - For each ENCUT value, it creates a directory, copies the VASP input files, and modifies the ENCUT value in the INCAR file.

### SLURM Job Scheduler:
 -Submits each VASP calculation to the SLURM queue, tracking job IDs to ensure proper sequence and dependency resolution.

### Energy Extraction:
 - Upon completion of all VASP jobs, it initiates a final SLURM job that extracts and aggregates total energy values into total_energies.txt.

## Usage Instructions
### Prepare the Script:
1. Confirm that the necessary VASP input files (INCAR, POSCAR, POTCAR, KPOINTS) are present in the same directory as this script.
2. Adjust the ENCUT range within the script (ENCUT_START, ENCUT_END, ENCUT_INCREMENT) to fit your testing requirements.
   
### Execute the Script:
 - Make the script executable: chmod +x ecut_conv_test.sh.
 - Convert line endings to Unix format if necessary: sed -i 's/\r$//' ecut_conv_test.sh.
 - Run the script: ./ecut_conv_test.sh.

### Analyze Results:
 - After execution, total_energies.txt will list the total energies corresponding to each tested ENCUT value.
 - Use this data to assess convergence and pinpoint the optimal ENCUT value.

## Important Notes
 - Familiarity with VASP and a valid license are presumed.
 - Ensure that your computational environment is SLURM-based and that you have the necessary compute permissions.
 - Verify the VASP output's accuracy and completeness before leveraging the extracted energy data for crucial evaluations or decisions.
 - By following these steps, you can systematically conduct ENCUT convergence tests using VASP in a SLURM environment, streamlining your process to achieve both accuracy and computational efficiency.
