df<-read.csv2("../whosampled/CSV.csv")
genres<-read.csv("../whosampled/genres.csv")



df<-dbGetQuery(con, "SELECT * FROM musicbrainz.whois b")
genres_all<-rbind(unique(data.frame(id=df$dest_track_id, genre=df$dest_track_main_genre)),unique(data.frame(id=df$source_track_id, genre=df$source_track_main_genre)))
genres_all<- merge(genres_all, genres, by.x="genre", by.y="genre_id", all.x = TRUE)
genres_all<-unique(genres_all)
table(genres_all$genre)
