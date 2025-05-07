# Please CITE This Work!
Point Defects Using VASP and PyDefect (DFT) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15358398.svg)](https://doi.org/10.5281/zenodo.15358398)

## Follow Youtube Playlist to use this GitHub Repository
[Point Defects Using VASP and PyDefect (DFT)](https://www.youtube.com/playlist?list=PLSm7ZQMDqBcdkODXc4n9LvCrBzmgtRQpA)

# Release v1.0.0 — “GaN Point‑Defect Toolkit”
**Date:** 2025‑05‑07

## 🚀 Highlights

- **Pristine (defect‑free) GaN workflows**  
  Located in `Without_defect_GaN_DFT_VASP_Slurm/`
- **Defective GaN workflows**  
  Located in `With_defect_GaN_DFT_VASP_Slurm_PyDefect/`
- **Helper scripts & utilities**  
  Located in `others/`
- **Comprehensive documentation** in `README.md`
- **Open‑source MIT license**  
 

## 📖 Getting Started

1. **Clone the repo**  
   ```bash
   git clone https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect.git
   cd GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect
   ```
2. **Set up your environment**  
   - VASP (≥5.4) with projector‑augmented waves  
   - Python ≥3.8  
     ```bash
     pip install pydefect numpy pandas matplotlib
     ```
3. **Run a pristine GaN job**  
   ```bash
   cd Without_defect_GaN_DFT_VASP_Slurm
   sbatch run_pristine_gaN.slurm
   ```
4. **Generate & analyze defects**  
   ```bash
   cd With_defect_GaN_DFT_VASP_Slurm_PyDefect
   python generate_defects.py
   sbatch submit_defects.slurm
   python analyze_defects.py
   ```

## 📝 Contributing

Contributions, bug reports, and feature requests are welcome! Fork the repo, create a branch, commit your changes, and open a PR.

## 🛣️ Roadmap & Known Issues

- Some charge‑state dielectric corrections still require manual tuning  
- Planned: Hybrid‑DFT (HSE06) support, automated HPC modules (LSF, PBS)  

## 📄 License

Released under the [MIT License](./LICENSE). The original release and repository of the PyDefect tutorial belong to the Kumagi Group. Please follow their official site: [click here](https://kumagai-group.github.io/pydefect/index.html)
