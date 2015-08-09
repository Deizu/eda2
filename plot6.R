# Plot 6

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
# Compare emissions from motor vehicle sources in Baltimore City (fips ==
# "24510") with emissions from motor vehicle sources in Los Angeles County,
# California (fips == "06037"). Which city has seen greater changes over time in
# motor vehicle emissions?
###############################################################################

# Limit dataset to Baltimore City & Los Angeles County readings
taleoftwocities <- subset(NEI,(fips == "24510" | fips == "06037"))

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
totc <- taleoftwocities[(taleoftwocities$SCC %in% codes$SCC),]

# Join the data emissions data to the matching codes from the list
## NOTE: THIS TAKES A LONG TIME ON THIS DATA! BE PATIENT!
complete <- left_join(totc,codes,by=c("SCC" = "SCC"))

# Transform the dataframe into a tbl via tidyr package for further cleanup
complete <- tbl_df(complete)

# Group the data by year for easier summarization
complete <- group_by(complete,fips,year)

# Summarize the data by calculating a sum for each year
summary <- summarize(complete,emissions=sum(Emissions))

# Clean up the column names
names(summary) <- c("Locale","Year","Emissions")

# Replace locale numerical codes with locale names
summary$Locale <- gsub("06037","Los Angeles County, CA",summary$Locale)
summary$Locale <- gsub("24510","Baltimore City, MD",summary$Locale)

# Plot it with ggplot2, include smoothed conditional mean
png(file="plot6.png", height=600, width=600)
print(
  qplot(Year, Emissions, data=summary, color=Locale) +
    geom_line() +
    labs(title="Motor Vehicle Related PM2.5 Emissions - Baltimore vs LA", 
         x="Years", 
         y="PM2.5 Emissions (Tons)") +
    theme(legend.position="top") +
    geom_smooth(method=lm,fill="light grey",linetype="dotted")
)
dev.off()