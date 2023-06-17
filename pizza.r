## Connect to PostgreSQL
library(RPostgreSQL)
library(tidyverse)
library(dplyr)
## Setup DB connection
con <- dbConnect(PostgreSQL(),
          host = "arjuna.db.elephantsql.com",
          port = 5432,
          user = "xxxxxx",
          password = "xxxxxxx",
          dbname = "xxxxxxx")


##Data Preparation
pizza_menu <- data.frame(id = 1:5,
                         name = c("Truffle","Hawaiian","Kimchi","Italian Sausage","Four Cheese"),
                         price_per_slices = c(5,3,2.5,4.5,3.5))

drinks <- data.frame(id = 1:3,
                     name = c("Coke","Coke Diet","Water"),
                     price = c(1.5,2,1))

customers <- data.frame(id=1:5,
                        name = c("Pepper","Lisa","Rose","Jisoo","Jennie")
                        )

customer_order <- data.frame(order_id = 1:5,
                             customer_id = 1:5)

pizza_order <- data.frame(order_id = 1:5,
                          pizza_id = 1:5,
                          number_of_slice = c(3,1,2,2,1))

drink_order <- data.frame (order_id = 1:5,
                           drink_id = c(1,2,3,2,1),
                           number_of_drink = c(2,1,1,1,1))

#Create Table into PostgreSQL without row.names
dbWriteTable(con,"pizza_menu",pizza_menu,row.names = FALSE)
dbWriteTable(con,"drinks",drinks,row.names = FALSE)
dbWriteTable(con,"customers",customers,row.names = FALSE)
dbWriteTable(con,"customer_order",customer_order,row.names = FALSE)
dbWriteTable(con,"pizza_order",pizza_order,row.names = FALSE)
dbWriteTable(con,"drink_order",drink_order,row.names = FALSE)

#List Table
dbListTables(con)

#I want to know what is best sales pizza and total revenue
pm<-dbGetQuery(con,"select * from pizza_menu")
po<-dbGetQuery(con,"select * from pizza_order")
best_sales_pizza <- pm %>%
  inner_join(po,by=c("id"="pizza_id"))%>%
  filter(number_of_slice == max(number_of_slice)) %>%
  mutate(total_revenue = price_per_slices * number_of_slice)
  
best_sales_pizza

#I want to know who order Coke and order with which pizza
do <- dbGetQuery(con,"select * from drink_order")
dm <- dbGetQuery(con,"select * from drinks")
cm <- dbGetQuery(con,"select * from customers")
co <- dbGetQuery(con,"select * from customer_order")

customer_coke_pizza <- cm %>%
  inner_join(co,by=c("id"="customer_id")) %>%
  inner_join(do,by=c("order_id" = "order_id")) %>%
  inner_join(dm,by=c("drink_id"="id")) %>%
  inner_join(po,by=c("order_id"="order_id"))%>%
  inner_join(pm,by=c("pizza_id" = "id")) %>%
  filter(name.y=="Coke") %>%
  select(name = name.x,drink=name.y,pizza=name)

customer_coke_pizza

#Remove Table
dbRemoveTable(con,"pizza_menu")
dbRemoveTable(con,"drinks")
dbRemoveTable(con,"customers")
dbRemoveTable(con,"customer_order")
dbRemoveTable(con,"pizza_order")
dbRemoveTable(con,"drink_order")
#Disconnect
dbDisconnect(con)
