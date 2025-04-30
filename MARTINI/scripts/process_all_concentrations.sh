#!/bin/bash

# Base directories
BASE_INPUT_DIR="/dfs9/tw/iha2/CG/Base"
SCRIPT_DIR="/dfs9/tw/yuanmis1/mrsec/FFssFF/S0/FFssFF_S0/MARTINI/scripts"
OUTPUT_DIR="/dfs9/tw/yuanmis1/mrsec/FFssFF/S0/FFssFF_S0/MARTINI/data"

# Array of concentrations
CONCENTRATIONS=("25mM" "60mM" "100mM" "145mM" "205mM" "260mM" "350mM" "525mM")

# Number of frames to process (default 200 for testing, change to 2000 for production)
FRAMES=200

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process each concentration
for conc in "${CONCENTRATIONS[@]}"; do
    echo "Processing concentration: $conc"
    
    # Create concentration-specific output directory
    conc_dir="$OUTPUT_DIR/$conc"
    mkdir -p "$conc_dir"
    
    # Step 1: Convert GROMACS trajectory to LAMMPS format
    echo "Converting trajectory for $conc..."
    cd "$SCRIPT_DIR"
    vmd -e convert_to_lammpstrj.tcl -args "$BASE_INPUT_DIR/$conc/" "$conc.data" "$FRAMES"
    
    # Check if conversion was successful
    if [ ! -f "$conc.data" ]; then
        echo "Error: Conversion failed for $conc"
        continue
    fi
    
    # Step 2: Run S0 analysis
    echo "Running S0 analysis for $conc..."
    python3 get-sk-3d-martini.py Sk "$conc" 8
    
    echo "Completed processing $conc"
    echo "----------------------------------------"
done

echo "All concentrations processed successfully!"

# Optional: Clean up temporary .data files
read -p "Do you want to remove the temporary .data files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f "$SCRIPT_DIR"/*.data
    echo "Temporary files cleaned up"
fi 