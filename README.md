submit_test_influenza_1.sh illustrates how to create a job submission file to run through the algorithm. To run the code, go to the directory where all the supporting scripts are located, then enter 
Make sure to replace your_username with your username. Also make sure to create the Rlogs and slurmlogs folder in your working directory. Once you have created the submission file type SBATCH 
submit_test_influenza_1.sh

#!/bin/bash

#SBATCH --mail-user=your_email@example.com
#SBATCH --output=./slurmlogs/slurm-%j.out

module add r/4.1.3

R CMD BATCH --vanilla --args --shortname=Test --core=2 --copy=1 --user=your_username Influenza_Test_1.R ./Rlogs/Influenza_Test_1.out



Workflow Overview

The workflow is divided into several steps, implemented across multiple R scripts:

1.   Setup (Influenza_Test_1.R): Prepares the influenza data for analysis and sets up global parameters

2.   Main Script (SHJ_algor.R): Performs the main analysis, including pre-processing, submits the hierarchical SCMH analysis, and performs block MH (Metropolis-Hastings)

3.   Post-processing: To be posted at a later time


   All of the supporting scripts are listed below:

   Tree.R: The workflow for creating the hierarchical SCMH
   source.R: Enables automatic hierarchical divisive tree
   Allfcns2.R: Provides all the necessary functions
   library_cmdline.R: Provides all the source code needed for SLURM command line input

Necessary packages:

install.packages("R.oo")
install.packages("bmixure")
install.packages("coda")
install.packages("parallel")
install.packages("stringr")




