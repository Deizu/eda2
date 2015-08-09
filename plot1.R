# Plot 1

# Load required libraries

require(dplyr)

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

# NEI$Pollutant <- as.factor(NEI$Pollutant)
# NEI$year <- as.factor(NEI$year)
# NEI$type <- as.factor(NEI$type)

############################################################################### 
# Have total emissions from PM2.5 decreased in the United States from 1999 to
# 2008? Using the base plotting system, make a plot showing the total PM2.5
# emission from all sources for each of the years 1999, 2002, 2005, and 2008.
###############################################################################

data <- tbl_df(NEI)
data <- group_by(data,year)
dp <- summarize(data, sum(Emissions))
names(dp) <- c("Year","Total")
png(file="plot1.png", height=600, width=600)
plot(dp$Year, dp$Total, typ="b", xlab="Year", ylab="Total Emissions (Tons)",
     main="PM2.5 Emissions in the US")
dev.off()