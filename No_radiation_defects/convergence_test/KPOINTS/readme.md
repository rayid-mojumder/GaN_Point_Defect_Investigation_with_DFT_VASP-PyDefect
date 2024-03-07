# K-point Convergence Test Script Using VASP and SLURM

Table of Contents

1. Overview
2. Usage Instructions
   2.1 Prepare the Script
   2.2 Execute the Script
   2.3 Analyze Results
3. Important Notes

Overview:
This script automates the process of conducting a K-point convergence test using VASP within a SLURM-managed high-performance computing environment, adjusting K-point meshes, running calculations, and extracting energies to identify the optimal grid.

Usage Instructions:

1. Prepare the Script:
   - Ensure VASP input files (INCAR, POSCAR, POTCAR) are in the same directory as the script.
   - Modify K-point values (K_START, K_END, K_INCREMENT) as needed.

2. Execute the Script:
   - Make the script executable: chmod +x k_conv_test_2.sh.
   - If needed, fix line endings: sed -i 's/\r$//' k_conv_test_2.sh.
   - Run the script: ./k_conv_test_2.sh.

3. Analyze Results:
   - Upon completion, check total_energies.txt for total energies per K-point mesh.
   - Use these to decide on the optimal K-point grid.

Important Notes:
- Assumes knowledge of VASP and possession of a license.
- SLURM environment and compute permissions are required.
- Confirm VASP output integrity before basing decisions on extracted data.

Follow these guidelines to efficiently perform K-point convergence tests with VASP in a SLURM environment, enhancing both accuracy and computational efficiency.
