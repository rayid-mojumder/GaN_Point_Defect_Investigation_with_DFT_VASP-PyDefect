#!/bin/bash

#SBATCH --job-name=GaN_scf
#SBATCH --account=open
#SBATCH --partition=open
##SBATCH --account=mjj5508_b    ##For Prof. Mia Jin's access point
##SBATCH --partition=sla-prio   ##For Prof. Mia Jin's access point
#SBATCH --mem=32GB
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --cpus-per-task=2

echo "Job started on $(hostname) at $(date)"
source ~/.bashrc
export PATH="$(pwd):${PATH}"
# Load VASP module
module use /storage/icds/RISE/sw8/modules
module load vasp/vasp-6.3.1vtst

echo "Start: $(date)"
srun vasp_std
echo "End: $(date)"

#command line execution
#sbatch run_scf.slurm
