library(stringr)

ws<-read.csv2("../whosampled/CSV.csv")
write.csv(ws, "../whosampled/whosampled.csv", row.names = FALSE)
#colnames(ws)

# Unique destination songs
ws_uds<-unique(ws[,4:12])
# 318455 unique destination songs
# Unique source songs
ws_uss<-unique(ws[,13:21])
# 109114 unique source songs
cname<-str_replace(colnames(ws_uds),"dest_track_", "")
colnames(ws_uss)<-cname
colnames(ws_uds)<-cname
cname

###########################################################################
# A list of unique songs for both source and destination
###########################################################################
  ws_ubs<-unique(rbind(ws_uss, ws_uds))
  # 404828 unique songs
  length(unique(ws_ubs$id))
  # 404827 unique ids
    
  ws_ubs_did<-data.frame(duplicate=duplicated(ws_ubs$id), id=ws_ubs$id)
  # There is just one duplicated ID
    ws_ubs_did[ws_ubs_did$duplicate==TRUE,]
    View(ws_ubs[ws_ubs$id=="64015",])
    #       id                 name release_year main_genre main_artist_id
    # 45124  64015 You're Still the One         1998          R           4995
    # 305425 64015 You're Still the One         1997          R           4995
    # main_artist_name  youtube_id                       musicbrainz_id
    # 45124      Shania Twain KNZH-emehxA 2ac1b488-18fb-4c78-82ab-be34b9c57f32
    # 305425     Shania Twain KNZH-emehxA 2ac1b488-18fb-4c78-82ab-be34b9c57f32
    # main_artist_musicbrainz_id
    # 45124  faabb55d-3c9e-4c23-8779-732ac2ee2c0d
    # 305425 faabb55d-3c9e-4c23-8779-732ac2ee2c0d
    
    # I put the oldest date for booth, althought one is the country version and the other is the pop version
    # https://www.discogs.com/Shania-Twain-Youre-Still-The-One/master/132429
    ws_ubs[ws_ubs$id=="64015" & ws_ubs$release_year==1998,]<-ws_ubs[ws_ubs$id=="64015" & ws_ubs$release_year==1997,]
    ws_ubs<-unique(ws_ubs)
    
###########################################################################
# A list of unique artists
###########################################################################
ws_uba<-unique(ws_ubs[,c(5,6,9)])
ws_uba<-ws_uba[order(ws_uba$main_artist_id),]
#92159 artists, although there are some problems in the names (e.g. () or numbers)
length(unique(ws_uba$main_artist_id))
length(unique(ws_uba$main_artist_name))
# Weird stuff
ws_ubs[ws_ubs$main_artist_id==117172,]
# id                                name release_year main_genre
# 336383 443090    Speech to Reichstag Sept 1, 1939         1939          P
# 403512 533002 Last Radio Speech 30th January 1945         1975          O
# main_artist_id main_artist_name  youtube_id musicbrainz_id
# 336383         117172     Adolf Hitler nnP-KlNVE2E               
# 403512         117172     Adolf Hitler X1h-UpXwiKc               
# main_artist_musicbrainz_id
# 336383                           
# 403512     

# NA artists
ws_uba_na<-ws_uba[ws_uba$main_artist_musicbrainz_id=="",]
#30330 artists without MB artist ID
# Non NA artists
ws_uba_nna<-ws_uba[ws_uba$main_artist_musicbrainz_id!="",]
length(unique(ws_uba_nna$main_artist_musicbrainz_id))
# 61097
ws_uba_nna_dup<-ws_uba_nna[duplicated(ws_uba_nna$main_artist_musicbrainz_id)==TRUE,]
# 732 MB_artists ID duplicates
# Some examples
ws_uba_nna[ws_uba_nna$main_artist_musicbrainz_id=="f1edfbed-9315-4550-859c-599cc3fdee57",]
main_artist_id main_artist_name           main_artist_musicbrainz_id
# 1431             9958     Willie Colón f1edfbed-9315-4550-859c-599cc3fdee57
# 320842          62165     Willie Colon f1edfbed-9315-4550-859c-599cc3fdee57

ws_uba_nna_dupall<-ws_uba_nna[ws_uba_nna$main_artist_musicbrainz_id %in% ws_uba_nna_dup$main_artist_musicbrainz_id,]
# I need to do a merge with MB to get a single name and create my own ID

pmatch<-partialMatch(ws_uba_na$main_artist_name[1:100], ws_uba_nna$main_artist_name, 0.01)    




# Using MBartistID -> get a name and assign a new ID to ws_uba_nna
# 
