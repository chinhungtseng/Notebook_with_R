if(!require(pacman)) install.packages('pacman')
library(pacman)
pacman::p_load(sparklyr, dplyr, DBI) 
spark_install(version = "2.1.0")

# Load library
library(sparklyr)
library(dplyr)
library(DBI)
library(ggplot2)

options(scipen=999)

# Recommended properties form RStudio with sparklry official web
conf <- spark_config()
conf$`sparklyr.cores.local` <- 4
conf$`sparklyr.shell.driver-memory` <- "12G" #16G
conf$spark.memory.fraction <- 0.9

# Connecting to Spark
sc <- spark_connect(master = "local", 
                    version = "2.1.0",
                    config = conf)

# Load data into spark
system.time({
train_tbl <- spark_read_csv(sc, name = 'train', 
                            path = 'C:/Users/Student/R/train_sample.csv', 
                            header = TRUE, 
                            delimiter = ",")})

system.time({
  test_tbl <- spark_read_csv(sc, name = 'test', 
                              path = 'C:/Users/Student/R/test.csv', 
                              header = TRUE, 
                              delimiter = ",")})

src_tbls(sc)

head(train_tbl, 5)
head(test_tbl, 5)

# system.time(dim(collect(test_tbl)))
# system.time({dbGetQuery(sc, "SELECT count(*) FROM test")})
dbGetQuery(sc, "SELECT count(*) FROM train")
dbGetQuery(sc, "SELECT count(*) FROM test")


ip_count <- train_tbl %>% group_by(ip) %>% summarise(count_ip = n()) %>% arrange(desc(count_ip))

ggplot(ip_count, aes(x = ip, y = count_ip)) + geom_bar(stat="identity")












## Spark web console 
spark_web(sc)

# Disconnect from Spark
spark_disconnect(sc)
