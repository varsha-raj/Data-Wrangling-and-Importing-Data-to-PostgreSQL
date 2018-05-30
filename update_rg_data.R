#Required Libraries
library(RPostgreSQL)
library(RODBC)
library(dplyr)
library(lubridate)

#Global environment settings, can be added to user's Rprofile
Sys.setenv(TZ='EST')
options(error=recover)
options(warn=1) # -1 ignores all warning and 1 throws warnings as they occur
options(stringsAsFactors=FALSE)
options(scipen=999)

#Connect to postgres database
con <- odbcConnect(dsn = "mars_testing")

#Query 'rain gage' table from MARS database
rg_marsdb <- sqlFetch(con, "rainfall_gage", as.is = TRUE)

#format datetime column and rainfall column to specific class types (posixct/numeric values repectively)
rg_marsdb$dtime_est <- ymd_hms(rg_marsdb$dtime_est, tz = "EST")

rg_marsdb$rainfall_in <- as.numeric(as.character(rg_marsdb$rainfall_in))

#Query 'gage' table from MARS database
rg_name <- sqlFetch(con, "gage", as.is = TRUE)

#close connection
odbcClose(con)

#create a new dataframe merging rg_marsdb and rg_name dataframes using gage_uid
merged_df <- merge(rg_marsdb, rg_name, by= 'gage_uid', all = TRUE) 

#File path to rain gage data saved in local directory
db <- "D:/CSORain2010.mdb"

channel <- odbcConnectAccess2007(db) #connect to access database

rg_masterdb <-sqlFetch(channel,"tblModelRain", as.is = TRUE) #Query rainfall data

odbcClose(channel)

#Formatting rain gage master database columns to specific classtypes
rg_masterdb$DateTime <- ymd_hms(rg_masterdb$DateTime, tz = "EST")
rg_masterdb$Rainfall <- as.numeric(as.character(rg_masterdb$Rainfall))

# This specifically converts gagename column of integer class type to character 
# This allows to merge easily with the mars database dataframes
rg_masterdb <- rg_masterdb %>%
               mutate_if(is.integer , as.character) %>%
               select(everything(), - FillFlag)


#Rename column names to match those in the MARS database raingage table
names(rg_masterdb) <- c('gagename', 'dtime_est', 'rainfall_in')

if(nrow(rg_masterdb) > nrow(rg_marsdb)) {

	#Extract only the new data
	new_df1 <- anti_join(rg_masterdb, merged_df, by = c('gagename', 'dtime_est')) 


	#join the new data with rg_gage dataframe using gagename
	#keep gageuid and remove gagename column from this new data
	new_df2 <- inner_join(new_df, rg_name, by= 'gagename') %>%

	                select(gage_uid, everything(),-gagename)


	
    #Append new data to the existing rain gage table in MARS database 

    con <- dbConnect(PostgreSQL(), dbname = "mars_testing",

	host = "hostname", port = 5432,

	user = "postgres",

	password = .rs.askForPassword('Enter password:'))

	dbWriteTable(con, "rainfall_gage", new_df2, append= TRUE, row.names = FALSE)
	

	dbDisconnect(con)

} else {print("There is no new data.")}





