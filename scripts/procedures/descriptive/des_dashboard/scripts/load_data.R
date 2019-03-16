open.rdata<-function(x){local(get(load(x)))}


output_folder<-"/home/christian/github_new/music_sampling"

source_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/source_DISTINCT_count.RData"))
dest_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/dest_DISTINCT_count.RData"))
all_c<-open.rdata(paste0(output_folder,"/output/dashboard_data/all_count.RData"))


