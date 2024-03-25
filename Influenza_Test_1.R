source("library_cmdline.R")
source("source.R")
source("Allfcns2.R")

user <- cmdline.strings("user") #so we can check jobs are finished before proceeding to next steps in shj_algor
shortname<-cmdline.strings("shortname") #For simulated data, shortname = Test 
copy<-cmdline.numeric("copy") #For possible multiple tests 
CORE<-cmdline.numeric("core") #Number of cores needed for mclapply

dir.create("Tests")
set.seed(copy*10)

# load data
load("H1N1_Data/H1N1data_Processed/S8_5tE2Data.Rdata")
# We do not want all time points just 4 
rawdataOG = rawdata
total_datasets <- 8
cols_per_dataset <- ncol(rawdataOG) / total_datasets

# Calculate the column indices for datasets 5 and 8
dataset5_start <- cols_per_dataset * (5 - 1) + 1
dataset5_end <- cols_per_dataset * 5
dataset8_start <- cols_per_dataset * (8 - 1) + 1
dataset8_end <- cols_per_dataset * 8

# Exclude datasets 5 and 8 (time point 5 control and treatment)
rawdata <- rawdataOG[, -c(dataset5_start:dataset5_end, dataset8_start:dataset8_end)]

#quick checks
dim = dim(rawdata)[2]
dim
indDim = dim/6
condition_vector <- rawdata[,(6-1)*indDim+1] == rawdataOG[,cols_per_dataset*(7-1)+1]
condition_vector

# Check if the data removed the correct columns
if (!(all(condition_vector) && length(condition_vector) == 4)) {
  stop("Not all conditions are met")
}


#Try L=1,10 
# Step0: Global Params
PostD = c(5,6)
#Pairs = c( "t1t2", "t1t3", "t2t3", "t1t3_D", "t2t3_D" )
#Pairs = c("t1t2","t1t3","t2t3","t1t4","t2t4","t1t5","t2t5","t1t5_D","t2t5_D")
Pairs = c("t1t2","t1t3","t2t3","t1t4","t2t4","t1t4_D","t2t4_D")
Num = ncol(rawdata)/max(PostD)
L = 1
J = nrow(rawdata)
a = 1/(J^2) # Penalty term from Dirichlet
Jname = paste(shortname, copy, "_a",1/a,sep="") #e.g. Jname = Test1_25
name = paste( "Tests/", Jname, sep = "" )
numSplits = 3000
GibbsMC = F #do not run gibbs step

# create directory 
dir.create(name)

# call main script
source("SHJ_algor.R")
