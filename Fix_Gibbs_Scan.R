library(stringr)
source("library_cmdline.R")
source("source.R")
source('Allfcns2.R')

#CORE<-cmdline.numeric("core") #Number of cores needed for mclapply
#copy<-cmdline.numeric("copy") #For possible multiple tests

####### inputs ######
CORE = 2
copy = 13
seg = 'S4_5tE1'

##################

# load in files and remove any previous result files
Jname = paste("Test", copy, "_a16",sep="") 
name = paste( "Tests/", Jname, sep = "" )
load(paste0(name,'/Data.Rdata'))
load(paste0("H1N1_Data/H1N1data_Processed/",seg,"Data.Rdata"))


dir.create(paste(name,"/Outputs",sep=""))
dir.create(paste(name,"/SLURMouts",sep=""))

file.remove(paste(name, "/FixGibbsResult.Rdata", sep=""))
file.remove(paste( name, "/mHtsFixOne.Rdata", sep = "" ))
file.remove(paste( name, "/ResultLocalFixOne.Rdata", sep = "" ))
file.remove(paste( name, "/FinalFixOne1.Rdata", sep = "" ))
file.remove(paste( name, "/InferenceFix1.Rdata",sep=""))

load(paste0(name,'/BlockResult.Rdata'))
load(paste0(name,'/TreeResult.Rdata'))

# Submit Gibbs modification
print ("Gibbs mod section")

BCs=combgrp[[1]][seq(1,10000,100),] #Thin-out the chain by every 100 iterations.
C0s=GibbsC0(BCs,Gp,Data) #Assign group label to each sequence position. 100*1175 matrix
newC0s=t(apply(C0s,1,renameC)) #Rename the labels.
save(newC0s, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )


  numC0=nrow(newC0s)
  
  
  for(C0 in 1:numC0){
    subFix=paste("sbatch --constraint=rhel8 -t 11- --mem=5000 -N 1 -n ", CORE, " -J FixGibbs.", Jname, "[",C0,"] -o  ", name, "/SLURMouts/FixGibbs%j.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
                 " --copy=",copy, " --core=", CORE, " --Ci=",C0," FixGibbsMC.R ", name,"/Outputs/FixGibbs",C0,".out\"", sep="")
    system(subFix)
    Sys.sleep(1)
  }
  
