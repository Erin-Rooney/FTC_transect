#Code to process site NEON temperature probe data and quantify freeze-thaw cycling using FTCQuant
#Code generated by Angela Possinger and Erin Rooney, August 2020
#Updated for TOOL by Angela Possinger 02-18-21
#modified for all sites by Erin Rooney 07-23-21

#Packages----------------------------------
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(reshape)
library(reshape2)
library(plyr)
library(Rmisc)
library(devtools)
#install_github("BajczA475/FTCQuant/FTCQuant")
library(FTCQuant)
library(data.table)
library(neonUtilities)
library(scales)

#Load soil temp data as NEON data products###################
#5 cores/site (001, 002, 003, etc.), 7-9 depths per site (501, 502, 503, etc.)

#Change "path" to directory for files #now "raw"
load("raw/fall1.RData")
load("raw/fall2.RData")
load("raw/fall3.RData")
load("raw/summer1.RData")
load("raw/summer2.RData")
load("raw/summer3.RData")
load("raw/spring1.RData")
load("raw/spring2.RData")
load("raw/spring3.RData")
load("raw/winter1.RData")
load("raw/winter2.RData")
load("raw/winter3.RData")

#Each data product has 4 elements
#Example:
fall1$readme_00041 #A large readme file giving information about data collection and format
fall1$sensor_positions_00041 #Gives locations and depths of probes
fall1$ST_30_minute #The actual time series temperature data
fall1$variables_00041 #Variable defintions


#Combined data for plotting and FTC analysis#################
temp.dat=list(fall1 = fall1$ST_30_minute, fall2 = fall2$ST_30_minute, fall3 = fall3$ST_30_minute, summer1 = summer1$ST_30_minute, summer2 = summer2$ST_30_minute, summer3 = summer3$ST_30_minute, spring1 = spring1$ST_30_minute, spring2 = spring2$ST_30_minute, spring3 = spring3$ST_30_minute, winter1 = winter1$ST_30_minute, winter2 = winter2$ST_30_minute, winter3 = winter3$ST_30_minute)

pos.dat=list(fall1 = fall1$sensor_positions_00041, fall2 = fall2$sensor_positions_00041, fall3 = fall3$sensor_positions_00041, summer1 = summer1$sensor_positions_00041, summer2 = summer2$sensor_positions_00041, summer3 = summer3$sensor_positions_00041, spring1 = spring1$sensor_positions_00041, spring2 = spring2$sensor_positions_00041, spring3 = spring3$sensor_positions_00041, winter1 = winter1$sensor_positions_00041, winter2 = winter2$sensor_positions_00041, winter3 = winter3$sensor_positions_00041)

#Plot PDFS - grid by sensor and depth################

#Convert site, verticalPosition, and horizontalPosition to factors

str(temp.dat$fall1)

temp.dat = lapply(temp.dat, function(x) {
  x$siteID = as.factor(x$siteID)
  x$verticalPosition = as.factor(x$verticalPosition)
  x$horizontalPosition = as.factor(x$horizontalPosition)
  
  return(x)
})

str(temp.dat$fall1)

#Plot function 
#Change "path" to folder storing files #now "raw"

plot_function = function(x,y){
  
  setwd("raw")
  pdf(paste0(y,".pdf"), heigh=10, width=25) 
  print(ggplot(x) + geom_line(aes(x=startDateTime, y=soilTempMean)) + 
          facet_grid(horizontalPosition~verticalPosition) + 
          labs(title=y, x="Date (M-Y)", y=expression("Mean soil temperature " ( degree*C))) + 
          scale_x_datetime( breaks=("1 month"), 
                            minor_breaks=("14 days"), 
                            labels=date_format("%m/%y"), 
                            timezone = "UTC-9:00") + 
          theme_bw() + 
          theme(panel.grid=element_blank(), 
                axis.text = element_text(size=10, color="black"),
                axis.title = element_text(size=12, color="black")))
  
  dev.off() 
}


for (i in 1:length(temp.dat)){
  cur.name=names(temp.dat)[i]
  plot_function(x=temp.dat[[i]], 
                y=cur.name)
}

#FTC calculation - FTCQuant packages#####################

#FTC for 1.5 degree mag.vec, 4 hour duration (8 timesteps)#######################
FTC_1.5_4 = function(x, #list of dataframes (element ST_30_minute from NEON data product)
                     y, #list of dataframes (element sensor_positions_00041 from NEON data product)
                     name, #names of elements in x and y (vector). Names must end in a single digit number (year) in this case. 0 = NA. 
                     year #last character of names, which defines the year of measurements (in this case 1 or 2). 0 = NA. 
) {
  
  #Reduce dataframe to relevant columns (speeds up dcast)
  reduced_dat <- x[,c("siteID","verticalPosition","horizontalPosition","startDateTime","soilTempMean")]
  
  #Convert vertical, horizontal, and siteID to factors
  reduced_dat$verticalPosition=as.factor(reduced_dat$verticalPosition)
  reduced_dat$horizontalPosition=as.factor(reduced_dat$horizontalPosition)
  reduced_dat$siteID=as.factor(reduced_dat$siteID)
  
  #Reformat from "long" to "wide" form. Now the first column is the date-time
  #the other columns all correspond to one individual unit (probe), i.e. 1 site, 1 core, 1 depth 
  reduced_dat_Wide <- dcast(reduced_dat, startDateTime ~ siteID + verticalPosition + horizontalPosition)
  
  #Freeze.thaw.analysis function fails with too many missing values (they do not provide a cutoff) 
  #For now, replacing columns with NA > 3% of timepoints with 0s (should be a flat line)
  #Most probes with missing data >3% are missing most if not all measurements
  
  #How many NAs is 3%?
  Max_NA <- nrow(reduced_dat_Wide)*0.03
  
  #Count # of NAs in each column
  NA_count <- as.data.frame(sapply(reduced_dat_Wide, function(x) sum(is.na(x))))
  colnames(NA_count) <- c("NA_count")
  
  #Converts all columns with names that match rows in NA_count with NA > 3% to 0s 
  reduced_dat_Wide[,c(rownames(NA_count)[NA_count$NA_count >= Max_NA])] <- 0
  
  #Convert date to character
  reduced_dat_Wide$startDateTime=as.character.Date(reduced_dat_Wide$startDateTime)
  names(reduced_dat_Wide)[names(reduced_dat_Wide) == 'startDateTime'] <- 'date'
  
  # #Dimensions of final dataframe
  # dim(reduced_dat_Wide)
  
  #Freeze-thaw analysis ####################################
  #Names of all columns but date, which will become the names of each element in the data.list for freeze thaw function
  column_names=as.vector(colnames(reduced_dat_Wide[,2:ncol(reduced_dat_Wide)]))
  #Number of columns to use in the data.list 
  column_number=as.vector(2:ncol(reduced_dat_Wide))
  
  #This function makes a list of elements, extracting row 1 (date) and then sequentially each column (y)
  #Each date and data column is a new element in the list, named by the list of column names above (x) 
  fun1 <- function(name,number) {
    data.list <- list(name = reduced_dat_Wide[,c(1,number)])
  }
  
  #This applies the function to loop through the list of column names (name) and numbers (number) 
  data.list = mapply(fun1,column_names,column_number)
  
  #The actual analysis function: this is where the parameters can be changed. 
  #mag.vec = degrees below thres.vec
  #thres.vec = upper limit (0 degrees C) to induce FTC
  #dur.vec = duration of time (number of timesteps) above or below mag.vec to induce FTC
  FTC=freeze.thaw.analysis(data.list, mag.vec=1.5, dur.vec=8, thres.vec=0)
  
  #Combine FTC data output (Def1) with column_names 
  FTC.dat = cbind(FTC$data, column_names)
  
  #Measurements to exclude?
  Exclude = as.data.frame(rownames(NA_count)[NA_count$NA_count >= Max_NA])
  Exclude$Label = rep("Exclude", length(Exclude))
  colnames(Exclude)=c("column_names","Label")
  
  FTC.full <- Exclude %>% right_join(FTC.dat, by=c("column_names"))
  FTC.full$Label[is.na(FTC.full$Label)] = "Keep"
  
  FTC.full$Def1[FTC.full$Label == "Exclude"] <- NA
  FTC.full$season=rep(name,nrow(FTC.full))
  FTC.full$year=rep(year,nrow(FTC.full))
  
  #Split column to create factors (depth and core)
  FTC.full$column_names_2=FTC.full$column_names
  
  #Final FTC data
  FTC.full.final = FTC.full %>% separate(column_names_2, c("site","depth","core"), sep="_")
  
  #Core depths###################
  Sensor_Pos = y
  Sensor_Pos$HOR.VER.2 = Sensor_Pos$HOR.VER
  Sensor_Pos = Sensor_Pos %>% separate(HOR.VER.2, c("HOR", "VER"))  
  
  Sensor_Pos = Sensor_Pos[,c("siteID","HOR","VER","zOffset")]
  #220 rows
  
  #Remove duplicate rows? This works in this example, but it's not generalizable. 
  #Healy has two zOffsets. Negative values seem to be correct depths, keeping only first row of HEAL
  Sensor_Pos_Distinct = distinct_at(Sensor_Pos, vars(siteID, HOR, VER), .keep_all = TRUE)
  
  #Combine names for ID column
  Sensor_Pos_Distinct = as.data.frame(unite(Sensor_Pos_Distinct, "column_names", c(siteID, VER, HOR), sep = "_", remove = FALSE))
  
  colnames(Sensor_Pos_Distinct)=c("column_names","site_pos","core_pos","depth_pos","depth_m")
  
  #Combine with FTC calculations
  FTC.all = Sensor_Pos_Distinct %>% right_join(FTC.full.final, by=c("column_names"))
  
#  setwd("raw")
  write.csv(FTC.all, paste0("FTC_1.5_4-",name, ".csv", sep="")) #Change append to name to make parameters in FTC function
  
}

for (i in 1:length(pos.dat)){
  cur.name=names(temp.dat)[i]
  FTC_1.5_4(x=temp.dat[[i]], 
            y=pos.dat[[i]], 
            name=cur.name,
            year=substr(cur.name, nchar(cur.name),nchar(cur.name)))
}

#Create final dataset########################################
setwd("raw")

FTC_1.5_4 = list.files(pattern="*.csv")

myfiles = lapply(FTC_1.5_4, read.csv)

combined_FTC_1.5_4 = do.call(rbind, myfiles)

combined_FTC_1.5_4$mag.vec=rep("1.5",nrow(combined_FTC_1.5_4))
combined_FTC_1.5_4$dur.vec=rep("4",nrow(combined_FTC_1.5_4))

#Convert season to character and drop the last digit (this shouldn't happen in the function - why? For long term fixing...)
combined_FTC_1.5_4$season=as.character(combined_FTC_1.5_4$season)
combined_FTC_1.5_4$season = substr(combined_FTC_1.5_4$season, 1 , nchar(combined_FTC_1.5_4$season)-1)

#Back to factor....
combined_FTC_1.5_4$season=as.factor(combined_FTC_1.5_4$season)

final_FTC_1.5_4=combined_FTC_1.5_4[,-1]

saveRDS(final_FTC_1.5_4, file = "FTC_1.5_4.RData") 
write.csv(final_FTC_1.5_4, "FTC_1.5_4.csv")

