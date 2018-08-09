#df_postgres <- dbGetQuery(con, "SELECT a.* FROM musicbrainz.recording a LIMIT 10 OFFSET 2;")

#######################################################

countings_preliminary<-function(type="s"){
  print("Type s for source and d for destination")
  if(type=="s"){
    type<-"source"
  }
  if(type=="d"){
    type<-"dest"
  }
  else{"Type either s or d"}
  
  # Number of matched source songs (or the songs that appear in both MB and WIS)
  matched<- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT b.",type,"_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording a
                            ON b.",type,"_track_musicbrainz_id=a.gid;"))
  
  # Number of source songs with MB ID in WIS
  wis_id <- dbGetQuery(con, 
                       paste0("SELECT COUNT(DISTINCT a.",type,"_track_musicbrainz_id)
                            FROM musicbrainz.whois a;"))
  
  
  # Number of total source songs in WIS (Using track_id)
  wis_t <- dbGetQuery(con, 
                      paste0("SELECT COUNT(DISTINCT a.",type,"_track_id)
                            FROM musicbrainz.whois a;"))
  return(list(matched=matched, wis_id=wis_id, wis_t=wis_t))
}

source<-countings_preliminary("s")

source$matched

dest<-countings_preliminary("d")




