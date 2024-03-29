[mvm7218@p-sc-2344 structure_opt]$ cd ~
[mvm7218@p-sc-2344 ~]$ nano ./.config/.pmgrc.yaml


Step-1: Install Python3. Run Python shell and install packages
  pip install pydefect
  pip install vise

Step-2: Extract POTCAR files in a directory
  cd /storage/work/mvm7218/
  mkdir potpaw_PBE.54
  tar -xzvf  potpaw_PBE.54.tar.gz -C /storage/work/mvm7218/potpaw_PBE.54

Step-3: Edit .pmgrc.yaml file and add POTCAR and Materials project API
  cd ~
  nano .pmgrc.yaml (or nano .config/.pmgrc.yaml) (if error with .pmgrc.yaml, then use>> find . -name .pmgrc.yaml -type f -exec readlink -f \{\} \;)
    PMG_DEFAULT_FUNCTIONAL: PBE_54
    PMG_MAPI_KEY: ksrEbuvP0ucRZAas11zIz8y7lii15gpy
    PMG_VASP_PSP_DIR: /storage/work/mvm7218/

Step-4: Create the directory tree
<project_name>
 │
 ├ pydefect.yaml
 ├ vise.yaml
 │
 ├ unitcell/ ── structure_opt/
 │            ├ band/
 │            ├ dielectric/
 │            └ dos/
 │
 ├ cpd/ ──── <competing_phase 1>
 │       ├── <competing_phase 2>
 │           ....
 │
 └ defect/ ── perfect/
            ├─ Va_X_0/
            ├─ Va_X_1/
            ├─ Va_X_2/
             ...

[use GaN (project name) folder as the base]  
  mkdir GaN
  cd GaN
  mkdir unitcell
  mkdir unitcell/structure_opt
  mkdir unitcell/band
  mkdir unitcell/dielectric
  mkdir unitcell/dos
  mkdir unitcell/relax
  mkdir cpd
  mkdir defect
  mkdir defect/perfect

Step-5: Download a pristine bulk unitcell from Materials Project and move it to the 'unitcell/structure_opt/' folder
Step-6: Calculate relaxation (point-defect calculations are generally performed at the theoretically relaxed structure)

    cd unitcell/structure_opt
    vise vs # creates INCAR, POTCAR, and KPOINTS for the relax calculation

  Run the slurm script (run.slurm) with 'vasp standard' to calculate the relax calculation from the 'structure_opt' folder
    sbatch run.slurm
  Copy the all the files to the 'unitcell/relax' folder for future reference
    cp * ../relax

  Remove all files in the 'unitcell/structure_opt' folder, create a new blank 'POSCAR' and 'run.slurm' file
    rm *
    touch POSCAR
    touch run.slurm

Step-7: copy 'relax/CONTCAR' contents to the 'structure_opt/POSCAR' (not needed), 'relax/run.slurm' contents to the 'structure_opt/run.slurm'
    cp ../relax/CONTCAR POSCAR (not needed)
    cp ../relax/run.slurm run.slurm

Step-8: We create 'band/', 'dos/' and 'dielectric/' in 'unitcell/' and copy POSCAR from 'unitcell/structure_opt/'. 
    mkdir ../band
    mkdir ../dos
    mkdir ../dielectric
    cp POSCAR -r ../band
    cp POSCAR -r ../dos
    cp POSCAR -r ../dielectric

  # Use the following procedure for each band, dos, and dielectric directory:
  Move to 'unitcell/band' directory and run the following comamnd
    cd ../band
    vise vs -t band -d ../structure_opt
  Now go to 'structure_opt' and run vasp-band calculation
    cd ../structure_opt
    sbatch run.slurm
  Copy the band calculation file to the 'unitcell/band/' directory
    cp * -r ../band/

  for 'unitcell/dos' and 'unitcell/dielectric' directory use the following commands
    vise vs -t dos -d ../structure_opt -uis LVTOT True LAECHG True KPAR 1
    vise vs -t dielectric_dfpt -d ../structure_opt

Step-9: Gathering unitcell information related to point-defect calculations
  move to the 'unitcell' directory and run the command
  cd ..
  pydefect_vasp u -vb band/vasprun.xml -ob band/OUTCAR -odc dielectric/OUTCAR -odi dielectric/OUTCAR -n GaN

Step-10: if required, open a python terminal and upgrade the package
  pip install --upgrade pydefect
  pip install --upgrade vise
  pip install --upgrade mp-api
  
Step-11: modify and correct the files
  ### download the following file and replace the 'mprester.py' file's content
  # https://github.com/materialsproject/api/blob/main/mp_api/client/mprester.py
  cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/mp_api/client/mprester.py
  # in 'mprester.py' file hardcode the materials project ket to the default API key 
  # line>> DEFAULT_API_KEY = environ.get("MP_API_KEY", "ksrEbuvP0ucRZAas11zIz8y7lii15gpy"))
  ### download the following file (added at the last part of this instruction set) and replace the 'mp_tools.py' file's content
  cd /storage/home/mvm7218/.local/lib/python3.8/site-packages/pydefect/util/mp_tools.py

Step-11: Calculation of competing phases
  move to 'cpd/' directory and run the command
  cd ../cpd
  pydefect_vasp mp -e Ga N --e_above_hull 0.0005
  pydefect_vasp mp -e Ga --e_above_hull 0.0005
  pydefect_vasp mp -e N --e_above_hull 0.0005
  
Step-12: Create VASP files for each competing phases, with the same ENCUT (1.3x max energy value)
  for i in *_*/;do cd $i; vise vs -uis ENCUT 400.0; cd ../;done

Step-13: Create a symbolic link of these competing phases with the pristine structure (if used same ENCUT), can use previously calculated one
  ln -s ../unitcell/relax GaN_unitcell (if ENCUT of relax is same as the competing phases. in this case delete 'GaN_mp-804' file, otherwise, do not link just use the three folders created by in step-11,12)

Step-14: Copy-paste 'run.slurm' file in each of the three competing phase folders and run vasp calculation in each directory
  cp ../unitcell/band/run.slurm -r GaN_mp-804
  cp ../unitcell/band/run.slurm -r Ga_mp-142
  cp ../unitcell/band/run.slurm -r N_mp-568348
  cd GaN_mp-804
  sbatch run.slurm
  cd ..
  cd Ga_mp-142
  sbatch run.slurm
  cd ..
  cd P_mp-568348
  sbatch run.slurm  

Step-15: Generate the 'composition_energies.yaml' file, which collects the total energies per calculated formula
  #return to '/cpd' folder
  cd ..
  pydefect_vasp mce -d *_*/

Step-16: Create 'relative_energies.yaml' and 'standard_energies.yaml'
  pydefect sre

Step-17: Make information on the CPD
  pydefect cv -t GaN
  #To plot the diagram
  pydefect pc

Step-18: Check the defect formation energies sooner (avoiding laborious CPD calculation process, steps 11-17) based on the MPD [optional]
  #prepare atom calculation directories
  vise_util map -e Ga N
  #install BoltzTraP2
  cd ~
  pip install BoltzTraP2
  #cd to the '/cpd' directory
  vise_util map -e Ga N

Step-19: Create files related to a supercell for defect incorporation
  #go to '/defect/' directory
  cd /storage/work/mvm7218/GaN/defect
  #copy the CONTCAR obtained after relax calcultion to the 'structure_opt/' directory [use primitive POSCAR, if error occurs with CONTCAR]
  cp ../unitcell/relax/CONTCAR ../unitcell/structure_opt
  #create supercell POSCAR file (SPOSCAR)
  pydefect s -p ../unitcell/structure_opt/CONTCAR
  #If one wants to know the conventional cell, type
  vise si -p ../unitcell/structure_opt/CONTCAR -c
  #Generate readable command lines from json files
  pydefect_print supercell_info.json

Step-20: Incoporate defects
  #build the 'defect_in.yaml' file - for  antisite and vacancy defects
  pydefect ds
  #add substituted defect species (n-type: Si, p-type: Mg)
  pydefect ds -d Si Mg
  #to manually set the oxidation state of Si to 4: pydefect ds --oxi_states Si 4

Step-21: Decision of interstitial sites
  #generate volumetric data, e.g., AECCAR and LOCPOT, based on the standardized primitive cell, already done in DOS calculation
  cp ../unitcell/dos/AECCAR0 .
  cp ../unitcell/dos/AECCAR1 .
  cp ../unitcell/dos/AECCAR2 .
  cp ../unitcell/dos/LOCPOT .
  #see the local minima of the charge density 
  pydefect_vasp le -v AECCAR{0,2} -i all_electron_charge
  pydefect_print volumetric_data_local_extrema.json
  #add the two interstitial sites
  pydefect_util ai --local_extrema volumetric_data_local_extrema.json -i 1 2 [did not work, let's proceed without intersitials]
  #If the input structure is different from the standardized primitive cell, NotPrimitiveError is raised
  #To pop the interstitial sites, use>> pydefect pi -i 1 -s supercell_info.json

Step-22: Create point-defect calculation directories
  pydefect_vasp de
  #see the 'defect_entry.json' file to see information about a point defect in each directory>> cd 'foldername' >> pydefect_print defect_entry.json
  #avoid treating complex defects. skipping generation of defect_entry.json

Step-23: Parsing supercell calculation results
  #create the vasp input files
  for i in */;do cd $i; vise vs -t defect ; cd ../;done
  #copy sbatch script to all the folders (use 4 cpu, 256 GB ram, 32 tasks per cpu)
  for i in */;do cd $i; cp ../srun.slurm .; cd ../;done
  #increase parallel computing, discard KPAR=1 line (line #33) and append NCORE tag at the end of INCAR file
  for i in */;do cd $i; sed -i '33d' INCAR; echo "NCORE=32" >> INCAR; cd ../;done
  #execute the bash command to loop through each directory, run sbatch file, and wait till the job is complete
  #defect_vasp_run.sh is given in later portion
  chmod +x defect_vasp_run.sh
  dos2unix defect_vasp_run.sh
  ./defect_vasp_run.sh


Step-24: Corrections of defect formation energies in finite-size supercells



































[mvm7218@p-sc-2344 structure_opt]$ cd 
[mvm7218@p-sc-2344 ~]$ find . -name .pmgrc.yaml -type f -exec readlink -f \{\} \;
/storage/home/mvm7218/.config/.pmgrc.yaml
/storage/home/mvm7218/.pmgrc.yaml
[mvm7218@p-sc-2344 ~]$ cd /storage/work/mvm7218/GaN_002/unitcell/structure_opt
[mvm7218@p-sc-2344 structure_opt]$ vise vs
   INFO: -- Settings from vise.yaml:
   INFO: 
   INFO: Creating VASP input set in /storage/work/mvm7218/GaN_002/unitcell/structure_opt...
   INFO: K-point density is set to 5.0.
[mvm7218@p-sc-2344 structure_opt]$ python3
Python 3.8.8 (default, Apr 13 2021, 19:58:26) 
[GCC 7.3.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pkg_resources
>>> distribution = pkg_resources.get_distribution('pydefect')
>>> package_location = distribution.location
>>> print(package_location+'/pydefect/')
/storage/home/mvm7218/.local/lib/python3.8/site-packages/pydefect/
>>> 


vise vs -t band -d ../structure_opt
vise vs -t dos -d ../structure_opt -uis LVTOT True LAECHG True KPAR 1
vise vs -t dielectric_dfpt -d ../structure_opt












#################### run.slurm file #############################
#!/bin/bash

#SBATCH --job-name=GaN
##SBATCH --account=open
##SBATCH --partition=open
#SBATCH --account=mjj5508_b    ##For Prof. Mia Jin's access point
#SBATCH --partition=sla-prio   ##For Prof. Mia Jin's access point
#SBATCH --mem=32GB
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
##SBATCH --cpus-per-task=2

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
#sbatch run_dos.slurm





################# file content - mp_tools.py ##########################

# -*- coding: utf-8 -*-

from typing import List

from pydefect.defaults import defaults
from pymatgen.core import Element
# from pymatgen.ext.matproj import MPRester, MPRestError
from mp_api.client import MPRester, MPRestError
from vise.util.logger import get_logger
from itertools import combinations, chain

elements = [e.name for e in Element]


logger = get_logger(__name__)


class MpQuery:
    def __init__(self,
                 element_list: List[str],
                 e_above_hull: float = defaults.e_above_hull,
                 properties: List[str] = None):
        # API key is parsed via .pmgrc.yaml
        with MPRester() as m:
            # Due to mp_decode=True by default, class objects are restored.
            excluded = list(set(elements) - set(element_list))
            try:
                default_properties = ["task_id", "full_formula", "final_energy",
                                      "structure", "spacegroup", "band_gap",
                                      "total_magnetization", "magnetic_type"]
                criteria = (
                    {"elements": {"$in": element_list, "$nin": excluded},
                     "e_above_hull": {"$lte": e_above_hull}})
                self.materials = m.query(
                    criteria=criteria,
                    properties=properties or default_properties)
            except:
                logger.info("Note that you're using the newer MPRester.")
                default_fields = ["material_id", "formula_pretty", "structure",
                                  "symmetry", "band_gap", "total_magnetization",
                                  "types_of_magnetic_species"]
                properties = properties or default_fields
                self.materials = m.materials.summary.search(
                    chemsys='-'.join(element_list),
                    #elements=element_list,
                    #exclude_elements=excluded,
                    energy_above_hull=(-1e-5, e_above_hull),
                    fields=properties)


class MpEntries:
    def __init__(self,
                 element_list: List[str],
                 e_above_hull: float = defaults.e_above_hull,
                 additional_properties: List[str] = None):
        excluded = list(set(elements) - set(element_list))
        criteria = ({"elements": {"$in": element_list, "$nin": excluded},
                     "e_above_hull": {"$lte": e_above_hull}})
        with MPRester() as m:
            self.materials = m.get_entries(
                criteria, property_data=additional_properties)


######################### defect_vasp_run.sh ##########################

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



########################## Suggestions ##################

execute command from the basic terminal, not jupyter terminal
