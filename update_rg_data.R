library(RPostgreSQL)
library(RODBC)
library(dplyr)
library(lubridate)

Sys.setenv(TZ='EST')
options(error=recover)
options(warn=-1)
options(stringsAsFactors=FALSE)
options(scipen=999)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "mars_testing",

	host = "28-ARATHEFFE2.water.gov", port = 5432,

	user = "postgres",

	password = "silly-monkey-antics")

rg_marsdb <- dbGetQuery(con, "SELECT * FROM rainfall_gage")

dbDisconnect(con)


db <- "D:/MARS/CSORain2010/CSORain2010.mdb"

mychannel <- odbcConnectAccess2007(db)

rg_masterdb <-sqlFetch(mychannel,"tblModelRain")

rg_masterdb$DateTime <- ymd_hms(rg_masterdb$DateTime, tz = "EST")

rg_masterdb <-select(rg_masterdb, -FillFlag)

names(rg_masterdb) <- c('gage_uid', 'dtime_est', 'rainfall_in')

if(nrow(rg_masterdb) > nrow(rg_marsdb)) {

	new_df <- anti_join(rg_marsdb, rg_masterdb, by = c('gage_uid', 'dtime_est')) %>%

	      	  mutate(rainfall_gage_uid = last(last_val):n()) %>% select(rainfall_gage_uid, everything())


	dbWriteTable(con, "rainfall_gage", new_df, append= TRUE, row.names = FALSE)

	dbDisconnect(con)

} else {print("There is no new data.")}




