# Convergence Test
In Density Functional Theory (DFT) calculations using the Vienna Ab initio Simulation Package (VASP), ensuring the convergence of the calculations with respect to the plane-wave cutoff energy (**ENCUT**) and the **K-point** mesh is crucial for obtaining reliable results. Here's a detailed look at these two types of convergence tests:

## K-point Convergence Test:
The k-point mesh determines the sampling of the Brillouin zone. Insufficient k-point sampling can lead to inaccurate results, especially for properties that are sensitive to the electronic structure near the Fermi level.

### How to perform a K-point Convergence Test:
* Begin with a relatively coarse k-point mesh and calculate the property of interest (e.g., total energy, band structure).
* Incrementally increase the density of the k-point mesh (e.g., 2x2x2, 3x3x3, 4x4x4, etc.) and perform the calculation at each step.
* Monitor the property of interest as you increase the k-point density. When the change in the property between successive k-point meshes is below a chosen threshold (e.g., a few meV per atom for total energy), the calculation is considered converged with respect to k-points.

### Best Practices:
* Always ensure that the k-point grid is centered at the Gamma point for better accuracy.
* Utilize symmetry reduction if applicable to reduce computational effort.
* For metals or systems with small band gaps, a denser k-point mesh might be necessary due to rapid changes in electronic states near the Fermi level.

## ECUT Convergence Test (Plane-wave Cutoff Energy):
The plane-wave cutoff energy (ENCUT) determines the kinetic energy limit for the plane waves used in expanding the wave functions. Lower cutoff values lead to faster computations but can compromise accuracy.

### How to perform an ECUT Convergence Test:
* VASP recommends starting with the maximum ENMAX or ENMIN value among all the POTCAR files used in the calculation. However, testing for convergence is essential.
* Start the test with the recommended ENCUT and increase it in steps (e.g., 25 eV increments).
* At each step, compute the property of interest.
* Observe how the property changes with increasing ENCUT. When the property variation falls below a chosen threshold (again, perhaps a few meV per atom for total energy), you can consider the calculation converged with respect to ENCUT.

### Best Practices:
* After determining a converged ENCUT, it's common practice to add a small buffer (e.g., 10-20% extra) to ensure that the results are well within the converged range.
* Be aware that higher ENCUT values significantly increase computational time and memory requirements.
* Check the VASP manual or literature for typical ENCUT values for similar systems or materials as a reference point.

In summary, ensuring convergence in both k-points and ENCUT is fundamental for achieving reliable DFT results with VASP. These convergence tests, while increasing computational time upfront, are crucial for validating the accuracy of your simulations.
