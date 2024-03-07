#!/bin/bash

################################### Parameter Setting ################################

echo "K-point convergence test submission initiated"

# Initialize a variable to hold all job IDs.
job_ids=()

# Define the range of k-points to test.
K_START=4
K_END=6
K_INCREMENT=1

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
#SBATCH --job-name=GaN_Trail${K}
#SBATCH --account=open
#SBATCH --partition=open
#SBATCH --mem=32GB
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=1

echo "Job started on \$(hostname) at \$(date)"
source ~/.bashrc
export PATH="\$(pwd):\${PATH}"
# Load VASP module
module use /storage/icds/RISE/sw8/modules
module load vasp/vasp-6.3.1vtst

echo "Start: \$(date)"
srun vasp_std
echo "End: \$(date)"
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
#chmod +x k_conv_test_2.sh && sed -i 's/\r$//' k_conv_test_2.sh
#./k_conv_test_2.sh