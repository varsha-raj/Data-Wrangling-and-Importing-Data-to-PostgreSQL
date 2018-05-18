
library(RPostgreSQL)
library(RODBC)
library(dplyr)
library(lubridate)

Sys.setenv(TZ='EST')
options(error=recover)
options(warn=-1)
options(stringsAsFactors=FALSE)
options(scipen=999)
#Connect to postgres database

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "mars_testing",

	host = "hostname", port = 5432,

	user = "postgres",

	password = "pwd")
#Query rain gage table
rg_marsdb <- dbGetQuery(con, "SELECT * FROM rainfall_gage")

dbDisconnect(con)

#Local rain gage access database
db <- "raingage.mdb"

mychannel <- odbcConnectAccess2007(db)

rg_masterdb <-sqlFetch(mychannel,"tblModelRain")

rg_masterdb$DateTime <- ymd_hms(rg_masterdb$DateTime, tz = "EST")

rg_masterdb <-select(rg_masterdb, -FillFlag)

names(rg_masterdb) <- c('gage_uid', 'dtime_est', 'rainfall_in')

if(nrow(rg_masterdb) > nrow(rg_marsdb)) {

	
#Extract only new data
	new_df <- anti_join(rg_masterdb, rg_marsdb, by = c('gage_uid', 'dtime_est')) 
	

#Append new data to existing records in postrgres database
	dbWriteTable(con, "rainfall_gage", new_df, append= TRUE, row.names = FALSE)
	

	dbDisconnect(con)

} else {print("There is no new data.")}




