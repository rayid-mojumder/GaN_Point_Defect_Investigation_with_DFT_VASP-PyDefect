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
