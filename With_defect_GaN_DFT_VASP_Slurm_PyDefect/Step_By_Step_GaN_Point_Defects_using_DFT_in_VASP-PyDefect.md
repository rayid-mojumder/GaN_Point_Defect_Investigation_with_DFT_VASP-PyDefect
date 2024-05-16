# GaN Point Defect Formation Energy Calculation Using VASP and PyDefect [May 16, 2024]
This entire step-by-step guide is a simplified and comprehensive guide to generating point defect formation energy using the PyDefect package [[Official site](https://kumagai-group.github.io/pydefect/index.html)] and VASP. 
* All the issues related to implementing the codes have been solved here. You can just copy and paste the codes with your own materials, and it should work perfectly. Here, I am using GaN as an example. 
* If you are new to VASP, please first go to the "GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/Without_defect_GaN_DFT_VASP_Slurm" directory to become familiar with it.
* *You need a Linux environment (could be a local PC or supercomputing server) and already installed Python3 (also Pip) and VASP*.
* Also, you need to have a Pseudopotential file. In my case, I have *potpaw_PBE.54.tar.gz*
* I am using Slurm to run the package on the remote server; if you are using MPIrun or something else, please adjust the VASP run scripts. Either way, you can follow this guide.
* Basic Workflow (from Official PyDefect site): ![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/a20eeb7a-2a10-4cfa-94e1-341b1ce64f07)
* Basic Directory Tree (From Official PyDefect site): ![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/0e62eff1-ac7e-4db0-8565-a6f873854168)

** *Let's begin....* **

##  Step-1: Open Python3 terminal and install PyDefect and VISE
```bash
pip install pydefect
pip install vise
```

