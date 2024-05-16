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
* You will find the batch scripts at the end of this step-by-step. Please update that script based on your system parameters. Upload the slurm packages in the `/GaN` directory, or you can create it later on.
Let's calculate the point defects!
 
## Step-6: Relax Calculation and save relaxed POSCAR file for further calculations
```
cd unitcell/structure_opt
vise vs
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
vise vs -t band -d ../structure_opt
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
vise vs -t dos -d ../structure_opt -uis LVTOT True LAECHG True KPAR 1
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
vise vs -t dielectric_dfpt -d ../structure_opt
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
## At this point of simulation, you must do the following - *Modify and Correct the mprester.py and mp_tools.py files*
*Download *mprester.py* and *mp_tools.py* files from this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/` path
```
#Go to the mprester.py file. In the following command replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/mp_api/client/mprester.py
# Replace the *mprester.py* file's content with the downloaded one
nano mprester.py
```
Find the *DEFAULT_API_KEY* line and hardcode the materials project key to the default API key (like the following). Here 'ksrEbuvP0ucRZAas11zIz8y7lii15gpy' is my own Materials Project API key.
<br>*DEFAULT_API_KEY = environ.get("MP_API_KEY", "ksrEbuvP0ucRZAas11zIz8y7lii15gpy")*
```
#Go to the mp_tools.py file. In the following command replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/pydefect/util/mp_tools.py
# Replace the *mp_tools.py* file's content with the downloaded one
nano mp_tools.py
```

















Sbatch scripts: (line-66)
