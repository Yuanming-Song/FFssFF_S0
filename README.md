# FFssFF_S0: Phase Separation Analysis Using S0 Method

This project investigates phase separation in FFssFF (Fragment-based solvation of Flexible molecules in Flexible molecules) systems using the S0 method developed by [Cheng et al.](https://github.com/BingqingCheng/S0).

## Overview

The S0 method enables computation of chemical potentials from structure factors in molecular simulations. This implementation specifically focuses on analyzing phase separation behavior in FFssFF systems by:
1. Processing FFssFF trajectory data to extract relevant structural information
2. Computing structure factors for selected components (SP5 beads and water)
3. Analyzing phase separation tendencies through chemical potential calculations

## Prerequisites

- VMD (Visual Molecular Dynamics)
- Python 3.x with packages:
  - numpy
  - scipy
  - matplotlib
  - jupyter

## Directory Structure

```
.
├── scripts/
│   ├── convert_to_lammpstrj.tcl    # VMD script for trajectory conversion
│   ├── get-sk-3d.py               # Structure factor calculation
│   └── analysis-n-plot.ipynb      # Analysis and visualization notebook
├── data/
│   └── [concentration]/           # Data organized by concentration
│       ├── *ions*gro             # Structure files
│       └── *md*xtc               # Trajectory files
```

## Usage

1. Convert FFssFF trajectories to LAMMPS format:
   ```bash
   vmd -e scripts/convert_to_lammpstrj.tcl -args ./25mM output.lammpstrj 2000
   ```
   This will:
   - Process the second half of the simulation
   - Select every other SP5 bead from CYS residues
   - Include all water beads
   - Generate approximately 2000 frames

2. Calculate structure factors:
   ```bash
   python scripts/get-sk-3d.py output.lammpstrj Sk 8
   ```
   This generates structure factors for:
   - SP5-SP5 correlations
   - SP5-water correlations
   - Water-water correlations

3. Analyze results using the Jupyter notebook:
   ```bash
   jupyter notebook scripts/analysis-n-plot.ipynb
   ```

## Method Details

The S0 method ([Cheng et al.](https://github.com/BingqingCheng/S0)) provides a framework for computing chemical potentials from structure factors. Key aspects:

1. Structure Factor Calculation:
   - Computes partial structure factors between system components
   - Uses 3D Fourier transforms for spatial correlations
   - Handles periodic boundary conditions

2. Chemical Potential Analysis:
   - Extracts thermodynamic information from structural correlations
   - Enables investigation of phase separation tendencies
   - Provides insights into solution behavior at different concentrations

## References

1. Original S0 method: [BingqingCheng/S0](https://github.com/BingqingCheng/S0)
2. FFssFF methodology: [Add relevant FFssFF paper/reference]

## Contributing

Feel free to open issues or submit pull requests for improvements or bug fixes.

## License

[Specify your license]
