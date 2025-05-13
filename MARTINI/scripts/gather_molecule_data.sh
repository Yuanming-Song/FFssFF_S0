#!/bin/bash

# Directory containing the simulations
SIM_DIR="/dfs9/tw/iha2/CG/Base"
cd "$SIM_DIR"

# Create Python data file
cat > molecule_data.py << 'EOF'
# Molecule counts and volume data
mol_list = ['25', '60', '100', '145', '205', '260', '350', '525']

# number of FFssFF and water molecules, volume [A^3]
natom_dict = {
EOF

# Create shell script with variables
cat > molecule_data.sh << 'EOF'
#!/bin/bash
# Molecule counts and volume data
EOF

for dir in *mM; do
    # Extract concentration number
    conc=$(echo $dir | sed 's/mM//')
    
    # Count FFssFF molecules (each has 4 BB)
    ffssff=$(awk '/^[ ]*[0-9]+PHE.*BB/ {count++} END {print count/4}' $dir/FFssFF_Base_Lattice_${conc}mM_FSSF_md.part0001.gro)
    
    # Count water molecules (WT4)
    water=$(awk '/^[ ]*[0-9]+W/ {count++} END {print count}' $dir/FFssFF_Base_Lattice_${conc}mM_FSSF_md.part0001.gro)
    
    # Get box size and calculate volume in A^3
    # Convert from nm to A: 1 nm = 10 A
    box_size=$(tail -n 1 $dir/FFssFF_Base_Lattice_${conc}mM_FSSF_md.part0001.gro | awk '{print $1}')
    # Convert box size to A and calculate volume: (box_size * 10)^3
    volume=$(echo "scale=8; ($box_size * 10)^3" | bc)
    
    # Append to Python file
    echo "    $conc: [$ffssff, $water, $volume]," >> molecule_data.py
    
    # Append to shell script
    echo "FFSSFF_${conc}mM=$ffssff" >> molecule_data.sh
    echo "WATER_${conc}mM=$water" >> molecule_data.sh
    echo "VOLUME_${conc}mM=$volume" >> molecule_data.sh
    echo "" >> molecule_data.sh
done

# Close the Python dictionary
echo "}" >> molecule_data.py

# Make the shell script executable
chmod +x molecule_data.sh

echo "Data has been saved to:"
echo "1. Python file: $SIM_DIR/molecule_data.py"
echo "2. Shell script: $SIM_DIR/molecule_data.sh"
echo
echo "You can use these files in two ways:"
echo "1. In Python: from molecule_data import mol_list, natom_dict"
echo "2. In shell: source molecule_data.sh" 