library(stringr)
source("library_cmdline.R")
source("source.R")
source('Allfcns2.R')

#CORE<-cmdline.numeric("core") #Number of cores needed for mclapply
#copy<-cmdline.numeric("copy") #For possible multiple tests

####### inputs ######
CORE = 2
copy = 13
seg = 'S2_5tE2'

##################

# load in files and remove any previous result files
Jname = paste("Test", copy, "_a16",sep="") 
name = paste( "FluTests/", Jname, sep = "" )
load(paste0(name,'/Data.Rdata'))
load(paste0("H1N1_Data/H1N1data_Processed/",seg,"Data.Rdata"))


dir.create(paste(name,"/Outputs",sep=""))
dir.create(paste(name,"/SLURMouts",sep=""))

file.remove(paste(name, "/FixGibbsResult.Rdata", sep=""))


load(paste0(name,'/BlockResult.Rdata'))
load(paste0(name,'/TreeResult.Rdata'))

# Submit Gibbs modification
print ("Gibbs mod section")

BCs=combgrp[[1]][seq(1,10000,100),] #Thin-out the chain by every 100 iterations.
C0s=GibbsC0(BCs,Gp,Data) #Assign group label to each sequence position. 100*1175 matrix
newC0s=t(apply(C0s,1,renameC)) #Rename the labels.
save(newC0s, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )


  numC0=nrow(newC0s)
  
  
  for(C0 in 1:numC0) {
    # Construct the system command with improved quoting
    subFix <- sprintf("R CMD BATCH --vanilla --args --name='%s' --copy=%d --core=%d --Ci=%d FixGibbsMC.R '%s/Outputs/FixGibbs%d.out'",
                      name, copy, CORE, C0, name, C0)
    
    # Print the command for debugging purposes
    cat("Executing command:", subFix, "\n")
    
    # Execute the system command
    system(subFix)
    
    # Simple delay
    Sys.sleep(1)
    
    # Debugging messages
    cat("Started job for C0 =", C0, "\n")
  }
  

