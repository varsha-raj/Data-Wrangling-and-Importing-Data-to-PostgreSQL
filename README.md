# Data-Wrangling-and-Importing-Data-to-PostgreSQL

Simple R code to process rainfall data from an access database in a local directory and importing only the new data to an already existing table in postgreSQL

There are two main ways to connect to a database, one is via ODBC (Open DataBase Connectivity) and the other is the DBI (DataBase Interface).

RODBC allows you to access the ODBC's capabilities from within R and RpostgreSQL provides an R interface to the PostgreSQL database.

[read more on RpostgreSQL](https://cran.r-project.org/web/packages/RPostgreSQL/RPostgreSQL.pdf) 
[read more on RODBC](https://cran.r-project.org/web/packages/RODBC/RODBC.pdf)

To install these packages, type the following command at the command prompt in the R console:
*install.packages("RODBC")*
*install.packages("RPostgreSQL")*

For the script to work effectively, ensure relevant ODBC drivers are installed.

With RODBC, one can establish a DSN (Data Source Name) in the ODBC source administrator. DSN has all the relevant information that describes the connection.
This way only DSN needs to be provided each time connection is made.

With RPostgreSQL however, all the relevant information should be provided from within R each time a coonection is made.

RpostgreSQL's *dbGetQuery* function to read the data from the database is only good when working with small datasets. For this reason, RODBC's *sqlFetch* will be used to read data from the database. 

RODBC's *sqlUpdate* does not automatically fill primary keys when the new data is appended to the the existing database. An alternative to this is using the *dbWriteTable* from RpostgreSQL. 

For this reason, this R script uses a combination of both RODBC and RpostgreSQL packages.

The script read three tables, two from the postgresSQL. Data from access database is used to update the raingage table in postgres database:
1. gage dummy data:

| gage_uid | gagename |
| ---      | ---      |
| 1		   | 1        |
| 1        | 1        |
| .        | .        |
| .        | .        |
| 10       | 10       |
| 10       | 10       |
| .        | .        |
| .        | .        |
| 40       | 40       |

2. rainfall_gage dummy data:

| rainfall_gage_uid | gage_uid | datetime_est        | rainfall_in |
| ---               | ---      | ---                 |             |
| 1		   			| 1        | 1990-01-01 00:15:00 | 0.2         |
| 2        			| 1        | 1990-01-01 00:30:00 | 0.01        |
| 3        			| 1        | 1990-01-01 00:45:00 | 0           |
| 4        			| 1        | .					 | .           |
| 5        			| 1        | .                   | .           |
| 6        			| 1        | 2018-02-16 05:45:00 | .           |       
| .        			| .        | .                   | .           |
| .        			| .        | .                   | 0.05        |
| 1190618        	| 40       | 2018-02-16 05:45:00 | 0.23        |


3. raingage_data dummy data (access database)

| gageno   | datetime_est        | rainfall_in |
| ---      | ---                 |             |
| 1        | 1990-01-01 00:15:00 | 0.2         |
| 1        | 1990-01-01 00:30:00 | 0.01        |
| 1        | 1990-01-01 00:45:00 | 0           |
| 1        | .					 | .           |
| 1        | .                   | .           |
| 1        | 2018-04-30 05:45:00 | 0.05        |     
| .        | .                   | .           |
| .        | .                   | 0.05        |
| 40       | 2018-04-30 05:45:00 | 0.08        |
