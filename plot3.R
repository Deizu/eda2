# Plot 3

# Load required libraries

require(ggplot2)
require(tidyr)

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
# Of the four types of sources indicated by the type (point, nonpoint, onroad,
# nonroad) variable, which of these four sources have seen decreases in
# emissions from 1999–2008 for Baltimore City? Which have seen increases in
# emissions from 1999–2008? Use the ggplot2 plotting system to make a plot
# answer this question.
###############################################################################

NEI$Pollutant <- as.factor(NEI$Pollutant)
NEI$year <- as.factor(NEI$year)
NEI$type <- as.factor(NEI$type)
data <- tbl_df(NEI)
data <- group_by(data,year,type)
dp <- summarize(data, sum(Emissions))
names(dp) <- c("Year","Type","Emissions")

png(file="plot3.png", height=480, width=480)
qplot(Year, Emissions, data=dp, color=Type) + 
  facet_grid(.~Type) + 
  facet_wrap( ~Type, ncol=2) +
  geom_line(aes(group=1)) +
  geom_point(aes(group=1),size=2,shape=21,fill="white") +
  theme(legend.position="none")
dev.off()