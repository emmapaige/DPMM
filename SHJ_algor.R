# Algorithm (preprocess, processing, and post-process)
# need this library for str_count
# install.packages("stringr",lib="/nas/longleaf/home/weiyq/ms/Rpackages", repos='http://cran.us.r-project.org')
# library(stringr,lib.loc="/nas/longleaf/home/weiyq/ms/Rpackages")
#library(stringr,lib.loc="/nas/longleaf/home/weiyq/R/x86_64-redhat-linux-gnu-library/3.6")  
library(stringr)


# Step1: Preprocess
conso=consoData(rawdata)  # consoData is in Allfcns.R
Data=conso[[1]]
G0=conso[[2]]
save(Data,G0,Num,L,J,a,PostD,Pairs,numSplits,GibbsMC,file=paste(name,"/Data.Rdata",sep=""))



# Step2: Processsing
# Hierarchical SCMH
dir.create(paste(name,"/Outputs",sep=""))
dir.create(paste(name,"/SLURMouts",sep=""))

starttree = paste("sbatch --constraint=rhel8 -t 4- --mem=10000  -N 1 -n 1 -J ",Jname," -o ", name, "/SLURMouts/", Jname,
                  ".out.1  --wrap=\"R  CMD BATCH --vanilla --args --copy=", copy,
                  " --name=",name, " --Jname=", Jname, " --current=1 Tree.R ", name, "/Outputs/tree1.Rout \"",sep="" )

print (paste("sbatch command:",starttree))
print (" ")
system(starttree)

state <- system(paste("squeue -u", user, "-O jobid,name:40"), intern=TRUE) #allows for username input
#state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE)
# collapse character vector into on long string
state <- paste(state,collapse=" ")
print("printing state")
print(state)
isInQueue <- str_detect(state, Jname)
print (paste("isInQueue=",isInQueue))
while (isInQueue) {
  Sys.sleep(60)
  state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE)
  state <- paste(state,collapse=" ")
  isInQueue <- str_detect(state, Jname)
  print (paste("whiling away isInQueue=",isInQueue))
}


SplitList=list() #Summarize tree result.
print (paste("1 spl=",SplitList))
run=T
i=0
endInd=3
print ("doing while")
while(run==T){
  i=i+1
  print (paste("i=",i))
  if(1==i){
    load(paste(name,"/Tree_",i,".Rdata", sep=""))
    test=old.result
    SplitList[[i]]<-SplitNode(left=2*i,right=2*i+1,parent=NA,curent=i,LP=test$LP,
                              ind=sort(c(test$left,test$right)))    #SplitNode is in source.R
    if(0!=length(test$left) & 0!=length(test$right)){
      SplitList[[2*i]]<-SplitNode(left=4*i,right=4*i+1,curent=2*i,parent=i,LP=NULL,ind=test$left)
      SplitList[[2*i+1]]<-SplitNode(left=2*(2*i+1),right=2*(2*i+1)+1,curent=2*i+1,parent=i,
                                    LP=NULL,ind=test$right)
    }
    if(0==length(test$left) | 0==length(test$right)){
      noLeft(SplitList[[i]])    #noLeft is in source.R
      noRight(SplitList[[i]])  #noRight is in source.R
    }
  }
  else if(is.Node(SplitList[[i]])){
    load(paste(name,"/Tree_",i,".Rdata", sep=""))
    test=old.result
    updateLP(SplitList[[i]],test$LP)  #updateLP is in source.R
    if(0!=length(test$left) & 0!=length(test$right)){
      SplitList[[2*i]]<-SplitNode(left=4*i,right=4*i+1,curent=2*i,parent=i,LP=NULL,ind=test$left) #Function is in source.R
      SplitList[[2*i+1]]<-SplitNode(left=2*(2*i+1),right=2*(2*i+1)+1,curent=2*i+1,parent=i,
                                    LP=NULL,ind=test$right)
    }else{
      noLeft(SplitList[[i]])
      noRight(SplitList[[i]])
      SplitList[[2*i]]=NULL
      SplitList[[2*i+1]]=NULL
    }
  }else{
    SplitList[[2*i]]=NULL
    SplitList[[2*i+1]]=NULL
  }
  if (i==endInd){
    st=stopSplit(i)
    if(0==st){run=F}
    endInd=2*endInd+1
    SplitList[[2*endInd+1]]=NA
  }
}
print ("end while T")
Gp=groupIndex()
save(Gp, file=paste(name,"/TreeResult.Rdata",sep=""))


print ("Block MH section")
# Block MH
Z0=grpData(Data,Gp)
T0 = proc.time()
combgrp=blockcomb(Z0,Gp,50000,a,1000,Num,L)  
TN = proc.time() - T0
cput_block = TN[1]
save(Z0,combgrp, cput_block,file=paste(name,"/BlockResult.Rdata",sep=""))

print ("Gibbs mod section")

BCs=combgrp[[1]][seq(1,10000,100),] #Thin-out the chain by every 100 iterations.
C0s=GibbsC0(BCs,Gp,Data) #Assign group label to each sequence position. 100*1175 matrix
newC0s=t(apply(C0s,1,renameC)) #Rename the labels.
save(newC0s, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )

if (GibbsMC==T){
numC0=nrow(newC0s)

#took out --mem=20000
for(C0 in 1:numC0){

  subFix=paste("sbatch --constraint=rhel8 -t 11- -N 1 -n ", CORE, " -J FixGibbs.", Jname, "[",C0,"] -o  ", name, "/SLURMouts/FixGibbs%j.out  --wrap=\"R CMD BATCH --vanilla --args --name=", name,
               " --copy=",copy, " --core=", CORE, " --Ci=",C0," FixGibbsMC.R ", name,"/Outputs/FixGibbs",C0,".out\"", sep="")
  system(subFix)
  Sys.sleep(1)
}

# 
# 
# state <- system(paste("squeue -u emmamit -O  jobid,name:40"),intern=TRUE)
# # collapse character vector into on long string
# state <- paste(state,collapse=" ")
# print("printing state")
# print(state)
# isInQueue <- str_detect(state, Jname)
# print (paste("isInQueue=",isInQueue))
# while (isInQueue) {
#   Sys.sleep(60)
#   system(paste("squeue -u emmamit -O  name:40"))
#   state <- system(paste("squeue -u emmamit -O  name:40"),intern=TRUE)
#   state <- paste(state,collapse=" ")
#   isInQueue <- str_detect(state, Jname)
#   print (paste("whiling away isInQueue=",isInQueue))
# }
# 
# 
# system(paste("rm ", name, "/FixGibbsMC*temp.Rdata", sep="" ))
# Gibbs=Gibbsresult2(newC0s,name,rawdata, GibbsMC = T) 
# save( newC0s, Gibbs, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )
} else{
  Gibbs=Gibbsresult2(newC0s,name,rawdata, GibbsMC = F)
  save( newC0s, Gibbs, file = paste( name, "/FixGibbsResult.Rdata", sep = "" ) )
}
# 
# print ("Step 3")
# 
# # Step 3: Postprocess
# HtMed( Gibbs$FinalCs, rawdata, a, PostD, Num, name, Control = T, mHtsFile = "/mHtsFixOne.Rdata" )
# inffile = paste( name, "/mHtsFixOne.Rdata", sep = "" )
# resultfile =  paste( name, "/ResultLocalFixOne.Rdata", sep = "" )
# load(inffile); Cuts = seq(0, max(mHts.pos), by = .001)
# noise.test = sapply(Cuts, function(y){
#   result = freaksite0(inffile, Pairs, PostD, y, Control = T )
#   noise.l = c( length(result$Substitution), length(result$potential),
#                length(result$noise))
#   return( noise.l )
# })
# save( Pairs, PostD, Cuts, noise.test, file = resultfile )
# savefile =  paste( name, "/FinalFixOne1.Rdata", sep = "" )
# result = freak.result1( inffile, resultfile, savefile, delta = 3, Control = T, alpha = .05 )
# 
# save(Gibbs, result, file = paste( name, "/InferenceFix1.Rdata",sep=""))
# 
# 
# 










