# Usage: vmd -e convert_to_lammpstrj.tcl -args input_dir output_file [num_frames]
# Example: vmd -e convert_to_lammpstrj.tcl -args ./25mM output.lammpstrj 2000

# Get command line arguments
set input_dir [lindex $argv 0]
set output_file [lindex $argv 1]
set desired_frames 2000
if {[llength $argv] > 2} {
    set desired_frames [lindex $argv 2]
}

# Find structure and trajectory files
set gro_files [glob -nocomplain "$input_dir/*ions*gro"]
if {[llength $gro_files] == 0} {
    puts "Error: No *ions*gro file found in $input_dir"
    exit 1
}
set gro_file [lindex $gro_files 0]
puts "Using structure file: $gro_file"

# Load structure
mol new $gro_file type gro waitfor all

# Find and load all trajectory files in correct order
set xtc_files [glob -nocomplain "$input_dir/*md*.part*.xtc"]
if {[llength $xtc_files] == 0} {
    # If no part files found, try regular xtc files
    set xtc_files [glob -nocomplain "$input_dir/*md*.xtc"]
}
if {[llength $xtc_files] == 0} {
    puts "Error: No *md*xtc files found in $input_dir"
    exit 1
}

# Sort trajectory files numerically by part number
set sorted_xtc_files {}
foreach xtc $xtc_files {
    if {[regexp {part(\d+)} $xtc -> part_num]} {
        lappend sorted_xtc_files [list $part_num $xtc]
    } else {
        # For files without part number, use -1 to place them at the start
        lappend sorted_xtc_files [list -1 $xtc]
    }
}

# Sort by part number
set sorted_xtc_files [lsort -integer -index 0 $sorted_xtc_files]

puts "Loading trajectory files in order:"
foreach xtc_entry $sorted_xtc_files {
    set xtc [lindex $xtc_entry 1]
    puts "Loading: $xtc"
    mol addfile $xtc type xtc waitfor all
}

# Get total number of frames
set total_frames [molinfo top get numframes]
set start_frame [expr {int($total_frames/2)}]
set remaining_frames [expr {$total_frames - $start_frame}]
set stride [expr {int(ceil(double($remaining_frames)/$desired_frames))}]

puts "Total frames: $total_frames"
puts "Starting from frame: $start_frame"
puts "Using stride: $stride"
puts "Will generate approximately $desired_frames frames"

# Create selections
set sp5_all [atomselect top "name SP5 and resname CYS"]
set sp5_indices [$sp5_all get index]
set sp5_alternate []
# Get every other SP5 atom
for {set i 0} {$i < [llength $sp5_indices]} {incr i 2} {
    lappend sp5_alternate [lindex $sp5_indices $i]
}
set sp5_sel [atomselect top "index $sp5_alternate"]
set water_sel [atomselect top "resname W"]

puts "Selected [llength $sp5_alternate] SP5 atoms (every other one)"
puts "Selected [$water_sel num] water beads"

# Open output file
set outfile [open $output_file w]

# Process frames
for {set frame $start_frame} {$frame < $total_frames} {incr frame $stride} {
    $sp5_sel frame $frame
    $water_sel frame $frame
    
    # Get box dimensions
    set box [molinfo top get {a b c} frame $frame]
    set box_angles [molinfo top get {alpha beta gamma} frame $frame]
    
    # Write LAMMPS trajectory format
    puts $outfile "ITEM: TIMESTEP"
    puts $outfile $frame
    puts $outfile "ITEM: NUMBER OF ATOMS"
    puts $outfile [expr {[$sp5_sel num] + [$water_sel num]}]
    puts $outfile "ITEM: BOX BOUNDS pp pp pp"
    puts $outfile "0.0 [lindex $box 0]"
    puts $outfile "0.0 [lindex $box 1]"
    puts $outfile "0.0 [lindex $box 2]"
    puts $outfile "ITEM: ATOMS id type x y z"
    
    # Write SP5 coordinates
    set coords [$sp5_sel get {x y z}]
    set id 1
    foreach coord $coords {
        puts $outfile "$id 1 [lindex $coord 0] [lindex $coord 1] [lindex $coord 2]"
        incr id
    }
    
    # Write water coordinates
    set coords [$water_sel get {x y z}]
    foreach coord $coords {
        puts $outfile "$id 2 [lindex $coord 0] [lindex $coord 1] [lindex $coord 2]"
        incr id
    }
}

# Clean up
close $outfile
$sp5_sel delete
$water_sel delete
$sp5_all delete

puts "Conversion complete. Output written to $output_file"

# Exit VMD
quit 