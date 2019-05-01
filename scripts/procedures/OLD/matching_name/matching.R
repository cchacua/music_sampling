# Table of main_artist IDs: the source of the loop
main_art<- dbGetQuery(con, "SELECT DISTINCT a.id FROM musicbrainz.whosam_mb_nonmatched a")



match_rec<-function(artistid){
  # Table 1: recordings in WS that have not been matched but that have a main artist MB id
  one <- dbGetQuery(con, paste0("SELECT a.*
                                      FROM musicbrainz.whosam_mb_nonmatched a 
                                      WHERE a.id='", artistid ,"'
                                      ORDER BY a.track_name"))
  
  one$track_name <-toupper(one$track_name)
  print(one$track_name)
  # Table 2: recordings in MB that are produced by the main artists that appear in WS
  two <- dbGetQuery(con, paste0("SELECT a.* 
                                      FROM musicbrainz.wsmb_nm_rec a
                                      WHERE a.mb_art_id='", artistid ,"'
                                      ORDER BY a.rec_name"))
  
  two$rec_name <-toupper(two$rec_name)
  print(two$rec_name)
  matches <- partialMatch(one$track_name, two$rec_name, levDist=0.1)
  if(nrow(matches)>0){
    result <- merge(one, matches, by.x="track_name",by.y='raw.x',all.x=T)
    result <- merge(result, two, by.x='raw.y',by.y="rec_name",all.x=T)
    result<-result[,c(1:8,10,13:22)]
    write.csv(result, paste0("../output/rec_matched/",artistid,".csv"))
    return(result<-unique(result))
  }
  else(return(result<-"None"))
  #list(wsmb_nm=wsmb_nm,mb_rec=mb_rec)
}

lapply(files.part1ba_f[1:length(files.part1ba_f)],
       function(x) tryCatch(get_nationalities_batch(x), error=function(e) print("Not done")))

match_rec(main_art[7,1])

# The most frequent in the family in the first release, if they have the same year. In case of a tie, the first on the list
# Location of the artists  
  