# Influenza Analysis Workflow

This repository contains R scripts for analyzing the last segment of the influenza A virus A/Brisbane/59/2007 strain time series data (NIH Biodefencse and Emerging Infectious Research Resources Repository NIAID, NIH; NR-12282; lot 58550257) with a Dirichlet Process Mixture Model. The data were collected from multiple passages in the presence and absence of an inhibitor of neuraminidase, oseltamivir, for a total of two biological replicates (E1 & E2). The algorithm includes steps for data preparation, a series of MCMC procedures designed to cluster the genome, and a post-analysis summarization of sites that have changed in frequency due to the treatment Oseltamivir. Note only passages 1,3,9, and 12 are considered for this analysis.

## Getting Started

### Prerequisites

Ensure R (version 4.1.3 or later) is installed along with the following packages:

```{r}
install.packages(c("R.oo", "bmixture", "coda", "parallel", "stringr", "fields", "matrixStats", "gtools"))
```

### Installation

Clone this repository:

git clone https://github.com/emmapaige/DPMM.git


### Running the Analysis

1. Go to the directory where all the supporting scripts are located
2. Create `Rlogs` and `slurmlogs` directories in your working directory.
3. Modify `submit_test_influenza_1.sh` with your details (make sure to add more time and cores if necessary and change your username and email):

```bash

#!/bin/bash
#SBATCH -t 3- 
#SBATCH --mail-user=your_email@example.com
#SBATCH --output=./slurmlogs/slurm-%j.out
module load r/4.1.3
R CMD BATCH --vanilla --args --shortname=Test --core=1 --copy=1 --user=your_username Influenza_Test_1.R ./Rlogs/Influenza_Test_1.out
```

Submit the job with:
``` bash
sbatch submit_test_influenza_1.sh
```

## Workflow Overview

### The workflow is divided into several steps, implemented across multiple R scripts:

1. Setup (`Influenza_Test_1.R`): Prepares the influenza data for analysis and sets up global parameters

2. Main Script (`SHJ_algor.R`): Performs the main analysis, including pre-processing, submits the hierarchical SCMH analysis, and performs block MH (Metropolis-Hastings)

3. Post-processing: To be posted at a later time


### All of the supporting scripts are listed below:

1. `Tree.R`: The workflow for creating the hierarchical SCMH
2. `source.R`: Enables automatic hierarchical divisive tree
3. `Allfcns2.R`: Provides all the necessary functions
4. `library_cmdline.R`: Provides all the source code needed for SLURM command line input






