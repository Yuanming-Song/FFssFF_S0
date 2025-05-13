#!/bin/bash

# Count FFssFF molecules (count unique first residues)
echo "Number of FFssFF molecules:"
awk '/^[ ]*[0-9]+PHE.*BB/ {count++} END {print count}' 25mM/FFssFF_Base_Lattice_25mM_FSSF_md.part0001.gro

# Count water molecules (WT4)
echo "Number of water molecules (WT4):"
awk '/^[ ]*[0-9]+W/ {count++} END {print count}' 25mM/FFssFF_Base_Lattice_25mM_FSSF_md.part0001.gro

# Get box size and calculate volume
echo "Box size (nm):"
box_size=$(tail -n 1 25mM/FFssFF_Base_Lattice_25mM_FSSF_md.part0001.gro | awk '{print $1}')
echo "$box_size $box_size $box_size"
echo "Volume (nm^3):"
echo "$box_size * $box_size * $box_size" | bc 