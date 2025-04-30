#!/bin/bash
#SBATCH --job-name=R_analysis
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
module load vmd
module load python/3.9.7
module load r/4.1.2

# Set working directory
cd /dfs9/tw/yuanmis1/mrsec/FFssFF/S0/FFssFF_S0/MARTINI/scripts

# Run the conversion and analysis script
echo "Starting trajectory conversion and S(k) analysis..."
./process_all_concentrations.sh

# Change to analysis directory
cd ../analysis

# Install required R packages if not already installed
Rscript -e 'if(!require(tidyverse)) install.packages("tidyverse", repos="https://cloud.r-project.org")'
Rscript -e 'if(!require(latex2exp)) install.packages("latex2exp", repos="https://cloud.r-project.org")'
Rscript -e 'if(!require(scales)) install.packages("scales", repos="https://cloud.r-project.org")'

# Render the R Markdown document
echo "Rendering R Markdown analysis..."
Rscript -e "rmarkdown::render('analyze_sk_martini.Rmd', output_file='sk_analysis_report.html')"

echo "Analysis complete!" 