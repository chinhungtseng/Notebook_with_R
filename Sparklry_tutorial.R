# https://spark.rstudio.com
# Installation
if(!require(sparklyr)) install.packages('sparklyr')
library(sparklyr)
spark_install(version = "2.1.0")

conf <- spark_config()
conf$`sparklyr.cores.local` <- 4
conf$`sparklyr.shell.driver-memory` <- "16G"
conf$spark.memory.fraction <- 0.9

sc <- spark_connect(master = "local", 
                    version = "2.1.0",
                    config = conf)

# Connecting to Spark
## You can connect to both local instances of Spark as well as remote Spark clusters.
# conf <- spark_config()   # Load variable with spark_config()
# conf$spark.executor.memory <- "16G" # Use `$` to add or set values
# sc <- spark_connect(master = "yarn-client", 
#                     config = conf)  # Pass the conf variable

# conf <- spark_config()
# conf$spark.executor.memory <- "300M"
# conf$spark.executor.cores <- 2
# conf$spark.executor.instances <- 3
# conf$spark.dynamicAllocation.enabled <- "false"
# 
# sc <- spark_connect(master = "yarn-client", 
#                     spark_home = "/usr/lib/spark/",
#                     version = "2.1.0",
#                     config = conf)


# Using dplyr
if(!require(nycflights13)) install.packages('nycflights13')
if(!require(Lahman)) install.packages('Lahman')

## Copying some datasets from R into the Spark cluster
library(dplyr)
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")

src_tbls(sc)

### filter by departure delay and print the first few records
flights_tbl %>% filter(dep_delay == 2)

delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect

#### plot delays
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area(max_size = 2)

# WINDOW FUNCTIONS
batting_tbl %>%
  select(playerID, yearID, teamID, G, AB:H) %>%
  arrange(playerID, yearID, teamID) %>%
  group_by(playerID) %>%
  filter(min_rank(desc(H)) <= 2 & H > 0)

# Using SQL
library(DBI)
iris_preview <- dbGetQuery(sc, "SELECT * FROM iris LIMIT 10")
iris_preview

# Machine Learning
## copy mtcars into spark
mtcars_tbl <- copy_to(sc, mtcars)

## transform our data set, and then partition into 'training', 'test'
partitions <- mtcars_tbl %>%
  filter(hp >= 100) %>%
  mutate(cyl8 = cyl == 8) %>%
  sdf_partition(training = 0.5, test = 0.5, seed = 1099)

## fit a linear model to the training dataset
system.time({
fit <- partitions$training %>%
  ml_linear_regression(response = "mpg", features = c("wt", "cyl"))
})
fit$summary

summary(fit)

# Reading and Writing Data
temp_csv <- tempfile(fileext = ".csv")
temp_parquet <- tempfile(fileext = ".parquet")
temp_json <- tempfile(fileext = ".json")

spark_write_csv(iris_tbl, temp_csv)
iris_csv_tbl <- spark_read_csv(sc, "iris_csv", temp_csv)

spark_write_parquet(iris_tbl, temp_parquet)
iris_parquet_tbl <- spark_read_parquet(sc, "iris_parquet", temp_parquet)

spark_write_json(iris_tbl, temp_json)
iris_json_tbl <- spark_read_json(sc, "iris_json", temp_json)

src_tbls(sc)

# Distributed R
## You can execute arbitrary r code across your cluster using spark_apply. 
## For example, we can apply rgamma over iris as follows:
spark_apply(iris_tbl, function(data) {
  data[1:4] + rgamma(1,2)
})

## You can also group by columns to perform an operation over each group of rows 
## and make use of any package within the closure:
system.time({
  spark_apply(iris_tbl, function(e) broom::tidy(lm(Petal_Width ~ Petal_Length, e)),
  names = c("term", "estimate", "std.error", "statistic", "p.value"),
  group_by = "Species"
)})

# Extensions
## write a CSV 
tempfile <- tempfile(fileext = ".csv")
write.csv(nycflights13::flights, tempfile, row.names = FALSE, na = "")

## define an R interface to Spark line counting
count_lines <- function(sc, path) {
  spark_context(sc) %>% 
    invoke("textFile", path, 1L) %>% 
    invoke("count")
}

## call spark to count the lines of the CSV
count_lines(sc, tempfile)

# Table Utilities

## You can cache a table into memory with:
tbl_cache(sc, "batting")

## and unload from memory using:
tbl_uncache(sc, "batting")


# Connection Utilities
## You can view the Spark web console using the spark_web function:
spark_web(sc)

## You can show the log using the spark_log function:
spark_log(sc, n = 10)

# Disconnect from Spark
spark_disconnect(sc)

