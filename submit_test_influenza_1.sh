#!/bin/bash

#SBATCH -t 11- 
#SBATCH -N 1 
#SBATCH -n 1
#SBATCH --mail-type=end
#SBATCH --mail-user=YOUR_EMAIL_HERE
#SBATCH --output=./slurmlogs/slurm-%j.out

# Create Rlogs and slurmlogs directories if they do not exist
mkdir -p ./Rlogs
mkdir -p ./slurmlogs

module add r/4.1.3

# Replace YOUR_USERNAME_HERE with your actual username
R CMD BATCH --vanilla --args --shortname=Test --core=2 --copy=1 --user=YOUR_USERNAME_HERE Influenza_Test_1.R ./Rlogs/Influenza_Test_1.out
