# FFssFF Phase Separation Analysis

Analysis of phase separation in FFssFF systems using structure factor calculations and the S0 method.

## Project Structure

```
.
├── S0_base/               # Original S0 method implementation
│   ├── scripts/          # Original analysis scripts
│   └── input-*/          # Example input data
├── MARTINI/              # MARTINI-specific analysis
│   ├── scripts/          # Modified scripts for MARTINI
│   ├── analysis/         # R markdown analysis
│   └── data/             # Data organized by concentration
│       ├── 25mM/
│       ├── 60mM/
│       └── ...
└── CHARMM/              # CHARMM-specific analysis (future)
    └── scripts/
```

## MARTINI Analysis Workflow

1. **Data Preparation**
   ```bash
   # For each concentration (e.g., 25mM):
   cd MARTINI/scripts
   vmd -e convert_to_lammpstrj.tcl -args ../../data/25mM output.lammpstrj 2000
   ```
   This will:
   - Process the second half of the simulation
   - Select every other SP5 bead from CYS residues
   - Include all water beads
   - Generate ~2000 frames

2. **Structure Factor Calculation**
   ```bash
   cd MARTINI/data/25mM
   python ../../scripts/get-sk-3d-martini.py output.lammpstrj Sk 8
   ```
   Generates:
   - SP5-SP5 correlations (II)
   - SP5-water correlations (IW)
   - Water-water correlations (WW)

3. **Analysis**
   - Using Jupyter Notebook:
     ```bash
     jupyter notebook MARTINI/scripts/analysis-n-plot-martini.ipynb
     ```
   - Using R Markdown:
     ```bash
     Rscript -e "rmarkdown::render('MARTINI/analysis/analysis-n-plot.Rmd')"
     ```

## Batch Processing

For processing multiple concentrations:
```bash
for conc in 25mM 60mM 100mM 145mM 205mM 260mM 350mM 525mM; do
    # Convert trajectories
    vmd -e MARTINI/scripts/convert_to_lammpstrj.tcl -args ./data/$conc $conc/output.lammpstrj 2000
    
    # Calculate structure factors
    cd MARTINI/data/$conc
    python ../../scripts/get-sk-3d-martini.py output.lammpstrj Sk 8
    cd ../../..
done
```

## Analysis Output

The analysis generates:
1. Structure factor data files:
   - `Sk-II-real.dat`: SP5-SP5 correlations
   - `Sk-IW-real.dat`: SP5-water correlations
   - `Sk-WW-real.dat`: Water-water correlations

2. Visualization:
   - Structure factor plots
   - Chemical potential analysis
   - Phase separation indicators

## References

1. Original S0 method: [BingqingCheng/S0](https://github.com/BingqingCheng/S0)
2. FFssFF methodology: [Add relevant FFssFF paper/reference]

## Contributing

When adding new scripts or modifying workflows:
1. Update README.md with changes
2. Document any new dependencies
3. Update analysis notebooks if needed
4. Follow the established directory structure

## License

[Specify your license]
