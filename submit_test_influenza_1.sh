#!/bin/bash

#SBATCH -t 3- 
#SBATCH -N 1 
#SBATCH -n 1
#SBATCH --output=./slurmlogs/slurm-%j.out

module add r/4.1.3

R CMD BATCH --vanilla --args --shortname=Test --core=1 --copy=1 --user=YOUR_USERNAME_HERE Influenza_Test_1.R ./Rlogs/Influenza_Test_1.out
