library(sp)
library(raster)


## Data preparation
instance <- read.csv("/Users/lizavab/Documents/term-project/outputs/predicted_test_labels.csv")
head(instance)

# Add ground reference column
GT=instance$gt
best=instance$rf5  

# Create an empty matrix that can contain all the models we need
mc_OA<-matrix(NA,6,2) 

# Remove the best model and the ground reference 
compare<-instance[,-c(5,8)] 


## Compare overall accuracy (OA)
C1<-best
for(i in 1:dim(compare)[2]){
  print(i)
  C2<-compare[,i]
  f11<-sum((GT==C1)&(GT==C2),na.rm=T) #both classifier correct
  f12<-sum((GT==C1)&(GT!=C2),na.rm=T) #c1 correct, c2 incorrect
  f21<-sum((GT!=C1)&(GT==C2),na.rm=T) #c1 incorrect, c2 correct
  f22<-sum((GT!=C1)&(GT!=C2),na.rm=T) #both incorrect
  
  (c<-matrix(c(f11,f21,f12,f22),nrow = 2)) 
  (d<-mcnemar.test(c))
  mc_OA[i,1]<-d$statistic
  mc_OA[i,2]<-d$p.value
}


## Compare the user's accuracy (UA) of the different classes
# Comparing User's accuracy and overall accuracies of class 'built-up'
mc_UA_Built <- matrix(NA,6,2)

C1<-best
for(i in 1:dim(compare)[2]){
  print(i)
  C2<-compare[,i]
  f11<-sum((C1==0)&(GT==0)&(C2==0),na.rm=T) #both classifier correct for class 4
  f12<-sum((C1!=0)&(GT!=0)&(C2==0),na.rm=T) #c1 correct, c2 overestimate
  f21<-sum((C1==0)&(GT!=0)&(C2!=0),na.rm=T) #c1 overestimate, c2 correct
  f22<-sum((C1==0)&(GT!=0)&(C2==0),na.rm=T) #both incorrect
  (c<-matrix(c(f11,f21,f12,f22),nrow = 2)) 
  (d<-mcnemar.test(c))
  mc_UA_Built[i,1]<-d$statistic
  mc_UA_Built[i,2]<-d$p.value
}
(mc_results0<-data.frame(names(compare),mc_OA,mc_UA_Built))

# Rename the columns
names(mc_results0)<-c("compare_classification","chi_OA","pvalue_OA","chi_UA","pvalue_UA")
head(mc_results0)

# Comparing user's accuracy and overall accuracies of class 'water'
mc_UA_water <- matrix(NA,6,2)

C1<-best
for(i in 1:dim(compare)[2]){
  print(i)
  C2<-compare[,i]
  f11<-sum((C1==1)&(GT==1)&(C2==1),na.rm=T) #both classifier correct for class 4
  f12<-sum((C1!=1)&(GT!=1)&(C2==1),na.rm=T) #c1 correct, c2 overestimate
  f21<-sum((C1==1)&(GT!=1)&(C2!=1),na.rm=T) #c1 overestimate, c2 correct
  f22<-sum((C1==1)&(GT!=1)&(C2==1),na.rm=T) #both incorrect
  (c<-matrix(c(f11,f21,f12,f22),nrow = 2)) 
  (d<-mcnemar.test(c))
  mc_UA_water[i,1]<-d$statistic
  mc_UA_water[i,2]<-d$p.value
}
(mc_results1<-data.frame(names(compare),mc_OA,mc_UA_water))

names(mc_results1)<-c("compare_classification","chi_OA","pvalue_OA","chi_UA","pvalue_UA")
head(mc_results1)

# Comparing user's accuracy and overall accuracies of class 'woody vegetation'
mc_UA_woody <- matrix(NA,6,2)

C1<-best
for(i in 1:dim(compare)[2]){
  print(i)
  C2<-compare[,i]
  f11<-sum((C1==2)&(GT==2)&(C2==2),na.rm=T) #both classifier correct for class 4
  f12<-sum((C1!=2)&(GT!=2)&(C2==2),na.rm=T) #c1 correct, c2 overestimate
  f21<-sum((C1==2)&(GT!=2)&(C2!=2),na.rm=T) #c1 overestimate, c2 correct
  f22<-sum((C1==2)&(GT!=2)&(C2==2),na.rm=T) #both incorrect
  (c<-matrix(c(f11,f21,f12,f22),nrow = 2)) 
  (d<-mcnemar.test(c))
  mc_UA_woody[i,1]<-d$statistic
  mc_UA_woody[i,2]<-d$p.value
}
(mc_results2<-data.frame(names(compare),mc_OA,mc_UA_woody))

names(mc_results2)<-c("compare_classification","chi_OA","pvalue_OA","chi_UA","pvalue_UA")
head(mc_results2)

# Comparing user's accuracy and overall accuracies of class 'non-woody vegetation'
mc_UA_non_woody <- matrix(NA,6,2)

C1<-best
for(i in 1:dim(compare)[2]){
  print(i)
  C2<-compare[,i]
  f11<-sum((C1==3)&(GT==3)&(C2==3),na.rm=T) #both classifier correct for class 4
  f12<-sum((C1!=3)&(GT!=3)&(C2==3),na.rm=T) #c1 correct, c2 overestimate
  f21<-sum((C1==3)&(GT!=3)&(C2!=3),na.rm=T) #c1 overestimate, c2 correct
  f22<-sum((C1==3)&(GT!=3)&(C2==3),na.rm=T) #both incorrect
  (c<-matrix(c(f11,f21,f12,f22),nrow = 2)) 
  (d<-mcnemar.test(c))
  mc_UA_non_woody[i,1]<-d$statistic
  mc_UA_non_woody[i,2]<-d$p.value
}
(mc_results3<-data.frame(names(compare),mc_OA,mc_UA_non_woody))

names(mc_results3)<-c("compare_classification","chi_OA","pvalue_OA","chi_UA","pvalue_UA")
head(mc_results3)


## Combine McNemar's test results
mcn_test <- data.frame(mc_results0,mc_results1,mc_results2, mc_results3)
write.csv(mcn_test,"./McNemar_results.csv",row.names=F)


## Adjust area estimates based on error reports             
best=raster("/Users/lizavab/Documents/term-project/outputs/rf5_classified.tif")

# Summarize numbers of pixels of each class mapped
table(values(best))
pixelValues<-table(values(best))

# Convert square meters to square kilometers
pixelAreaSqKm <- (3 * 3) / 1000000 
valuesInSqKm <- pixelValues * pixelAreaSqKm
valuesInSqKm

# Convert square meters to hectares
pixelAreaHa <- (3 * 3) / 10000 
valuesInHa <- pixelValues * pixelAreaHa
valuesInHa
