library(magrittr)
library(tidyr)

data.df<-read.csv2("../whosampled/CSV.csv")
genres.df<-read.csv("../whosampled/genres.csv")

colnames(data.df)

# Level 1
connections<-unique(data.df[,c(1:4,13)])
write.csv(connections, "../output/pre_cleaning/connections.csv")

# Level 2
recordings1<-unique(data.df[,c(4:12)])
recordings2<-unique(data.df[,c(13:21)])
recordings_colnames<-substr(colnames(recordings1),6,nchar(colnames(recordings1)))

colnames(recordings1)<-recordings_colnames
colnames(recordings2)<-recordings_colnames

recordings<-unique(rbind(recordings1,recordings2))
recordings<-recordings[order(recordings$track_name,recordings$track_release_year, recordings$track_main_artist_name),]
write.csv(recordings,"../output/pre_cleaning/recordings.csv")
rm(connections,recordings1,recordings2,recordings_colnames)


recordings<-read.csv("../output/pre_cleaning/recordings.csv")

colnames(recordings)

# recordings_dup1<-recordings[duplicated(recordings[,c(2,3)]),]
recordings_dup1<-recordings[recordings$track_id  %in% c(469704,448759,537790),]

recordings_dup1 %>%
  spread(data = ., key = track_name, value = Value)


# https://stackoverflow.com/questions/51912898/r-error-in-varying-i-incorrect-number-of-dimensions-when-reshaping-from


# recordings$
# recordings_dup2<-reshape(transform(recordings_dup1, time=ave(track_id, track_name, track_release_year, FUN=seq_along)), idvar=c("track_name", "track_release_year"), direction="wide")
# 
# recordings_dup2<-reshape(recordings_dup1, timevar="track_id", idvar = c("track_name","track_release_year"), direction = "wide")
# 
# df3 <- data.frame(school = rep(1:3, each = 4), class = rep(9:10, 6),
#                   time = rep(c(1,1,2,2), 3), score = rnorm(12))
# wide <- reshape(df3, idvar = c("school","class"), direction = "wide")
# wide


# write.csv("../output/pre_cleaning/artists.csv")

