# VASP Simulation Guide for GaN
This README provides detailed instructions for conducting DFT simulations of Gallium Nitride (GaN) using the Vienna Ab initio Simulation Package (VASP). The guide covers various types of calculations including self-consistent field (scf), band structure, density of states (DOS), projected density of states (PDOS), and phonon calculations, both with and without radiation-induced defects.

## Table of Contents
- Prerequisites
- SCF Calculations
- Band Structure Calculations
- Density of States Calculations
- Phonon Calculations
- Incorporating Radiation-Induced Defects
- Post-Processing and Analysis
- Troubleshooting
- References

## Prerequisites
* VASP license and software installation
* Basic knowledge of DFT and VASP
* Understanding of Slurm workload manager for job submission

## SCF Calculations
* Input Files Preparation: Prepare the INCAR, POSCAR, KPOINTS, and POTCAR files specific to GaN.
* Job Script Creation: Create a Slurm job script specifying the number of nodes, cores per node, and other relevant parameters.
* Job Submission: Submit the job using sbatch and monitor the progress.
* Output Analysis: Analyze the OUTCAR file for convergence and ensure that the energy is minimized.

## Band Structure Calculations
* Non-SCF Calculation: After SCF convergence, modify the INCAR file for non-SCF run to calculate the band structure.
* K-Path Generation: Use tools like seekpath to generate high-symmetry k-point paths.
* Job Submission and Analysis: Submit the band structure calculation job and analyze the EIGENVAL file to plot the band structure.

## Density of States Calculations
* DOS Calculation: Modify the INCAR file to include DOS-related tags (e.g., NEDOS, ISMEAR).
* Job Submission: Submit the job and after completion, use the DOSCAR file to plot total and partial DOS.

## Phonon Calculations
* Preparation: Use VASP with Phonopy or a similar package to prepare phonon-related calculations.
* Displacement Calculations: Perform supercell calculations with displacements to obtain force constants.
* Post-Processing: Analyze the force constants to compute phonon dispersion and density of states.

## Incorporating Radiation-Induced Defects
* Defect Structure Generation: Introduce defects into the GaN crystal structure in POSCAR.
* SCF Calculation: Repeat SCF calculations for the defective structure to analyze changes in electronic and vibrational properties.
* Band, DOS, and Phonon Analysis: Perform band, DOS, and phonon calculations for the defective structure following the same steps as for the pristine case.

## Post-Processing and Analysis
* Use tools like VASP Tools, pymatgen, or VESTA for data visualization and analysis.
* Compare the results with and without defects to assess the impact of radiation on GaN properties.

## Troubleshooting
* Ensure that all input files are correctly formatted.
* Check OUTCAR for any error messages or warnings.
* Validate convergence criteria for all calculations.
* Consult VASP and Slurm documentation for specific error codes and troubleshooting tips.

## References
* Kresse, G., and Furthmüller, J. Efficient iterative schemes for ab initio total-energy calculations using a plane-wave basis set. Phys. Rev. B 54, 11169 – Published 1 October 1996.
VASP User Guide and Documentation
Slurm Workload Manager Documentation
