# Follow Youtube Playlist to use this GitHub Repository
[Point Defects Using VASP and PyDefect (DFT)](https://www.youtube.com/playlist?list=PLSm7ZQMDqBcdkODXc4n9LvCrBzmgtRQpA)
![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/588d2b4a-6200-402a-b8f6-e7e1f82a55c2)

=========================

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
mkdir POT_GGA_PAW_PBE_54
#now upload the potpaw_PBE.54.tar.gz file to /storage/work/mvm7218/
tar -xzvf potpaw_PBE.54.tar.gz -C /storage/work/mvm7218/POT_GGA_PAW_PBE_54
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
* Whenever there is the command *sbatch some_name.slurm*, this means it's a command used with the Slurm package to execute VASP calculation. If you are using MPI-run or another package, use the execution script for that package.*Download *run.slurm* and *srun.slurm* files from this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/` path. Please update that script based on your system parameters. Upload the slurm scripts (*run.slrum* and *srun.slurm*) in the `/GaN` directory, or you can create it later on.
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
```
```
sbatch run.slurm
```
```
vise plot_band
grep E-fermi OUTCAR | tail -1
```
```
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
```
```
sbatch run.slurm
```
```
vise plot_dos
grep E-fermi OUTCAR | tail -1
```
```
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
```
```
sbatch run.slurm
```
```
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
See the `unitcell.yaml` file to get the bandgap value (cbm - vbm = bandgap)
### At this point of the simulation, you must do the following 
*Modify and Correct the mprester.py and mp_tools.py files* [Must do this additional stage]
*Download *mprester.py* and *mp_tools.py* files from this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/` path. Or, you can use the updated file here - https://github.com/materialsproject/api/blob/main/mp_api/client/mprester.py

Find the *DEFAULT_API_KEY* line and hardcode the materials project key to the default API key (like the following). Here 'ksrEbuvP0ucRZAas11zIz8y7lii15gpy' is my own Materials Project API key.
<br>*DEFAULT_API_KEY = environ.get("MP_API_KEY", "ksrEbuvP0ucRZAas11zIz8y7lii15gpy")*
```
#Go to the mprester.py file. In the following command, replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/mp_api/client/mprester.py
# Replace the *mprester.py* file's content with the downloaded one
nano mprester.py
```

```
#Go to the mp_tools.py file. In the following command, replace the first '/storage/home/mvm7218/' part with your own directory path
cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/pydefect/util/mp_tools.py
# Replace the *mp_tools.py* file's content with the downloaded one
nano mp_tools.py
```

## Step-8: Create competing phases and run VASP calculation of the competing phases
If only considerring vacancy and/or intersitials: create competing phases for GaN. This means all the possible scenarios with these atoms; in this case, there could be - GaN, Ga, and N. 
Move to 'cpd/' directory and run the command
```
cd ~
# In the following command, replace the first /storage/work/' part with your own directory path
cd /storage/work/GaN/cpd
```
```
pydefect_vasp mp -e Ga N --e_above_hull 0.0005
pydefect_vasp mp -e Ga --e_above_hull 0.0005
pydefect_vasp mp -e N --e_above_hull 0.0005
```
If also considering impurities: consider the impurities - Mg, Si, all the atoms used in the structure should be added here. 
```
  pydefect_vasp mp -e Ga N --e_above_hull 0.0005
  pydefect_vasp mp -e Ga --e_above_hull 0.0005
  pydefect_vasp mp -e N --e_above_hull 0.0005
  pydefect_vasp mp -e Si --e_above_hull 0.0005
  pydefect_vasp mp -e Mg --e_above_hull 0.0005
  pydefect_vasp mp -e Ga N Mg Si --e_above_hull 0.0005
```
Create VASP files for these competing phases and run the calculation
```
for i in *_*/;do cd $i; vise vs -uis ENCUT 520.0; cd ../;done
#Copy run.slurm to each competing phase folder and run VASP calculation
for dir in */;do cd $dir; cp ../../unitcell/band/run.slurm .; sbatch run.slurm; cd ../;done 
```
Generate the *composition_energies.yaml* file - which collects the total energies per calculated formula. Note, *pydefect_print* command is used to visualize the *.json* or *.yaml* files
```
pydefect_vasp mce -d */
pydefect_print composition_energies.yaml
```
Create *relative_energies.yaml* and *standard_energies.yaml*. Read the files and store the energies for better understanding and future reference. The first command also generates *convex_hull.pdf* convex hall diagram.
```
pydefect sre
  pydefect_print standard_energies.yaml
  pydefect_print relative_energies.yaml
```
Make information on the CPD - creates *chem_pot_diag.json* and *target_vertices.yaml* files. Quickly read the files and its contents. Finally, plot the CPD diagram - creates *cpd.pdf*
```
  pydefect cv -t GaN
  pydefect_print chem_pot_diag.json
  pydefect_print target_vertices.yaml
  pydefect pc
```
* In the *cpd.pdf* plot, there will be points A, B, etc. meaning which element is Rich. In our case point-A means Ga-rich, point-B means N-rich. Rich means the chemical potential of that one is higher than the other.
* Remember this A,B, etc. points. Because these points will be used to plot chemical potential diagram (CPD)

To know how to read the CPD diagram and other diagrams - 
*Download and use the file on this Github Repo directory - `GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/With_defect_GaN_DFT_VASP_Slurm_PyDefect/GaN_Point_Defect_Presentation.pptx`

## Step-9: Creating supercell files and incorporate the required defect types and states
Create Supercell structure of the relaxed unit cell
```
cd ../defect
pydefect s -p ../unitcell/structure_opt/POSCAR
pydefect_print supercell_info.json
# If one wants to know the conventional cell run the following (optional)
# vise si -p ../unitcell/structure_opt/POSCAR -c
```
Incorporate defects (antisites and vacancies)
```
pydefect ds
```
To see the antisites created by the above command use thisL:
```
pydefect_print defect_in.yaml
```
Incorporate impurity defects. I am using substitutional defect species (n-type: Si, p-type: Mg).
```
pydefect ds
pydefect ds -d Si Mg
#If needed you can change the oxidation states of a material. For instance to add +4 oxidation state to Si you can use:
#pydefect ds --oxi_states Si 4
pydefect_print defect_in.yaml
```
Incorporate intersitials defects. Generate volumetric data, e.g., AECCAR and LOCPOT, based on the standardized primitive cell, already done in DOS calculation. Get AECCAR0, AECCAR1, AECCAR2, and LOCPOT files generated by DOS calculation of the unit cell. See the local minima of the charge density. This creates *volumetric_data_local_extrema.json*
Follow the following commands:
```
cp ../unitcell/dos/AECCAR0 .
cp ../unitcell/dos/AECCAR1 .
cp ../unitcell/dos/AECCAR2 .
cp ../unitcell/dos/LOCPOT .
pydefect_vasp le -v AECCAR{0,2} -i all_electron_charge
```
If we are using two interstitial sites, use this part -> -i 1 2. Then, Rebuild the *defect_in.yaml* file - for  adding interstitials to antisite and vacancy defects.  Then, build the *defect_in.yaml* file - for  antisite and vacancy defects. Read the *defect_in.yaml* file and store details for future reference.
```
pydefect_util ai --local_extrema volumetric_data_local_extrema.json -i 1 2
pydefect ds
pydefect_print defect_in.yaml
```
(optional) <start>
If does not work (and receive NotPrimitiveError, follow this:
    - replace the value of the POSCAR file in '/unitcell/structure_opt/' file with 'Unitcell in the supercell_info.json'
    ```
    pydefect s -p ../unitcell/structure_opt/POSCAR
    ```
    - then re-run all the steps from the start of Step-9
    
If the input structure is different from the standardized primitive cell, NotPrimitiveError is raised
To pop the interstitial sites, use>> pydefect pi -i 1 -s supercell_info.json
<end>

## Step-10: Create Point-defect Supercell directories and run VASP calculation for defect-induced supercells
The following commands create *defect_entry.json* file in each directory. When required, go to the specific defect directory and read and store the data for future reference and analysis. Copy the perfect supercell structure to the  `/perfect/` folder.
```
pydefect_vasp de
cp SPOSCAR ./perfect/POSCAR
#if required, run the following command in each defect directory to get that specific defect supercell info
pydefect_print defect_entry.json

```
```
(optional)       
#If we want to treat complex defects run the following command
pydefect_vasp_util de -d . -p ../perfect/POSCAR -n complex_defect
```
Copy *srun.slurm* -supercell run.slurm scripts and run the defect-induced supercell calculation on VASP. Recommendation: use 4 CPU, 256 GB ram, 32 tasks per cpu:
```
for i in */;do cd $i; vise vs -t defect -uis ENCUT 520.0 NSW 140 NCORE 32 EDIFFG -0.03; cd ../;done
for i in */;do cd $i; cp /storage/work/GaN/srun.slurm .; cd ../;done
for dir in */;do cd $dir; sbatch srun.slurm; cd ..; done
```
## Step-11: Parse the defect-induced supercell calculation results
Generate the *calc_results.json* that contains the first-principles calculation results related to the defect properties. Generate *calc_results.json* file in all the calculated directories 
```
pydefect_vasp cr -d *_*/ perfect
cd perfect
pydefect_vasp cr -d .
cd ..
```
## Step-12: Corrections of defect formation energies in finite-size supercells
The total energies for charged defects are not properly estimated due to interactions between a defect, its images, and background charge. The following command creates *correction.json* and *correction.pdf* files in each of the defect directory
```
pydefect efnv -d *_*/ -pcr perfect/calc_results.json -u ../unitcell/unitcell.yaml
```
The following command creates *defect_structure_info.json* files to analyze the defect local structures [in each defect directory]
```
pydefect dsi -d *_*/
```
The following command creates VESTA file (defect.vesta) for analyzing the defect structure files [in each defect directory]
```
pydefect_util dvf -d *_*/ 
```
## Step-13: Check defect eigenvalues and band-edge states in supercell calculations (Optional stage)
* Defects with (1) deep localized states inside band gap, (2) band edges, (3) without defect states inside the band gap or near band edges
* Analyze the eigenvalues and band-edge states 
- Generates the *perfect_band_edge_state.json* files to show the information on the eigenvalues and orbital information of the VBM and CBM in the perfect supercell. [parent defect directory]
```
  pydefect_vasp pbes -d perfect
```
- Create *band_edge_orbital_infos.json* files at defect directories [in each defect directories, creates *eigenvalues.pdf* file]
```
  pydefect_vasp beoi -d *_* -pbes perfect/perfect_band_edge_state.json
```
- Generate the *edge_characters.json* file with the band edge states (bes) command [in each defect directory]
```
pydefect_vasp bes -d *_*/ -pbes perfect/perfect_band_edge_state.json 
# If the previous command give error, instead of the above command, it can work manually by the following command
for dir in *_*/; do cd $dir; pydefect bes -d . -pbes ../perfect/perfect_band_edge_state.json; cd ..; done
```

## Step-14: Plot defect formation energy diagram
* Defect formation energies require - the band edges, chemical potentials of the competing phases, and total energies of the perfect and defective supercells
* Creates *defect_energy_info.yaml* in each of the defect directories
```
pydefect dei -d *_*/ -pcr perfect/calc_results.json -u ../unitcell/unitcell.yaml -s ../cpd/standard_energies.yaml
```
* Create a *defect_energy_summary.json* file with the defect_energy_summary (= des) sub-command. [in the parent defect folder]
```
  pydefect des -d *_*/ -u ../unitcell/unitcell.yaml -pbes perfect/perfect_band_edge_state.json -t ../cpd/target_vertices.yaml
```
* Create the *calc_summary.json* file with the calc_summary (= cs) sub-command [in the parent defect directory]
```
  pydefect cs -d *_*/ -pcr perfect/calc_results.json
```
* Defect formation energies are plotted as a function of the Fermi level with the plot_defect_formation_energy (= pe) sub-command.
* Here, after "-l" command, A or B is coming from the cpd diagram. A = Ga-rich, B = N-rich condition
```
  pydefect plot_defect_formation_energy -d defect_energy_summary.json -l A --allow_shallow -y -2 10 
  pydefect plot_defect_formation_energy -d defect_energy_summary.json -l B --allow_shallow -y -2 10
```
[Optional]: If you want to extend your PBE formation energy plot to the HSE limit do the following:
- go to **/unitcell/unitcell.yaml** file then open it in text editor and change the VBM and CBM to your HSE value
- Re-run all the codes in Step-14
------------ END OF THE CODE ----------------------
You can close everything here. But if you want to know more functionalities of VASP please read the suggestions part too. Thank you.

## ------------ Few Suggestions ----------------------

> Suggestion-1: While Calculating Formation Energy Diagram (customize parameters from help option):
```
pydefect pe -d defect_energy_summary.json
pydefect plot_defect_formation_energy -h
```
This gives the output:
![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/ef41c17e-881d-4bef-afe5-f3a6e5a50b0c)

```
Examples:
pydefect plot_defect_formation_energy -d defect_energy_summary.json -l A --allow_shallow -y -30 10 --no_add_charges
pydefect plot_defect_formation_energy -d defect_energy_summary.json -l B --allow_shallow -y -30 10 --no_label_line
pydefect plot_defect_formation_energy -d defect_energy_summary.json -l B --allow_shallow  -y -30 10
```

> Suggestion-2: Seeking help in Pydefect:
pydefect_vasp [the_command_key] -h 
pydefect_vasp [the_command_key] --help

Examples:
```
pydefect_vasp beoi -h
pydefect pe --help
```

## ------------ Some random Stuffs ----------------------

> Some random Stuffs:

>> defect_vasp_run.sh:
```
for dir in */; do
    cd $dir
    # Submit the job and capture the job ID
    JOB_ID=$(sbatch srun.slurm | awk '{print $4}')
    cd ..

    # Wait for the job to complete
    echo "Waiting for job $JOB_ID to complete..."
    while squeue | grep -q "$JOB_ID"; do
        sleep 10  # Check every 10 seconds
    done
    echo "Job $JOB_ID completed."
done
```
>> defect_vasp_run_parallel.sh
```
for dir in */; do
    cd $dir
    # Submit the job and capture the job ID
    JOB_ID=$(sbatch srun.slurm | awk '{print $4}')
    cd ..

    # Wait for the job to complete
    echo "Waiting for job $JOB_ID to complete..."
done
```
>> check_convergence.sh
```
#!/bin/bash

# Loop through directories
for dir in */; do
  # Check if OUTCAR exists
  if [[ -f "${dir}/OUTCAR" ]]; then
    # Check for ionic convergence
    if grep -q "reached required accuracy - stopping structural energy minimisation" "${dir}/OUTCAR"; then
      echo "Ionic convergence achieved in ${dir}"
    else
      echo "Ionic convergence NOT achieved in ${dir}"
    fi
  else
    echo "OUTCAR not found in ${dir}"
  fi
done
```
>> Correct any INCAR settings - remove a line, add new line, etc from command
```
for i in */;do cd $i; sed -i '35d' INCAR; sed -i '36d' INCAR; echo "EDIFFG  =  -0.01" >> INCAR; echo "NSW = 100" >> INCAR; cd ../;done
```


