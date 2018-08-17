#######################################################

countings_type<-function(type="s", dis=TRUE){
  print("type: Type s for source and d for destination")
  if(type=="s"){
    type<-"source"
  }
  if(type=="d"){
    type<-"dest"
  }
  else{"Type either s or d"}
  
  if(dis==TRUE){
    dis<-"DISTINCT"
  }
  if(dis==FALSE){
    dis<-""
  }
  else{"dis: Type TRUE of FALSE"}
  
  # Number of matched songs of type s or d (or the songs that appear in both MB and WIS)
  matched<- dbGetQuery(con, paste0("SELECT COUNT(e.",type,"_track_id)
                                        FROM (
                                          SELECT ",dis, " b.",type,"_track_id
                                          FROM musicbrainz.whois b
                                          INNER JOIN musicbrainz.recording a
                                          ON b.",type,"_track_musicbrainz_id=a.gid
                                          UNION
                                          SELECT ",dis, " c.",type,"_track_id
                                          FROM musicbrainz.whois c
                                          INNER JOIN musicbrainz.recording_gid_redirect d
                                          ON c.",type,"_track_musicbrainz_id=d.gid) e;"))
  
  # WITH MB ID
  # "SELECT COUNT(",dis, " b.",type,"_track_musicbrainz_id)
  #                           FROM musicbrainz.whois b
  #                           INNER JOIN musicbrainz.recording a
  #                           ON b.",type,"_track_musicbrainz_id=a.gid;"
  
  
  
  
  # Number of s/d recordings with MB ID in WIS (USING RECORDING ID)
  # wis_id <- dbGetQuery(con, 
  #                      paste0("SELECT COUNT(",dis, " a.",type,"_track_musicbrainz_id)
  #                           FROM musicbrainz.whois a;"))
  
  # Number of s/d songs with MB ID in WIS (Using WS ID)
  wis_id <- dbGetQuery(con, 
                       paste0("SELECT COUNT(",dis, " a.",type,"_track_id)
                            FROM musicbrainz.whois a
                            WHERE a.",type,"_track_musicbrainz_id IS NOT NULL;"))
  
  # Number of total s/d songs in WIS (Using track_id)
  wis_t <- dbGetQuery(con, 
                      paste0("SELECT COUNT(",dis, " a.",type,"_track_id)
                            FROM musicbrainz.whois a;"))
  
  output<-list(matched=matched, wis_id=wis_id, wis_t=wis_t)
  
  save(output, file=paste0("../output/dashboard_data/",type,"_",dis,"_count.RData"))
  #return(list(matched=matched, wis_id=wis_id, wis_t=wis_t))
  return("Done")
}

countings_all<-function(){
  print("All types covered")
  
  # Number of matched songs (or the songs that appear in both MB and WIS)
  matched<- dbGetQuery(con,"SELECT COUNT(DISTINCT e.id) 
                       FROM (
                       SELECT DISTINCT a.source_track_musicbrainz_id AS id
                       FROM musicbrainz.whois a
                       INNER JOIN musicbrainz.recording b
                       ON a.source_track_musicbrainz_id=b.gid
                       UNION
                       SELECT DISTINCT c.dest_track_musicbrainz_id AS id
                       FROM musicbrainz.whois c
                       INNER JOIN musicbrainz.recording d
                       ON c.dest_track_musicbrainz_id=d.gid) e
                       ;")
  
  # Number of songs with MB ID in WIS
  wis_id <- dbGetQuery(con, "SELECT COUNT(DISTINCT c.id) 
                       FROM (
                       SELECT DISTINCT a.source_track_musicbrainz_id AS id
                       FROM musicbrainz.whois a
                       UNION
                       SELECT DISTINCT b.dest_track_musicbrainz_id AS id
                       FROM musicbrainz.whois b) c
                       ;")

  # Number of total s/d songs in WIS (Using track_id)
  wis_t <- dbGetQuery(con, "SELECT COUNT(DISTINCT c.id) 
                      FROM (
                      SELECT DISTINCT a.source_track_id AS id
                      FROM musicbrainz.whois a
                      UNION
                      SELECT DISTINCT b.dest_track_id AS id
                      FROM musicbrainz.whois b) c
                      ;")
  
  output<-list(matched=matched, wis_id=wis_id, wis_t=wis_t)
  
  save(output, file=paste0("../output/dashboard_data/all_count.RData"))
  #return(list(matched=matched, wis_id=wis_id, wis_t=wis_t))
  return("Done")
}

#############################################
 source<-countings_type("s")
 #source<-countings_type("s")

 dest<-countings_type("d")
 all<-countings_all()
#############################################

countings_type<-function(){
   print("link")
  
   # Number links
   links<- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT b.",type,"_track_musicbrainz_id)
                                    FROM musicbrainz.whois b
                                    INNER JOIN musicbrainz.recording a
                                    ON b.",type,"_track_musicbrainz_id=a.gid;"))
   
   output<-list(matched=matched, wis_id=wis_id, wis_t=wis_t)
   
   save(output, file=paste0("../output/dashboard_data/",type,"_count.RData"))
   #return(list(matched=matched, wis_id=wis_id, wis_t=wis_t))
   return("Done")
 }
 



