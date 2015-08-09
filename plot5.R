# Plot 5

# Load required libraries

require(dplyr)
require(tidyr)
require(ggplot2)

# Check for data and download it if needed

if(!file.exists("./data")) {dir.create("./data")}
if(!file.exists("./data/summarySCC_PM25.rds")
   | !file.exists("./data/Source_Classification_Code.rds")) {
  
  dataurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  
  download.file(dataurl, destfile="./data/data.zip", mode='wb')
  
  unzip(zipfile="./data/data.zip", files=NULL, list=FALSE, overwrite=FALSE, 
        junkpaths=FALSE, exdir=paste(getwd(),"/data",sep=""), unzip="internal",
        setTimes=FALSE)
  
  rm(dataurl)
}

# Read data into environment

NEI <- readRDS("./data/summarySCC_PM25.rds")
SCC <- readRDS("./data/Source_Classification_Code.rds")

###############################################################################
# How have emissions from motor vehicle sources changed from 1999–2008 in
# Baltimore City (fips == "24510")?
###############################################################################

# Limit dataset to Baltimore City readings
bc <- subset(NEI,fips == "24510")

# Reduce SCC dimensions to code identifier and sector description
scc <- SCC[,c("SCC","EI.Sector")]

# Get rid of extraneous data to keep the environment clutter free
rm(SCC)

# Generate a vector of codes with sector descriptions related to vehicles
vehicles <- grep("vehicles|Vehicles",scc$EI.Sector)

# Subset the codes list by the vehicle vector above
codes <- scc[vehicles,]

# Drop row names for cleaner data
row.names(codes) <- NULL

# Limit the data emissions data frame to rows matching the code list
nei <- bc[(bc$SCC %in% codes$SCC),]

# Join the data emissions data to the matching codes from the list
## NOTE: THIS TAKES A LONG TIME ON THIS DATA! BE PATIENT!
complete <- left_join(nei,codes,by=c("SCC" = "SCC"))

# Transform the dataframe into a tbl via tidyr package for further cleanup
complete <- tbl_df(complete)

# Group the data by year for easier summarization
complete <- group_by(complete,year)

# Summarize the data by calculating a sum for each year
summary <- summarize(complete,emissions=sum(Emissions))

# Clean up the column names
names(summary) <- c("Year","Emissions")

# Plot it with ggplot2
png(file="plot5.png", height=600, width=600)
print(
  qplot(summary$Year, summary$Emissions) +
    geom_line() +
    labs(title="Motor Vehicle Related PM2.5 Emissions in Baltimore City, MD", 
         x="Years", 
         y="PM2.5 Emissions (in Tons)")
)
dev.off()