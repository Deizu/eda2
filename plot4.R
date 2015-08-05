# Plot 4

# Load required libraries

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
# Across the United States, how have emissions from coal combustion-related
# sources changed from 1999–2008?
###############################################################################

coalindex <- grep("coal|Coal",SCC$Short.Name)
coalrelated <- SCC[coalindex,]
coalindex <- as.vector(unique(coalrelated$SCC))
coalindex <- NEI$SCC %in% coalindex
coaldata <- NEI[coalindex,]
coalcomplete <- left_join(coaldata,coalrelated,by=c("SCC" = "SCC"))
coalcomplete <- tbl_df(coalcomplete)
coalcomplete <- group_by(coalcomplete,year)
coalsum <- summarize(coalcomplete,emissions=sum(Emissions))
names(coalsum) <- c("Year","Emissions")

png(file="plot4.png", height=480, width=480)
plot(coalsum$Year, coalsum$Emissions, xlab="Year", ylab="Total Emissions (Tons)",
     main="PM2.5 Emissions from Coal Combustion Related Sources", typ="b")
dev.off()