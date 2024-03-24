#!/bin/bash

#SBATCH -t 11- 
#SBATCH -N 1 
#SBATCH -n 1
#SBATCH --mail-type=end
#SBATCH --mail-user=emmamit@email.unc.edu
#SBATCH --output=./slurmlogs/slurm-%j.out



module add r/4.1.3


R CMD BATCH --vanilla --args --shortname=Test --core=2 --copy=1 Influenza_Test_1.R ./Rlogs/Influenza_Test_1.out
