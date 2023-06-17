#get flights
library(nycflights13)
library(lubridate)
library(dplyr)
#1. I want to know JetBlue Airways have flight depart/arrive from/to which airports

jb_departure <- flights %>%
  inner_join(airlines,by=c("carrier" = "carrier")) %>%
  filter(name == "JetBlue Airways")%>%
  inner_join(airports,by=c("origin"="faa")) %>%
  select(airways = name.x ,departure_airport = name.y)%>%
  unique()

jb_arrival <- flights %>%
  inner_join(airlines,by=c("carrier" = "carrier")) %>%
  filter(name == "JetBlue Airways")%>%
  inner_join(airports,by=c("dest"="faa")) %>%
  select(airways = name.x ,arrival_airport = name.y)%>%
  unique()


jb_route <- jb_departure %>%
  inner_join(jb_arrival,by=c("airways" = "airways"),relationship ="many-to-many")

jb_route


#2. I want to know the most departure airport of Jetblue Airways

most_jb_d <- flights %>%
  filter(carrier == 'B6')%>%
  inner_join(airports,by=c("origin" = "faa")) %>%
  count(name) %>%
  arrange(-n) %>%
  head(1)

most_jb_d  

#3 I want to know total flight from JFK to Austin Bergstrom Intl by airways

jfk_aus <- flights %>%
  filter(origin == 'JFK',dest == 'AUS') %>%
  inner_join(airlines,by=c("carrier"="carrier")) %>%
  group_by(name) %>%
  count()

jfk_aus

#4 I want to know top 3 airlines has least delay flights

least_delay <- flights %>%
  inner_join(airlines,by=c("carrier"="carrier")) %>%
  group_by(name) %>%
  mutate(delay = replace_na(dep_delay,0) + replace_na(arr_delay,0)) %>%
  summarise(total_delay = sum(delay)) %>%
  arrange(total_delay) %>%
  head(3)

least_delay

#5 I want to know most popular airways in 4th quarter of 2013

most_flight <- flights %>%
  filter(month %in% c(10,11,12)) %>%
  inner_join(airlines,by=c("carrier"="carrier")) %>%
  group_by(name)%>%
  summarise(total_flights = n()) %>%
  arrange(-total_flights) %>%
  head(3)

most_flight
