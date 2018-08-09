#df_postgres <- dbGetQuery(con, "SELECT a.* FROM musicbrainz.recording a LIMIT 10 OFFSET 2;")

#######################################################

countings_preliminary<-function(type="s"){
  print("Type s for source and d for destination")
  
  # Number of matched source songs (or the songs that appear in both MB and WIS)
  source_songs_m <- dbGetQuery(con, 
                               "SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid;")
  
  # Number of source songs with MB ID in WIS
  source_songs_nm_mb <- dbGetQuery(con, 
                                   "SELECT COUNT(DISTINCT a.source_track_musicbrainz_id)
                            FROM musicbrainz.whois a;")
  
  
  # Number of total source songs in WIS (Using track_id)
  source_songs_t <- dbGetQuery(con, 
                               "SELECT COUNT(DISTINCT a.source_track_id)
                            FROM musicbrainz.whois a;")
  
}



#######################################################
# Number of matched destination songs
desti_songs_m <- dbGetQuery(con, 
                           "SELECT COUNT(DISTINCT b.dest_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording a
                            ON b.dest_track_musicbrainz_id=a.gid;")
# desti_songs_ <- dbGetQuery(con,
#                           "SELECT COUNT(DISTINCT a.gid)
#                             FROM musicbrainz.whois b
#                             INNER JOIN musicbrainz.recording a
#                             ON b.dest_track_musicbrainz_id=a.gid;")

# Number of total destination songs
desti_songs_t <- dbGetQuery(con, 
                              "SELECT COUNT(DISTINCT a.dest_track_name)
                            FROM musicbrainz.whois a;")

#######################################################
# Number of links with the missing source ID 

desti_songs_t <- dbGetQuery(con, 
                            "SELECT COUNT(DISTINCT a.dest_track_name)
                            FROM musicbrainz.whois a;")





