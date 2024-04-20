# K-point Convergence Test Script Using VASP and SLURM
This script automates the process of conducting a K-point convergence test using VASP within a SLURM-managed high-performance computing environment, adjusting K-point meshes, running calculations, and extracting energies to identify the optimal grid.

## Overview:
1. Parameter Setting:
   - It defines the range of K-points to test.
2. Creating Directory for Each K-point Mesh:
   - It loops over a specified range of K-point values.
   - For each K-point, it creates a directory, copies the VASP input files, and generates an appropriate KPOINTS file.
3. SLURM Job Scheduler:
   - It submits each VASP calculation to the SLURM queue, tracking job IDs to enforce dependencies.
4. Energy Extraction:
   - Upon the completion of all VASP jobs, it initiates a final SLURM job that extracts and compiles total energy values into total_energies.txt.

## Usage Instructions:
1. Prepare the Script:
   - Ensure the necessary VASP input files (INCAR, POSCAR, POTCAR) are in the same directory as this script.
   - Adjust the K-point range within the script (K_START, K_END, K_INCREMENT) as needed.

2. Execute the Script:
   - Make the script executable with: chmod +x k_conv_test.sh.
   - If needed, convert line endings to Unix format: sed -i 's/\r$//' k_conv_test.sh.
   - Launch the script: ./k_conv_test.sh.

3. Analyze Results:
   - Post-execution, total_energies.txt will contain the total energies corresponding to each K-point mesh.
   - Use this data to evaluate convergence and identify the optimal K-point mesh.

### Important Notes:
- Assumes knowledge of VASP and possession of a license.
- SLURM environment and compute permissions are required.
- Confirm VASP output integrity before basing decisions on extracted data.
- After running wait till the total_energies.txt file is generated, it will store the extracted data

Follow these guidelines to efficiently perform K-point convergence tests with VASP in a SLURM environment, enhancing both accuracy and computational efficiency.


#### Additional Details:
- **k_conv_test_1a.sh** refers to creating and simulating different KPOINTS files without total energy purging. After all jobs are completed, the final energy data can be manually purged together or could be purged by the **k_conv_test_1b.sh** file
