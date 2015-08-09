# Plot 3

# Load required libraries
require(dplyr)
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
# Of the four types of sources indicated by the type (point, nonpoint, onroad, 
# nonroad) variable, which of these four sources have seen decreases in 
# emissions from 1999–2008 for Baltimore City (fips == "24510")? Which have seen
# increases in emissions from 1999–2008? Use the ggplot2 plotting system to make
# a plot answer this question.
###############################################################################

# Limit dataset to Baltimore City readings
bc <- subset(NEI,fips == "24510")

# Transform the dataframe into a tbl via dplyr package for further cleanup
data <- tbl_df(bc)

# Group the data by year for easier summarization
data <- group_by(data,year,type)

# Summarize the data by calculating a sum for each year
dp <- summarize(data, sum(Emissions))

# Clean up the column names
names(dp) <- c("Year","Type","Emissions")

# Plot it using the ggplot2 package
png(file="plot3.png", height=600, width=600)
print(
  qplot(Year, Emissions, data=dp, color=Type) + 
  facet_grid(.~Type) + 
  facet_wrap( ~Type, ncol=2) +
  geom_line(aes(group=1)) +
  geom_point(aes(group=1),size=2,shape=19) +
  theme(legend.position="none") +
  ggtitle("PM2.5 Emissions by Type - Baltimore City") +
  labs(title = "PM2.5 Emissions by Type in Baltimore City, MD",
       x = "Years",
       y = "PM2.5 Emissions (Tons)")
)
dev.off()
