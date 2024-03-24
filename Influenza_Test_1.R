source("library_cmdline.R")
source("source.R")
source("Allfcns2.R")

user <- cmdline.strings("user") #so we can check jobs are finished before proceeding to next steps in shj_algor
shortname<-cmdline.strings("shortname") #For simulated data, shortname = Test 
copy<-cmdline.numeric("copy") #For possible multiple tests 
CORE<-cmdline.numeric("core") #Number of cores needed for mclapply


set.seed(copy*10)

# load data
load("H1N1_Data/H1N1data_Processed/S8_5tE2Data.Rdata")


#Try L=1,10 
# Step0: Global Params
PostD = c(6,7,8)
#Pairs = c( "t1t2", "t1t3", "t2t3", "t1t3_D", "t2t3_D" )
Pairs = c("t1t2","t1t3","t2t3","t1t4","t2t4","t1t5","t2t5","t1t5_D","t2t5_D")
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
