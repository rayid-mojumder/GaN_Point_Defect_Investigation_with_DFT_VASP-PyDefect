# GaN Point Defect Formation Energy Calculation Using VASP and PyDefect [May 16, 2024]
This entire step-by-step guide is a simplified and comprehensive guide to generating point defect formation energy using the PyDefect package [[Official site](https://kumagai-group.github.io/pydefect/index.html)] and VASP. 
* All the issues related to implementing the codes have been solved here. You can just copy and paste the codes with your own materials, and it should work perfectly. Here, I am using GaN as an example. 
* If you are new to VASP, please first go to the "GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/Without_defect_GaN_DFT_VASP_Slurm" directory to become familiar with it.
* *You need a Linux environment (could be a local PC or supercomputing server) and have already installed Python3 (also Pip) and VASP*.
* Also, you need to have a Pseudopotential file. In my case, I have *potpaw_PBE.54.tar.gz*
* I am using Slurm to run the package on the remote server; if you are using MPIrun or something else, please adjust the VASP run scripts. Either way, you can follow this guide.
* Basic Workflow (from Official PyDefect site): ![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/a20eeb7a-2a10-4cfa-94e1-341b1ce64f07)
* Basic Directory Tree (From Official PyDefect site): ![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/0e62eff1-ac7e-4db0-8565-a6f873854168)

*Let's begin....*

## Step-1: Open Python3 terminal and install PyDefect and VISE
```bash
pip install pydefect
pip install vise
```
If you need to upgrade the package, use:
```
pip install --upgrade pydefect
pip install --upgrade vise
pip install --upgrade mp-api
```
## Step-2: Extract POTCAR files in a directory (replace directory with your own directory)
```bash
cd /storage/work/mvm7218/
mkdir potpaw_PBE.54
#now upload the potpaw_PBE.54.tar.gz file to /storage/work/mvm7218/
tar -xzvf potpaw_PBE.54.tar.gz -C /storage/work/mvm7218/potpaw_PBE.54
```
## Step-3: Edit *.pmgrc.yaml* file and add POTCAR and Materials project API (you need to add your own Materials Project API number)
```bash
cd ~
cd .config
nano .pmgrc.yaml
# In cases, the .pmgrc.yaml file could be within.config, in that case use that file using the following code [if needed]
nano .config/.pmgrc.yaml
```
The above two codes will open *.pmgrc.yaml* file. Now, add the functional type, POTCAR directory, and materials project API in the text file and save it. For instance, my info is below. Please note that this is not a bash command.
```
PMG_DEFAULT_FUNCTIONAL: PBE_54
PMG_MAPI_KEY: ksrEbuvP0ucRZAas11zIz8y7lii15gpy
PMG_VASP_PSP_DIR: /storage/work/mvm7218/
```
With the following code, you can see all the *.pmgrc.yaml* files, and if there is multiple, check and delete the one that is not needed [optional]
```
find . -name .pmgrc.yaml -type f -exec readlink -f \{\} \;
```
## Step-4: Create the required directory tree (change first command to your custom directory)
```
cd /storage/work/
mkdir GaN
cd GaN
#This 'GaN' directory will be our parent directory from now on.
mkdir unitcell
mkdir unitcell/structure_opt
mkdir unitcell/band
mkdir unitcell/dielectric
mkdir unitcell/dos
mkdir unitcell/relax
mkdir cpd
mkdir defect
mkdir defect/perfect
```
## Step-5: Download and upload pristine bulk unit cell
`
Download the pristine unit cell from the materials project and upload it to the *unitcell/structure_opt/* directory
`
<br> From this point on, I assume you are following the provided directory tree. If that is the case, you can copy and paste the codes into the terminal without any issues. <br>In any case, if you see errors in the directory, please check if your directory path is correctly used or not, and update the code with your own directory path. 
* Remember, we will consider `/GaN` as our parent directory. Underwhich there will be `/unitcell`, `/cpd`, and `/defect` directories.
* Whenever there is the command *sbatch some_name.slurm*, this means it's a command used with the Slurm package to execute VASP calculation. If you are using MPI-run or another package, use the execution script for that package. 
* You will find the batch scripts at the end of this step-by-step. Please update that script based on your system parameters. Upload the slurm scripts (*run.slrum* and *srun.slurm*) in the `/GaN` directory, or you can create it later on.
Let's calculate the point defects!
 
## Step-6: Relax Calculation and save the relaxed POSCAR file for further calculations
* Note that the structure optimization must be generally iterated with 1.3 times larger cutoff energy until the forces and stresses are converged at the first ionic step. So if you are considering GaN, with Si and Mg dopants, then consider the highest ECUT value that is present in the potential file of Ga, N, Si, and Mg. Then use 1.3 times ECUT value of that for propert convergence. Use the same ECUT for all calculation. In my case it is 400 * 1.3 = 520 eV.
  
```
cd unitcell/structure_opt
vise vs -uis ENCUT 520.0;
# creates INCAR, POTCAR, and KPOINTS for the relax calculation
# If you need uniform K-points grid use the next line (if required)
# vise vs --uniform_kpt_mode 
```
Copy the slurm package to the structure_opt folder and run the slurm script
```
sbatch run.slurm
```
Now copy everything to the `unitcell/relax` directory and remove everything under `/structure_opt/` and then create empty *POSCAR* file and *run.slurm* files
```
cp * ../relax
rm *
touch POSCAR
touch run.slurm
```
Copy the *CONTCAR* file and *run.slurm* from the `unitcell/relax/` directory and save it as a *POSCAR* file amd *run.slurm* files in the `/structure_opt/` directory
```
cp ../relax/CONTCAR POSCAR
cp ../relax/run.slurm run.slurm
# To see the Fermi energy value run the following commad
grep E-fermi OUTCAR | tail -1
```
Copy the POSCAR file `/structure_opt/POSCAR` to `/band/`, `/dos`, and `/dielectric/` directories
```
cp POSCAR -r ../band
cp POSCAR -r ../dos
cp POSCAR -r ../dielectric
```
## Step-6: Band, DOS, and Dielectric calculation of the relaxed Unit cell
We then calculate the band structure (BS), density of states (DOS), and dielectric constants. In the defect calculations, the BS is used for determining the valence band maximum (VBM) and conduction band minimum (CBM), while the dielectric constant, or a sum of electronic (or ion-clamped) and ionic dielectric tensors, is needed for correcting the defect formation energies. 

Band calculation:
```
cd ../band
vise vs -uis ENCUT 520.0 -t band -d ../structure_opt
cd ../structure_opt
sbatch run.slurm
vise plot_band
grep E-fermi OUTCAR | tail -1
cp * -r ../band/
rm *
touch POSCAR
touch run.slurm
cp ../relax/CONTCAR POSCAR
cp ../relax/run.slurm run.slurm
```
DOS calculation:
```
cd ../dos
vise vs -uis ENCUT 520.0 -t dos -d ../structure_opt -uis LVTOT True LAECHG True KPAR 1
cd ../structure_opt
sbatch run.slurm
grep E-fermi OUTCAR | tail -1
vise plot_dos
cp * -r ../dos/
rm *
touch POSCAR
touch run.slurm
cp ../relax/CONTCAR POSCAR
cp ../relax/run.slurm run.slurm
```
Dielectric calculation:
```
cd ../dielectric
vise vs -uis ENCUT 520.0 -t dielectric_dfpt -d ../structure_opt
cd ../structure_opt
sbatch run.slurm
cp * -r ../dielectric/
rm *
touch POSCAR
touch run.slurm
cp ../relax/CONTCAR POSCAR
cp ../relax/run.slurm run.slurm
```
## Step-7: Gather unit cell calculation results for future reference
```
cd ..
pydefect_vasp u -vb band/vasprun.xml -ob band/OUTCAR -odc dielectric/OUTCAR -odi dielectric/OUTCAR -n GaN
pydefect_print unitcell.yaml
```
## At this point of the simulation, you must do the following - *Modify and Correct the mprester.py and mp_tools.py files* [Must do this additional stage]
*Download *mprester.py* and *mp_tools.py* files from this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/` path
```
#Go to the mprester.py file. In the following command, replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/mp_api/client/mprester.py
# Replace the *mprester.py* file's content with the downloaded one
nano mprester.py
```
Find the *DEFAULT_API_KEY* line and hardcode the materials project key to the default API key (like the following). Here 'ksrEbuvP0ucRZAas11zIz8y7lii15gpy' is my own Materials Project API key.
<br>*DEFAULT_API_KEY = environ.get("MP_API_KEY", "ksrEbuvP0ucRZAas11zIz8y7lii15gpy")*
```
#Go to the mp_tools.py file. In the following command, replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/pydefect/util/mp_tools.py
# Replace the *mp_tools.py* file's content with the downloaded one
nano mp_tools.py
```

## Step-8: Create competing phases and run VASP calculation of the competing phases
Create competing phases for GaN. This means all the possible scenarios with these atoms; in this case, there could be - GaN, Ga, and N. 
```
cd ~
# In the following command, replace the first /storage/work/' part with your own directory path
cd /storage/work/GaN/cpd
pydefect_vasp mp -e Ga N --e_above_hull 0.0005
pydefect_vasp mp -e Ga --e_above_hull 0.0005
pydefect_vasp mp -e N --e_above_hull 0.0005
```
Create VASP files for these competing phases and run the calculation
```
for i in *_*/;do cd $i; vise vs -uis ENCUT 520.0; cd ../;done
#Copy run.slurm to each competing phase folder and run VASP calculation
for dir in */;do cd $dir; cp ../../unitcell/band/run.slurm .; sbatch run.slurm; cd ../;done 
```
Generate the *composition_energies.yaml* file and competing phase diagram (CPD). Note, *pydefect_print* command is used to visualize the *.json* or *.yaml* files
```
pydefect sre
pydefect_print standard_energies.yaml
pydefect_print relative_energies.yaml
pydefect cv -t GaN
pydefect_print chem_pot_diag.json
pydefect_print target_vertices.yaml
pydefect pc
# In the cpd.pdf figure, A means Ga-rich, B means N-rich
# You can also check defect formation energies (optional)
vise_util map -e Ga N
cd ~
vise_util map -e Ga N

```
To know how to read the CPD diagram and other diagrams - 
*Download and use the file on this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/GaN_Point_Defect_Presentation.pptx`

## Step-9: Creating supercell files and the required defect types and states
Create Supercell structure of the relaxed unit cell
```
cd ../defect
pydefect s -p ../unitcell/structure_opt/POSCAR
pydefect_print supercell_info.json
```
Incorporate vacancy defects
```
pydefect ds
```
Incorporate intersitials defects. This needs AECCAR0, AECCAR1, AECCAR2, and LOCPOT files generated by DOS calculation of the unit cell. Follow the following commands:
```
cp ../unitcell/dos/AECCAR0 .
cp ../unitcell/dos/AECCAR1 .
cp ../unitcell/dos/AECCAR2 .
cp ../unitcell/dos/LOCPOT .
pydefect_vasp le -v AECCAR{0,2} -i all_electron_charge
# in the following line: - i 1 2 means two intersititals
pydefect_util ai --local_extrema volumetric_data_local_extrema.json -i 1 2
pydefect ds
pydefect_print defect_in.yaml
```
(optional)
If does not work (and receive NotPrimitiveError, follow this:
    - replace the value of the CONTCAR file in '/unitcell/structure_opt/' file with 'Unitcell in the supercell_info.json'
    ```
    pydefect s -p ../unitcell/structure_opt/CONTCAR
    pydefect_util ai --local_extrema volumetric_data_local_extrema.json -i 1 2  
    ```
  - If the input structure is different from the standardized primitive cell, NotPrimitiveError is raised
  - To pop the interstitial sites, use>> pydefect pi -i 1 -s supercell_info.json
<br>
Incorporate impurity defects. I am using Si and Mg type p-type and n-type dopants.
```
pydefect ds
pydefect ds -d Si Mg
#If needed you can change the oxidation states of a material. For instance to add +4 oxidation state to Si you can use:
#pydefect ds --oxi_states Si 4
pydefect_print defect_in.yaml
```
## Step-10: Create Point-defect Supercell directories and run VASP calculation for defect-induced supercells
```
pydefect_vasp de
cp SPOSCAR ./perfect/POSCAR
pydefect_print defect_entry.json
```
Copy *srun.slurm* -supercell run.slurm scripts and run the defect-induced supercell calculation on VASP. Find the *srun.slrum* file on the later parts:
```
for i in */;do cd $i; vise vs -t defect -uis ENCUT 520.0 NSW 140 NCORE 32 EDIFFG -0.03; cd ../;done
for i in */;do cd $i; cp /storage/work/GaN/srun.slurm .; cd ../;done
for dir in */;do cd $dir; sbatch srun.slurm; cd ..; done
```
Parse the defect-induced supercell calculation results:
for i in */;do cd $i; vise vs -t defect -uis ENCUT 520.0 NSW 140 NCORE 32 EDIFFG -0.03; cd ../;done
for i in */;do cd $i; cp /storage/work/mvm7218/Slurm/srun.slurm .; cd ../;done
for dir in */;do cd $dir; sbatch srun.slurm; cd ..; done
```











Sbatch scripts (run.slurm): (line-66)
Sbatch scripts (srun.slurm): (line-249)
