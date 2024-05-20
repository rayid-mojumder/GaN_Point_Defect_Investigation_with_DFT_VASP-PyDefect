# Follow Youtube Playlist to use this GitHub Repository
[Point Defects Using VASP and PyDefect (DFT)](https://www.youtube.com/playlist?list=PLSm7ZQMDqBcdkODXc4n9LvCrBzmgtRQpA)
![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/588d2b4a-6200-402a-b8f6-e7e1f82a55c2)

# Convergence Tests
In Density Functional Theory (DFT) calculations using the Vienna Ab initio Simulation Package (VASP), ensuring the convergence of the calculations with respect to the plane-wave cutoff energy (**ENCUT**) and the **K-point** mesh is crucial for obtaining reliable results. Here's a detailed look at these two types of convergence tests:

## 1. K-point Convergence Test:
The k-point mesh determines the sampling of the Brillouin zone. Insufficient k-point sampling can lead to inaccurate results, especially for properties that are sensitive to the electronic structure near the Fermi level.

### How to perform a K-point Convergence Test:
* Begin with a relatively coarse k-point mesh and calculate the property of interest (e.g., total energy, band structure).
* Incrementally increase the density of the k-point mesh (e.g., 2x2x2, 3x3x3, 4x4x4, etc.) and perform the calculation at each step.
* Monitor the property of interest as you increase the k-point density. When the change in the property between successive k-point meshes is below a chosen threshold (e.g., a few meV per atom for total energy), the calculation is considered converged with respect to k-points.

### Best Practices:
* Always ensure that the k-point grid is centered at the Gamma point for better accuracy.
* Utilize symmetry reduction if applicable to reduce computational effort.
* For metals or systems with small band gaps, a denser k-point mesh might be necessary due to rapid changes in electronic states near the Fermi level.
```shell
#!/bin/bash

################################### Parameter Setting ################################

echo "K-point convergence test submission initiated"

# Initialize a variable to hold all job IDs.
job_ids=()

# Define the range of k-points to test. For example, from 4x4x4 to 6x6x6.
K_START=3
K_END=15
K_INCREMENT=2 #choose odd K-mesh grids only

################################### Create directory for each K-point mesh ################################

# Loop over the specified range of k-point values.
for (( K=$K_START; K<=$K_END; K+=$K_INCREMENT ))
do
   # Create a directory for the current k-point grid.
   mkdir KPOINTS_${K}x${K}x${K}
   cd KPOINTS_${K}x${K}x${K}

   # Copy VASP input files from the parent directory.
   cp ../INCAR .
   cp ../POSCAR .
   cp ../POTCAR .

   # Create the KPOINTS file for the current k-point grid.
   echo "Automatic mesh" > KPOINTS
   echo "0" >> KPOINTS
   echo "Gamma" >> KPOINTS
   echo "$K $K $K" >> KPOINTS

################################### Slurm job schedular (wait for job completion) ################################

   # Submit the VASP job to the Slurm scheduler using a here-document for the job script.
   job_id=$(sbatch --parsable << EOF
#!/bin/bash
#SBATCH --job-name=GaN_Conv_KPOINTS_${K}x${K}x${K}
#SBATCH --account=open
#SBATCH --partition=open
#SBATCH --mem=32GB
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1

echo "Job started on $(hostname) at $(date)"
source ~/.bashrc
export PATH="$(pwd):${PATH}"
# Load VASP module
module use /storage/icds/RISE/sw8/modules
module load vasp/vasp-6.3.1vtst

echo "Start: $(date)"
srun vasp_std
echo "End: $(date)"
EOF
)
   # Save job ID for later dependency.
   job_ids+=($job_id)

   # Return to the parent directory.
   cd ..
done

echo "K-point convergence test submission completed"

# Combine job IDs into a comma-separated list for dependency.
job_ids_str=$(IFS=,; echo "${job_ids[*]}")

# Submit a new job that waits for all VASP jobs to finish before extracting energies.
sbatch --dependency=afterok:$job_ids_str << 'EOF'
#!/bin/bash
#SBATCH --job-name=extract_energies
#SBATCH --account=open
#SBATCH --partition=open
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

################################### Energy Extraction ################################

# Directory where the script is running
RUN_DIR=$(pwd)

# File to store the total energies.
echo "K-Points    Total Energy (eV)" > "$RUN_DIR/total_energies.txt"

# Loop through the KPOINTS directories.
for K_DIR in "$RUN_DIR"/KPOINTS_*; do
  if [ -d "$K_DIR" ] && [ -f "$K_DIR/OUTCAR" ]; then
    K_POINTS=$(basename "$K_DIR" | sed 's/KPOINTS_//')
    ENERGY=$(grep "free  energy   TOTEN" "$K_DIR/OUTCAR" | tail -1 | awk '{print $5}')
    echo "$K_POINTS    $ENERGY" >> "$RUN_DIR/total_energies.txt"
  fi
done


EOF

echo "Total energy extraction job will be followed once all the runs are completed"

#command line execution
#chmod +x k_conv_test.sh && sed -i 's/\r$//' k_conv_test.sh && ./k_conv_test.sh
```

## 2. ECUT Convergence Test (Plane-wave Cutoff Energy):
The plane-wave cutoff energy (ENCUT) determines the kinetic energy limit for the plane waves used in expanding the wave functions. Lower cutoff values lead to faster computations but can compromise accuracy.

### How to perform an ECUT Convergence Test:
* VASP recommends starting with the maximum ENMAX or ENMIN value among all the POTCAR files used in the calculation. However, testing for convergence is essential.
* Start the test with the recommended ENCUT and increase it in steps (e.g., 25 eV increments).
* At each step, compute the property of interest.
* Observe how the property changes with increasing ENCUT. When the property variation falls below a chosen threshold (again, perhaps a few meV per atom for total energy), you can consider the calculation converged with respect to ENCUT.

### Best Practices:
* After determining a converged ENCUT, it's common practice to add a small buffer (e.g., 10-20% extra) to ensure that the results are well within the converged range.
* Be aware that higher ENCUT values significantly increase computational time and memory requirements.
* Check the VASP manual or literature for typical ENCUT values for similar systems or materials as a reference point.
```shell
#!/bin/bash

################################### Parameter Setting ################################

echo "ENCUT convergence test submission initiated"

# Initialize a variable to hold all job IDs.
job_ids=()

# Define the range of ENCUT values to test. For example, from 300 eV to 600 eV.
 # For Ga - ENMAX  =  282.691; ENMIN  =  212.018 eV, for N - ENMAX  =  400.000; ENMIN  =  300.000 eV
 # Usual practice - set ENCUT = largest ENMAX in the POTCAR file	
ENCUT_START=390     # start a bit below the highest ENMAX (here 400 eV) value
ENCUT_END=600       # at least 150% of the highest ENMAX value, here = 600 eV
ENCUT_INCREMENT=20  # increments of 20 to 50 eV are typical choices.

################################### Create directory for each ENCUT value ################################

# Loop over the specified range of ENCUT values.
for (( ENCUT=$ENCUT_START; ENCUT<=$ENCUT_END; ENCUT+=$ENCUT_INCREMENT ))
do
   # Create a directory for the current ENCUT value.
   mkdir ENCUT_${ENCUT}
   cd ENCUT_${ENCUT}

   # Copy VASP input files from the parent directory.
   cp ../INCAR .
   cp ../POSCAR .
   cp ../POTCAR .
   cp ../KPOINTS .

   # Modify the INCAR file to set the ENCUT value.
   sed -i "/^ENCUT/c\ENCUT = $ENCUT" INCAR

################################### Slurm job scheduler (wait for job completion) ################################

   # Submit the VASP job to the Slurm scheduler using a here-document for the job script.
   job_id=$(sbatch --parsable << EOF
#!/bin/bash
#SBATCH --job-name=GaN_Conv_ENCUT_${ENCUT}
#SBATCH --account=open
#SBATCH --partition=open
#SBATCH --mem=32GB
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1

echo "Job started on $(hostname) at $(date)"
source ~/.bashrc
export PATH="$(pwd):${PATH}"
# Load VASP module
module use /storage/icds/RISE/sw8/modules
module load vasp/vasp-6.3.1vtst

echo "Start: $(date)"
srun vasp_std
echo "End: $(date)"
EOF
)
   # Save job ID for later dependency.
   job_ids+=($job_id)

   # Return to the parent directory.
   cd ..
done

echo "ENCUT convergence test submission completed"

# Combine job IDs into a comma-separated list for dependency.
job_ids_str=$(IFS=,; echo "${job_ids[*]}")

# Submit a new job that waits for all VASP jobs to finish before extracting energies.
sbatch --dependency=afterok:$job_ids_str << 'EOF'
#!/bin/bash
#SBATCH --job-name=extract_energies
#SBATCH --account=open
#SBATCH --partition=open
#SBATCH --mem=4GB
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

################################### Energy Extraction ################################

# Directory where the script is running
RUN_DIR=$(pwd)

# File to store the total energies.
echo "ENCUT    Total Energy (eV)" > "$RUN_DIR/total_energies.txt"

# Loop through the ENCUT directories.
for ENCUT_DIR in "$RUN_DIR"/ENCUT_*; do
  if [ -d "$ENCUT_DIR" ] && [ -f "$ENCUT_DIR/OUTCAR" ]; then
    ENCUT_VALUE=$(basename "$ENCUT_DIR" | sed 's/ENCUT_//')
    ENERGY=$(grep "free  energy   TOTEN" "$ENCUT_DIR/OUTCAR" | tail -1 | awk '{print $5}')
    echo "$ENCUT_VALUE    $ENERGY" >> "$RUN_DIR/total_energies.txt"
  fi
done

EOF

echo "Total energy extraction job will be followed once all the runs are completed"

# Command line execution
# chmod +x ecut_conv_test.sh && sed -i 's/\r$//' ecut_conv_test.sh && ./ecut_conv_test.sh
```
In summary, ensuring convergence in both k-points and ENCUT is fundamental for achieving reliable DFT results with VASP. These convergence tests, while increasing computational time upfront, are crucial for validating the accuracy of your simulations.
