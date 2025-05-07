# CITE This Work!
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15358398.svg)](https://doi.org/10.5281/zenodo.15358398)

## Follow Youtube Playlist to use this GitHub Repository
[Point Defects Using VASP and PyDefect (DFT)](https://www.youtube.com/playlist?list=PLSm7ZQMDqBcdkODXc4n9LvCrBzmgtRQpA)
![image](https://github.com/rayid-mojumder/GaN_Point_Defect_Investigation_with_DFT_VASP-PyDefect/assets/39030809/588d2b4a-6200-402a-b8f6-e7e1f82a55c2)

# Release v1.0.0 — “GaN Point‑Defect Toolkit”
**Date:** 2025‑05‑07

A first stable release of the **GaN Point‑Defect Investigation** framework, combining VASP-based DFT workflows with PyDefect‑powered defect analysis.

## 🚀 Highlights

- **Pristine (defect‑free) GaN workflows**  
  Located in `Without_defect_GaN_DFT_VASP_Slurm/`
- **Defective GaN workflows**  
  Located in `With_defect_GaN_DFT_VASP_Slurm_PyDefect/`
- **Helper scripts & utilities**  
  Located in `others/`
- **Comprehensive documentation** in `README.md`
- **Open‑source MIT license**  

## 🗂️ Changelog

### Added
- Initial project scaffold and directory structure  
- SLURM submission templates, example VASP input decks  
- PyDefect configuration files and analysis notebooks  
- Helper scripts for batch‑processing and automated post‑processing  

### Changed
- Renamed raw scripts → organized under `others/` for clarity  
- Enhanced README with detailed parameter explanations  

### Fixed
- Corrected POSCAR supercell dimensions for 2×2×2 GaN  
- Addressed INCAR convergence settings for charged defect calculations  

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

Released under the [MIT License](./LICENSE).

## Copyright
* Md. Rayid Hasan Mojumder, Penn State, USA
