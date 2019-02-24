# Load libraries
if(!require(data.table)) install.packages('data.table')
if(!require(tidyverse)) install.packages('tidyverse')
if(!require(lubridate)) install.packages('lubridate')

library(data.table)
library(tidyverse)
library(lubridate)

# Disable e notation
options(scipen = 999)

# Set file's path: you can set your path here.
path <- '/Users/peter/Documents/Project/Kaggle/Talkingdata/data/'

# Load dataset and count the loading time
## train.csv
system.time({
  train <- fread(input = paste(path, 'train_sample.csv', sep = ''),
               header = TRUE,
               sep = ',')
})

## test.csv
system.time({
  test <- fread(input = paste(path, 'test.csv', sep = ''),
              header = TRUE,
              sep = ',')
})

# Quick look up dataset
str(train);str(test)

# Split click_time and attributed_time to day, hour, minute, second 
system.time({
  train_new <- train %>% 
    mutate(
      # convert to date-time property
      click_time = as.POSIXct(strptime(click_time, "%Y-%m-%d %H:%M:%S")),
      attributed_time = as.POSIXct(strptime(attributed_time, "%Y-%m-%d %H:%M:%S")),
      # split date-time 
      click_day = day(click_time),
      click_hour = hour(click_time),
      click_minute = minute(click_time),
      click_second = second(click_time),
      attr_day = day(attributed_time),
      attr_hour = hour(attributed_time),
      attr_minute = minute(attributed_time),
      attr_second = second(attributed_time),
      # convert features below to factor property.
      ip = as.factor(ip), 
      app = as.factor(app),
      device = as.factor(device),
      os = as.factor(os),
      channel = as.factor(channel),
      is_attributed = as.factor(is_attributed)
    ) %>% 
    select(-c(click_time, attributed_time))
})

system.time({
  train_new <- train %>% 
     mutate(
       click_time = as.POSIXct(strptime(click_time, "%Y-%m-%d %H:%M:%S")),
       ip = as.factor(ip), 
       is_attributed = is_attributed == 1,
       # convert features below to factor property.
       ip = as.factor(ip), 
       app = as.factor(app),
       device = as.factor(device),
       os = as.factor(os),
       channel = as.factor(channel)
     ) %>% 
     select(c(ip, click_time, is_attributed, everything()))
})


# Exploratory Data Analysis

## train.csv: count_ip vs is_attributed
train_new %>% count(is_attributed)
ggplot(data = train_new) + 
  geom_bar(mapping = aes(x = is_attributed, fill = is_attributed))

train_new %>% 
  group_by(is_attributed) %>% 
  summarise(count = length(is_attributed == 1))

# train.csv: date vs is_attributed
train_new %>% 
  ggplot(mapping = aes(x = click_time)) +
  geom_freqpoly(mapping = aes(color = is_attributed), bins = 500)

# train.csv: 
## ip_count
train_new %>% 
  group_by(ip) %>% 
  summarise(count = n()) %>% 
  mutate(rank = dense_rank(desc(count))) %>% 
  filter(rank <= 50) %>% 
  ggplot() +
  geom_bar(mapping = aes(x = reorder(ip, count) , y = count, fill = ip), stat = 'identity') +
  coord_flip()

## app_count
train_new %>% 
  group_by(app) %>% 
  summarise(count = n()) %>% 
  mutate(rank = dense_rank(desc(count))) %>% 
  filter(rank <= 10) %>% 
  ggplot() +
  geom_bar(mapping = aes(x = reorder(app, desc(count)) , y = count, fill = app), stat = 'identity')

## device_count
train_new %>% 
  group_by(device) %>% 
  summarise(count = n()) %>% 
  mutate(rank = dense_rank(desc(count))) %>% 
  filter(rank <= 10) %>% 
  ggplot() +
  geom_bar(mapping = aes(x = reorder(device, desc(count)) , y = count, fill = device), stat = 'identity')

## os_count
train_new %>% 
  group_by(os) %>% 
  summarise(count = n()) %>% 
  mutate(rank = dense_rank(desc(count))) %>% 
  filter(rank <= 10) %>% 
  ggplot() +
  geom_bar(mapping = aes(x = reorder(os, desc(count)) , y = count, fill = os), stat = 'identity')

















ggplot(data = train_new ,mapping = aes(x = ip,  y = stat(count))) + 
  geom_bar()

ggplot(data = train_new) +
  geom_histogram(mapping = aes(x = ip), binwidth = 50)





