# Plot 2

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

###############################################################################
# Have total emissions from PM2.5 decreased in the Baltimore City, Maryland
# (fips == "24510") from 1999 to 2008? Use the base plotting system to make a
# plot answering this question.
###############################################################################

# Limit dataset to Baltimore City readings
bc <- subset(NEI,fips == "24510")

# Transform the dataframe into a tbl via dplyr package for further cleanup
data <- tbl_df(bc)

# Group the data by year for easier summarization
data <- group_by(data,year)

# Summarize the data by calculating a sum for each year
dp <- summarize(data, sum(Emissions))

# Clean up the column names
names(dp) <- c("Year","Total")

# Plot it using the base package
png(file="plot2.png", height=600, width=600)
plot(dp$Year, dp$Total, typ="b", xlab="Year", ylab="Total Emissions (Tons)",
     main="PM2.5 Emissions in Baltimore City, MD")
dev.off()