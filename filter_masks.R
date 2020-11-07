#Import libraries
library(dplyr)

#### Data Reduction ####

#Search result (2020/02/22) - 15315 objects 

#Load data - 10014 objects
df <- read.csv('data/data_1.csv', stringsAsFactors = F)
df$Index <- NULL

#Remove duplicates - 9931 objects (Objects with large enough image)
df <- df[!duplicated(df),]

#Remove non-masks - 8779 objects
df <- df[df$Features == "cephalomorphic",]
df <- df[df$Categories != FALSE,]
df$Features <- NULL

#Remove missing data - 6948 objects
df <- df[complete.cases(df),]

'%!in%' <- function(x,y)!('%in%'(x,y))
invalid_regions <- c(",", "@", "April", "Duke", "Goodnews", "Great", "King",
                     "Grasslands","North","South","Central","Southeastern",
                     "Southwestern","Western","Eastern","West","East","Central",
                     "Northwest","Woodlands","Inland","Lower","Upper","Middle",
                     "Northeastern","Cross","Bella","Haida","Zimbabwe","Carribbean",
                     "Guam","Panama")
df <- df[df$Region %!in% invalid_regions,]

invalid_periods = c("IXth","ACA", "CA","Protoclassic","XIVth")
df <- df[df$Period %!in% invalid_periods,]

#### Fix Factors ####

#Region names
df <- df %>% mutate(Region=recode(Region, 
                    "Democratic"="Democratic Republic of the Congo",
                    "Ivory"="Ivory Coast",
                    "Rio" = "Brazil",
                    "Amazon" = "Brazil",
                    "Chile" = "Argentina",
                    "Republic" = "Democratic Republic of the Congo",
                    "State" = "Mexico",
                    "Himalaya" = "Nepal",
                    "Equatorial" = "Equatorial Guinea",
                    "Gulf" = "Papua New Guinea",
                    "Hunan" = "Papua New Guinea",
                    "New" = "Papua New Guinea",
                    "Prince" = "Papua New Guinea",
                    "Point" = "Alaska",
                    "Batie" = "Cameroon",
                    "Chambri" = "Papua New Guinea",
                    "British" = "British Columbia",
                    "Vancouver" = "British Columbia",
                    "St." = "Alaska",
                    "Esmeraldas" = "Ecuador",
                    "Sierra" = "Sierra Leone",
                    "Angriman" = "Papua New Guinea",
                    "Arunachal" = "India",
                    "Bafum" = "Cameroon",
                    "Benin" = "Nigeria",
                    "Blackwater" = "Papua New Guinea",
                    "Burkina" = "Burkina Faso",
                    "Gazelle" = "Papua New Guinea",
                    "Guanacaste" = "Mexico",
                    "Guizhou" = "China",
                    "Hunstein" = "Papua New Guinea",
                    "Ituri" = "Democratic Republic of the Congo",
                    "Izapa" = "Guatemala",
                    "Kalimantan" = "Indoneasia",
                    "Kanduanam" = "Papua New Guinea",
                    "Kasai" = "Democratic Republic of the Congo",
                    "Kathmandu" = "Nepal",
                    "Keram" = "Papua New Guinea",
                    "Kuskokwim" = "Alaska",
                    "Malekula" = "Vanuatu",
                    "Maniema" = "Democratic Republic of the Congo",
                    "Maprik" = "Papua New Guinea",
                    "Mimika" = "Indonesia",
                    "Nagaland" = "India",
                    "Nass" = "British Columbia",
                    "Orokolo" = "Indonesia",
                    "Purari" = "Papua New Guinea",
                    "Quinhagak" = "Alaska",
                    "Ramu" = "Papua New Guinea",
                    "Sarawak" = "Indonesia",
                    "Shandong" = "China",
                    "Sichuan" = "China",
                    "Tabar" = "Papua New Guinea",
                    "Tami" = "Papua New Guinea",
                    "Terai" = "Nepal",
                    "Timor" = "Indonesia",
                    "Niger" = "Nigeria",
                    "Toba" = "Indonesia",
                    "Vokeo" = "Papua New Guinea",
                    "Washkuk" = "Papua New Guinea",
                    "Yao" = "China",
                    "Yuat" = "Papua New Guinea",
                    "Yunnan" = "China"))
print(paste(length(table(df$Region)), "Regions"))

#Time period
df <- df %>% mutate(Period=recode(Period, 
                    "XVIIIth" = "18th",
                    "XXth" = "20th",
                    "XIXth" = "19th",
                    "XIX-XXth" = "19-20th",
                    "Early" = "3-6th",
                    "Classic" = "6-7th",
                    "Late" = "8-9th",
                    "Middle" = "6-7th"))

table(df$Period)
print(paste(length(table(df$Period)), "Centuries"))
rm(invalid_periods, invalid_regions, "%!in%")

#Remove superfluous data
df$Index <- seq(1,nrow(df))
df <- df[,c("Index","Image","Page.URL","Region","Period","Culture","Materials","Size")]

#### Save Progress ####

#Copy relevant images
# file.copy(from=df$Image, to="images2", 
#           overwrite = TRUE, recursive = FALSE, 
#           copy.mode = TRUE)
# 
# write.csv(df, "data/data_2.csv", row.names = F)
