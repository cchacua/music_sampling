library(RPostgreSQL)
source("../connector/postgre_connector.R")


library(shiny)
require(shinydashboard)
library(ggplot2)
library(dplyr)

open.rdata<-function(x){local(get(load(x)))}
