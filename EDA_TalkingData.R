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
    click_time = as.POSIXct(strptime(click_time, "%Y-%m-%d %H:%M:%S")),
    attributed_time = as.POSIXct(strptime(attributed_time, "%Y-%m-%d %H:%M:%S")),
    click_day = day(click_time),
    click_hour = hour(click_time),
    click_minute = minute(click_time),
    click_second = second(click_time),
    attr_day = day(attributed_time),
    attr_hour = hour(attributed_time),
    attr_minute = minute(attributed_time),
    attr_second = second(attributed_time),
    ip = as.factor(ip), 
    app = as.factor(app),
    device = as.factor(device),
    os = as.factor(os),
    channel = as.factor(channel),
    is_attributed = as.factor(is_attributed)
  ) %>% 
  select(-c(click_time, attributed_time))
})

# Exploratory Data Analysis

## train: count_ip vs is_attributed
train_new %>% count(is_attributed)
ggplot(data = train_new) + 
  geom_bar(mapping = aes(x = is_attributed, fill = is_attributed))







ggplot(data = train_new ,mapping = aes(x = ip,  y = stat(count))) + 
  geom_bar()

ggplot(data = train_new) +
  geom_histogram(mapping = aes(x = ip), binwidth = 50)





