#!/bin/bash
#SBATCH --job-name=FFssFF_S0
#SBATCH --account=dtobias_lab
#SBATCH --partition=standard
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --output=R_analysis.out
#SBATCH --error=R_analysis.err
#SBATCH --mail-type=all
#SBATCH --mail-user=yuanmis1@uci.edu
#SBATCH --time=5:00:00

# Load required modules
module load python/3.9.7
module load r/4.1.2


# Set working directory
cd /dfs9/tw/yuanmis1/mrsec/FFssFF/S0/FFssFF_S0/MARTINI/scripts

# Run the conversion and analysis script
echo "Starting trajectory conversion and S(k) analysis..."
./process_all_concentrations.sh

echo "Analysis complete!" 