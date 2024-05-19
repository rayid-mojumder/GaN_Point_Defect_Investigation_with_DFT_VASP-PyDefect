# GaN Electronic Properties (scf, bands, dos) with VASP

To prepare for your VASP calculations involving relaxation, SCF, band structure, and DOS for GaN, you need properly configured INCAR, POSCAR, and KPOINTS files. Below is the comprehensive guidance for each calculation step, including file preparation, file usage sequence, and plotting instructions:

## 1. Relaxation Calculation:
INCAR.relax:
```shell
SYSTEM = GaN Relaxation    # Descriptive name of the system
ISTART = 0                 # Job is started from scratch
ICHARG = 2                 # Initial electron density from atomic charges
ENCUT = 520                # Energy cutoff for plane waves
ISMEAR = -5                # Smearing type, -5 for tetrahedron method with Blöchl corrections
EDIFF = 1E-5               # Energy convergence criterion
EDIFFG = -0.01             # Force convergence criterion, negative for relaxation
IBRION = 2                 # Algorithm for ionic relaxation, 2 for CG method
NSW = 100                  # Maximum number of ionic steps
ISIF = 3                   # Stress and ion relaxation, 3 for variable cell shape
```
POSCAR: As provided for GaN, detailing the unit cell and atomic positions.
KPOINTS:

```shell
K-Points
0               # Automatic generation scheme
Monkhorst Pack  # Centered: k mesh with equally spaced k point
11 11 11        # Grid size:  odd number of k points in each direction results in a Γ-centered k-mesh
0 0 0           # Shift (usually zero for bulk)
```
 
## 2. SCF Calculation:
File Usage Sequence and Plotting:
1.	Relaxation → SCF:
•	Use CONTCAR (and KPOINTS) from relaxation as the POSCAR for SCF.
•	Post-SCF, analyze the OUTCAR for total energy and convergence.
2.	SCF → Band Structure/DOS:
•	Utilize SCF's CHGCAR and WAVECAR (and POSCAR) for band structure and DOS calculations.
•	For band structure, plot EIGENVAL data.
•	For DOS, plot DOSCAR data.

INCAR.scf:
```shell
SYSTEM = GaN SCF            # Descriptive name for the SCF calculation
ISTART = 0                  # Start from scratch (use 1 if starting from WAVECAR)
ICHARG = 2                  # Use atomic charges for electron density
ENCUT = 520                 # Energy cutoff for plane waves
ISMEAR = 0                  # Gaussian smearing, appropriate for insulators
SIGMA = 0.05                # Width of the Gaussian smearing
EDIFF = 1E-6                # Energy convergence criterion
LREAL = Auto                # Real-space projection, auto-selected
```
POSCAR: Updated with the relaxed structure, typically taken from the CONTCAR of the relaxation step.
KPOINTS: Unchanged from the relaxation setup for consistency in k-point sampling.
 
## 3. Band Structure Calculation:
INCAR.band:
```shell
SYSTEM = GaN Band Structure # Descriptive name for the band structure calculation
ISTART = 1                  # Start from the wavefunction of a previous calculation
ICHARG = 11                 # Use the fixed charge density from SCF
ENCUT = 520                 # Energy cutoff for plane waves
ISMEAR = -5                 # Tetrahedron method with Blöchl corrections
EDIFF = 1E-6                # Energy convergence criterion
LCHARG = False              # Do not write CHGCAR
LWAVE = False               # Do not write WAVECAR
```
KPOINTS for Band Structure:
```shell
K-points along high symmetry lines # Comment for clarity
10                               # Number of k-points between high symmetry points
Line-mode                        # Path following high symmetry lines
Reciprocal                       # Coordinates in reciprocal space
0.0 0.0 0.0   ! Gamma
0.5 0.0 0.0   ! X
0.5 0.0 0.0   ! X
0.5 0.5 0.0   ! M
0.0 0.0 0.0   ! Gamma
```
### Plotting Guidelines:
•	Band Structure: Use gnuplot or similar to plot bands from EIGENVAL.
```shell
 plot 'EIGENVAL' using ($1):($2) with lines
 ```
## 4. DOS Calculation:
INCAR.dos:
```shell
SYSTEM = GaN DOS             # Descriptive name for the DOS calculation
ISTART = 1                   # Start from wavefunction, post-SCF
ICHARG = 11                  # Use the charge density from a static calculation
ENCUT = 520                  # Energy cutoff for plane waves
ISMEAR = -5                  # Tetrahedron method, suitable for DOS
EDIFF = 1E-6                 # Energy convergence criterion
LORBIT = 11                  # Write projected DOS
NEDOS = 2000                 # Number of energy points for DOSNumb
```
KPOINTS for DOS:
```shell
Automatic mesh               # Comment for clarity
0                            # Let VASP choose the grid
Gamma                        # Centered at Gamma point
10 10 1                      # Increased mesh density for DOS precision
```
### Plotting Guidelines:
•	DOS: Plot total and projected DOS from DOSCAR.
```Shell
plot 'DOSCAR' using ($1):($2) with lines
```
These instructions offer a cohesive framework for executing sequential VASP calculations for your GaN system, ensuring each step is well-defined and outputs are correctly interpreted for subsequent analyses.
 

# Other Materials in VASP
The outlined procedure for creating VASP input files (INCAR, POSCAR, KPOINTS) and the general workflow for conducting relaxation, self-consistent field (SCF) calculations, band structure, and density of states (DOS) analyses can be adapted to virtually any material and lattice structure with some adjustments specific to the material's properties and crystal structure:
1.	Material and Crystal Structure Specific Adjustments:
•	POSCAR: You need to modify the POSCAR file to reflect the crystal structure and atomic positions of your specific material. Each material will have its unique lattice parameters and atomic basis.
•	Pseudopotentials (POTCAR): While not detailed in our discussion, you need to select appropriate POTCAR files for the elements you are working with, matching the exchange-correlation functional used (e.g., PBE, LDA).
2.	Parameter Tuning:
•	ENCUT (Plane Wave Cutoff): This might need adjustment based on the highest ENMAX among the POTCAR files of your elements.
•	KPOINTS: The mesh density and specific high-symmetry points for band structure calculations will depend on the Brillouin zone of your material's lattice.
•	ISMEAR and SIGMA: Smearing parameters might need tuning based on the metallic or insulating nature of your material.
3.	Calculation Specifics:
•	Relaxation: While the general process remains the same, the forces and convergence criteria might need adjustments based on the system's size and the precision required.
•	SCF: The procedure is largely material-independent but verifies convergence and checks if the calculated properties align with expected physical behavior.
•	Band Structure and DOS: The path in the Brillouin zone for band structure calculations needs to be defined based on the crystal symmetry, and the DOS analysis may require adjustments in NEDOS and energy range.
4.	General Applicability:
•	The workflow is robust across different materials as it fundamentally relies on VASP's capacity to handle diverse material systems, given correct input files and adequate computational resources.
•	Adapting the workflow involves updating material-specific information, recalibrating parameters for the specific computational needs, and ensuring that the input files are consistently reflective of the material under study.
In summary, while the core computational steps remain consistent, specific input details and parameters need to be customized to reflect the physics of the material you are investigating, ensuring the reliability and accuracy of your simulations.







