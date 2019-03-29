# 5 Data transformation
## 5.1 Introduction
### in this chapter, which will teach you how to transform your data using 
### the dplyr package and a new dataset on flights departing New York City in 2013.

# 5.1.1 Prerequisites
library(nycflights13)
library(tidyverse)
## Take careful note of the conflicts message that’s printed when you load the tidyverse. 
## It tells you that dplyr overwrites some functions in base R

# 5.1.2 nycflights13
flights
?flights

## noticed the row of three (or four) letter abbreviations under the column names. 
## int stands for integers
## dbl stands for doubles, or real numbers
## chr stands for character vectors, or strings
## dttm stands for date-times(a date + a time)
## lgl stands for logical, vectors that contain only TRUE or FALSE
## fctr stands for factors, which R uses to represent categorical variables with fixed possible values
## date stands for dates

## 5.1.3 dplyr basics
## Pick observations by their values( filter() )
## Reorder the rows( arrange() )
## Pick variables by their names( select() )
## Create new variables with functions of existing variables( mutate() )
## Collapse many values down to a single summary( summaries() )

## These can all be used in conjunction with group_by() which changes the scope of 
## each function from operating on the entire dataset to operating on it group-by-group

## 1. The first argument is a data frame.
## 2. The subsequent arguments describe what to do with the data frame, 
##    using the variable names (without quotes).
## 3. The result is a new data frame.

# 5.2 Filter rows with filter()
## select all flights on January 1st
filter(flights, month == 1, day == 1)

jan1 <- filter(flights, month == 1, day == 1)

## prints out the results and saves them to a variable by wrap the assignment in paratheses
(dec25 <- filter(flights, month == 12, day == 25))

# 5.2.1 Comparisons
## R provides the standard suite: >, >=, <, <=, != (not equal), and == (equal).

filter(flights, month = 1)
### Error: `month` (`month = 1`) must not be named, do you need `==`?

sqrt(2) ^ 2 == 2 # FALSE
1 / 49 * 49 == 1 # FALSE

## Computers use finite precision arithmetic
near(sqrt(2) ^ 2, 2)
near(1 / 49 * 49, 1)

# 5.2.2 Logical operators
## Boolean operators: 
## & is “and”
## | is “or”
## ! is “not”. 

filter(flights, month == 11 | month == 12)
## short-hand
(nov_dec <- filter(flights, month %in% c(11, 12)))

## De Morgan’s law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y. 
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120 | dep_delay <= 120)

# 5.2.3 Missing values
## NA: not availables
## NA represents an unknown value so missing values are “contagious”: 
## almost any operation involving an unknown value will also be unknown.

NA > 5
## 10 == NA
NA + 10
NA / 2
## NA == NA 

# # Let x be Mary's age. We don't know how old she is.
# x <- NA
# 
# # Let y be John's age. We don't know how old he is.
# y <- NA
# 
# # Are John and Mary the same age?
# x == y
# #> [1] NA
# # We don't know!

## If you want to determine if a value is missing, use is.na():
is.na(x)

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)

filter(df, is.na(x) | x > 1)

# 5.2.4 Exercises
## 1. Find all flights that
## (1) Had an arrival delay of two or more hours
## (2) Flew to Houston (IAH or HOU)
## (3) Were operated by United, American, or Delta
## (4) Departed in summer (July, August, and September)
## (5) Arrived more than two hours late, but didn’t leave late
## (6) Were delayed by at least an hour, but made up over 30 minutes in flight
## (7) Departed between midnight and 6am (inclusive)

### (1) 
filter(flights, arr_delay >= 120)

### (2)
filter(flights, dest %in% c('IAH', 'HOU')) 
filter(flights, dest == 'IAH' | dest == 'HOU')

### (3)
filter(flights, carrier %in% c('UA', 'AA', 'DL'))
filter(flights, carrier == 'UA' | carrier == 'AA' | carrier == 'DL')

### (4)
filter(flights, month %in% 7:9)
filter(flights, month == 7 | month == 8 | month == 9)
filter(flights, month >= 7 & month <= 9)

### (5)
filter(flights, arr_delay >= 120 & dep_delay <= 0) 
filter(flights, arr_delay >= 120, dep_delay <= 0)
### (6)
filter(flights, arr_delay >= 60, dep_delay - arr_delay >= 30)

### (7)
filter(flights, dep_time %in% 0:600)
filter(flights, dep_time >= 0, dep_time <= 600)

## 2. Another useful dplyr filtering helper is between(). 
## What does it do? Can you use it to simplify the code needed to 
## answer the previous challenges?
?between
### It is a shortcut for finding observation between two values
filter(flights, month >= 7, month <= 9)
filter(flights, between(month, 7, 9))

## 3. How many flights have a missing dep_time? What other variables are missing? 
## What might these rows represent?
filter(flights, is.na(dep_time))
### They are also missing values for arrival time and departure/arrival delay. 
### Most likely these are scheduled flights that never flew.

## 4. Why is NA ^ 0 not missing? Why is NA | TRUE not missing? 
## Why is FALSE & NA not missing? Can you figure out the general rule?
## (NA * 0 is a tricky counterexample!)
### (1) NA ^ 0 - by definition anything to the 0th power is 1.
### (2) NA | TRUE - as long as one condition is TRUE, the result is TRUE. By definition, TRUE is TRUE.
### (3) FALSE & NA - NA indicates the absence of a value, so the conditional expression ignores it.
### (4) In general any operation on a missing value becomes a missing value. 
### Hence NA * 0 is NA. In conditional expressions, missing values are simply ignored.

# Arrange rows with arrange()
## arrange() works similarly to filter() except that instead of selecting rows, it changes their order. 
arrange(flights, year, month, day)

## Use desc() to re-order by a column in descending order:
arrange(flights, desc(dep_delay))

## Missing values are always sorted at the end:
df <- tibble(x = c(5, 2, 5, 6, 3, NA))
arrange(df, x);arrange(df, desc(x))

# 5.3.1 Exercises
## 1. How could you use arrange() to sort all missing values to the start? 
## (Hint: use is.na()).
arrange(flights, !is.na(dep_delay))

## 2. Sort flights to find the most delayed flights. 
## Find the flights that left earliest.
arrange(flights, desc(arr_delay))
arrange(flights, dep_delay)

## 3. Sort flights to find the fastest flights.
arrange(flights, desc(distance / air_time))

## 4. Which flights travelled the longest? Which travelled the shortest?
arrange(flights, desc(distance))

arrange(flights, distance)

# 5.4 Select columns with select()
## select() allows you to rapidly zoom in on a useful subset using operations 
## based on the names of the variables.

### select columns by name
select(flights, year, month, day)

### select columns between year and day (inclusive)
select(flights, year:day)

### select all columns except those from year to day(inclusive)
select(flights, -(year:day))

## There are a number of helper functions you can use within select():
### 1. starts_with('abc'): matches names that begin with 'abc'.
### 2. ends_with("xyz"): matches names that end with “xyz”.
### 3. contains("ijk"): matches names that contain “ijk”. Contains a literal string
### 4. matches("(.)\\1"): selects variables that match a regular expression. 
###    This one matches any variables that contain repeated characters. 
### 5. num_range("x", 1:3): matches x1, x2 and x3

## select() can be used to rename variables, but it’s rarely useful 
## because it drops all of the variables not explicitly mentioned. 
## Instead, use rename(), which is a variant of select() that keeps 
## all the variables that aren’t explicitly mentioned:
rename(flights, tail_num = tailnum)

## everything() is useful if you have a handful of variables you’d like to 
## move to the start of the data frame.
select(flights, time_hour, air_time, everything())

# 5.4.1 Exercises
## 1. Brainstorm as many ways as possible to select dep_time, dep_delay, 
##    arr_time, and arr_delay from flights.

select(flights, dep_time, dep_delay, arr_time, arr_delay)

time_delay <- c('dep_time', 'dep_delay', 'arr_time', 'arr_delay')
select(flights, time_delay)

select(flights, starts_with('dep'), starts_with('arr'))

## 2. What happens if you include the name of a variable multiple times 
##    in a select() call?

select(flights, dep_time, dep_time)
### It's included only a single time in the new data frame

## 3. What does the one_of() function do? Why might it be helpful 
##    in conjunction with this vector?
vars <- c("year", "month", "day", "dep_delay", "arr_delay")

select(flights, one_of(vars))
### one_of(): Matches variable names in a character vector.
### If you use this helper to select the variables that do not exist, 
### you'll get a warning message tell you no this variable, 
### but the other variables will still create a new data frame without error!

### contrast
test_var <- c('abc', 'month', 'day')
select(flights, test_var) # Error: Unknown column `abc` 
select(flights, one_of(test_var)) # Warning message: Unknown columns: `abc` 

## 4. Does the result of running the following code surprise you? 
## How do the select helpers deal with case by default? How can you 
## change that default?
select(flights, contains("TIME", ignore.case = FALSE))

# 5.5 Add new variables with mutate()
## mutate(): add new columns that are functions of existing columns

flights_sml <- select(flights, 
                      year:day, 
                      ends_with('delay'),
                      distance, 
                      air_time
)

mutate(flights_sml, 
       gain = dep_delay - arr_delay,
       speed = distance / air_time * 60
)

## you can refer to columns that you’ve just created:
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
)

## If you only want to keep the new variables, use transmute(): 
transmute(flights, 
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
)

# 5.5.1 Useful creation functions
## mutate(): The key property is that the function must be vectorised: 
## it must take a vector of values as input, 
## return a vector with the same number of values as output. 

## 1. Arithmetic operators: +, -, *, /, ^
## 2. Modular arithmetic: %/% (integer division) and %% (remainder), 
##    where x == y * (x %/% y) + (x %% y).
##    Modular arithmetic is a handy tool because it allows you to break integers up into pieces. 
transmute(flights, 
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
)
## 3. Logs: log(), log2(), log10(). Logarithms are an incredibly useful transformation for 
##    dealing with data that ranges across multiple orders of magnitude.
## 4. Offsets: lead() and lag() allow you to refer to leading or lagging values. 
##    This allows you to compute running differences (e.g. x - lag(x)) or 
##    find when values change (x != lag(x)). They are most useful in conjunction with group_by(), 
##    which you’ll learn about shortly.
(x <- 1:10)

lag(x)
lead(x)

x - lag(x)
x != lag(x)
## 5. Cumulative and rolling aggregates: 
##    R provides functions for running sums, products, mins and maxes: 
##    cumsum(), cumprod(), cummin(), cummax(); and dplyr provides cummean() for 
##    cumulative means. If you need rolling aggregates 
##    (i.e. a sum computed over a rolling window), try the RcppRoll package.
x
cumsum(x)
cummean(x)

## 6. Logical comparisons, <, <=, >, >=, !=, and ==.
## 7. Ranking: there are a number of ranking functions, 
##    but you should start with min_rank().
##    The default gives smallest values the small ranks; 
##    use desc(x) to give the largest values the smallest ranks.
y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))

row_number(y)
dense_rank(y)
percent_rank(y)
cume_dist(y)
### https://stats.stackexchange.com/questions/34008/how-does-ties-method-argument-of-rs-rank-function-work

# 5.5.2 Exercises

## 1. Currently dep_time and sched_dep_time are convenient to look at, 
##    but hard to compute with because they’re not really continuous numbers. 
##    Convert them to a more convenient representation of number of minutes since midnight.
### (1)
transmute(flights, 
          dep_time = (dep_time %/% 100 * 60) + dep_time %% 100,
          sched_dep_time = (sched_dep_time %/% 100 * 60) + sched_dep_time %% 100
)
### (2)
trans_time <- function(x) {
  return((x %/% 100 * 60) + x %% 100)
}
transmute(flights, 
          dep_time = trans_time(dep_time),
          sched_dep_time = trans_time(sched_dep_time)
)

## 2. Compare air_time with arr_time - dep_time. What do you expect to see? 
## What do you see? What do you need to do to fix it?
(flight2 <- select(flights, air_time, arr_time, dep_time))
mutate(flight2, air_time_new = arr_time - dep_time)

## 3. Compare dep_time, sched_dep_time, and dep_delay. 
## How would you expect those three numbers to be related?
select(flights, dep_time, sched_dep_time, dep_delay)  
### dep_delay = dep_time - sched_dep_time

## 4. Find the 10 most delayed flights using a ranking function. 
## How do you want to handle ties? Carefully read the documentation for min_rank().
mutate(flights, most_delay = min_rank(desc(arr_delay))) %>% 
  arrange(most_delay)

## 5. What does 1:3 + 1:10 return? Why?
1:3 + 1:10
### 2  4  6  5  7  9  8 10 12 11
### element_wise
### If one parameter is shorter than the other, 
### it will be automatically extended to be the same length.


## 6. What trigonometric functions does R provide?
??trigonometric
cos(x)
sin(x)
tan(x)

acos(x)
asin(x)
atan(x)
atan2(y, x)

cospi(x)
sinpi(x)
tanpi(x)

# 5.6 Grouped summaries with summaries()
## summarise(): It collapses a data frame to a single row:
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
mean(flights$dep_delay, na.rm = TRUE)

## summarise() is not terribly useful unless we pair it with group_by()
## This changes the unit of analysis from the complete dataset to individual groups. 
## Then, when you use the dplyr verbs on a grouped data frame they’ll be automatically applied “by group”. 
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

## Together group_by() and summarise() provide one of the tools that 
## you’ll use most commonly when working with dplyr: grouped summaries.

## 5.6.1 Combining multiple operations with the pip

### explore the relationship between the distance and average delay for each location
by_dest <- group_by(flights, dest)
delay <- summarise(by_dest, 
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
)
delay <- filter(delay, count > 20, dest != 'HNL')

ggplot(data = delay, mapping = aes(x = dist, y = delay)) + 
  geom_point(aes(size = count), alpha = 1/3) + 
  geom_smooth(se = FALSE)

### There are three steps to prepare this data:
#### 1. Group flights by destinations.
#### 2. Summarise to compute distance, average delay, and number of flights.
#### 3. Filter to remove noisy points and Honolulu airport, which is almost 
####    twice as far away as the next closest airport.

## This code is a little frustrating to write because we have to give 
## each intermediate data frame a name, even though we don’t care about it. 
## Naming things is hard, so this slows down our analysis.
## There’s another way to tackle the same problem with the pipe, %>%:

delay <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != 'HNL')

# 5.6.2 Missing values
## If we don't set na.rm = TRUE, then we'll get a lot of missing values.
## Because of aggregation functions obey the ususal rule of missing values.

### contrast
flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay, na.rm = TRUE))

## In this case, where missing values represent cancelled flights
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

### not_cancalled2 <- flights %>% filter(!(is.na(dep_delay) | is.na(arr_delay)))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

# 5.6.3 Counts
## Whenever you do any aggregation, it’s always a good idea to include either 
## a count (n()), or a count of non-missing values (sum(!is.na(x)))
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )
ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE), 
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

## Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

batters %>% 
  arrange(desc(ba))

# 5.6.4 Useful summary functions
## 1. Measures of location: we’ve used mean(x), but median(x) is also useful.

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
  )

## 2. Measures of spread: sd(x), IQR(x), mad(x)
### # Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

## 3. Measures of rank: min(x), quantile(x, 0.25), max(x)
### # When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year ,month, day) %>% 
  summarise(
    first = min(dep_time), 
    last = max(dep_time)
  )

## 4. Measures of position: first(x), nth(x, 2), last(x)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )

### complementary to filtering on ranks
not_cancelled %>% 
  group_by(year, month, day) %>% 
  mutate(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))

## 5. Counts: You’ve seen n(), which takes no arguments, and returns the size of the current group. 
##    To count the number of non-missing values, use sum(!is.na(x)).
##    To count the number of distinct (unique) values, use n_distinct(x).
### Which destinations have the most carriers?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

### Counts are so useful that dplyr provides a simple helper if all you want is a count:
not_cancelled %>% 
  count(dest)

not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n = n())

### You can optionally provide a weight variable. For example, 
### you could use this to “count” (sum) the total number of miles a plane flew:
not_cancelled %>% 
  count(tailnum, wt = distance)

## 6. Counts and proportions of logical values: sum(x > 10), mean(y == 0)
### When used with numeric functions, TRUE is converted to 1 and FALSE to 0. 
### This makes sum() and mean() very useful: sum(x) gives the number of TRUEs in x, 
### and mean(x) gives the proportion.

### How many flights left before 5am? (these usually indicate delayed
### flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

### What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60)) %>% 
  arrange(desc(hour_perc))

# 5.6.5 Grouping by multiple variables
## When you group by multiple variables, each summary peels off one level of the grouping. 
## That makes it easy to progressively roll up a dataset:
daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))

(per_month <- summarise(per_day ,flights = sum(flights)))

(per_year <- summarise(per_month, flights = sum(flights)))

# 5.6.6 Ungrouping
## If you need to remove grouping, and return to operations on ungrouped data, use ungroup()
daily %>% 
  ungroup() %>% # no longer grouped by date
  summarise(flights = n()) # all flights

# 5.6.7 Exercises
## 1. Brainstorm at least 5 different ways to assess the typical delay characteristics of 
##    a group of flights. Consider the following scenarios:
### (1) A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
### (2) A flight is always 10 minutes late.
### (3) A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.
### (4) 99% of the time a flight is on time. 1% of the time it’s 2 hours late.
## (5) Which is more important: arrival delay or departure delay?

### (1)
flights %>% 
  group_by(flight) %>% 
  summarise(
    early_15_min = sum(arr_delay <= -15, na.rm = TRUE) / n(),
    late_15_min = sum(dep_delay >= 15, na.rm = TRUE) / n()
  ) %>% 
  filter(early_15_min == 0.5, late_15_min == 0.5)
### (2)
flights %>% 
  group_by(flight) %>% 
  summarise(
    late_10_min = sum(arr_delay == 10, na.rm = TRUE) / n()
  ) %>% 
  filter(late_10_min == 1)
### (3)
flights %>% 
  group_by(flight) %>% 
  summarise(
    early_30_min = sum(arr_delay <= -30, na.rm = TRUE) / n(),
    late_30_min = sum(dep_delay >= 30, na.rm = TRUE) / n()
  ) %>% 
  filter(early_30_min == 0.5, late_30_min == 0.5)
### (4)
flights %>% 
  group_by(flight) %>% 
  summarise(
    on_time = sum(arr_delay == 0, na.rm = TRUE) / n(),
    late_two_hour = sum(arr_delay >= 120, na.rm = TRUE) / n()
  ) %>% 
  filter(on_time == .99, late_two_hour == .01)
### (5)
### It's depends on the customer.
flights %>% 
  group_by(year) %>% 
  summarise(
    mean_arr_delay = mean(arr_delay, na.rm = TRUE),
    mean_dep_delay = mean(dep_delay, na.rm = TRUE)
  )
### But the average of arrival delay and departure delay is 6.9 and 12.6,
### maybe we can find solution to reduce the rate of departure delay.

## 2. Come up with another approach that will give you the same output as not_cancelled %>% 
##    count(dest) and not_cancelled %>% count(tailnum, wt = distance) (without using count()).

not_cancelled <- flights %>% 
  filter(!is.na(arr_delay) & !is.na(dep_delay))

### (1)
### original
not_cancelled %>% 
  count(dest)
### new
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n = n() )

### (2)
### original
not_cancelled %>% 
  count(tailnum, wt = distance)
### new
not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(n = sum(distance, na.rm = TRUE))

## 3. Our definition of cancelled flights (is.na(dep_delay) | is.na(arr_delay) ) is slightly 
##    suboptimal. Why? Which is the most important column?
### There are no flights which arrived but did not depart, so we can just use !is.na(dep_delay).
flights %>% 
  filter(!is.na(dep_delay) & !is.na(arr_delay)) %>% 
  summarise(n = n())

flights %>% 
  filter(!is.na(arr_delay)) %>% 
  summarise(n = n())

## 4. Look at the number of cancelled flights per day. Is there a pattern? 
##    Is the proportion of cancelled flights related to the average delay?
flights %>% 
  group_by(year, month, day) %>% 
  summarise(cancelled = sum(is.na(arr_delay)))
flights %>% 
  group_by(year, month, day) %>% 
  filter(is.na(arr_delay)) %>% 
  count()

flights %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE), 
    prop_cancell = sum(is.na(arr_delay)) / n()
  )

## 5. Which carrier has the worst delays? Challenge: can you disentangle the effects of 
##    bad airports vs. bad carriers? Why/why not? (Hint: think about flights %>% 
##    group_by(carrier, dest) %>% summarise(n()))
### the worst delay
flights %>% 
  group_by(carrier) %>% 
  summarise(mean_delay = sum(arr_delay, na.rm = TRUE) / n()) %>% 
  arrange(desc(mean_delay))

flights %>% 
  group_by(carrier) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  arrange(desc(mean_delay))

### Challenge
flights %>% 
  group_by(carrier, dest) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  group_by(carrier) %>% 
  summarise(mean_delay_mad = mad(mean_delay, na.rm = TRUE)) %>% 
  arrange(desc(mean_delay_mad))
### https://cfss.uchicago.edu/r4ds_solutions.html#5_data_transformation

## 6. What does the sort argument to count() do. When might you use it?
### if TRUE will sort output in descending order of n
### set this argument, then without use arrange() function

# 5.7 Grouped mutates(and filters)
## Grouping is most useful in conjunction with summarise(), 
## but you can also do convenient operations with mutate() and filter()

## find the worst members of each group
flights_sml %>% 
  group_by(year, month, day) %>% 
  filter(rank(desc(arr_delay)) < 10)

## find all groups bigger than a threshold
popular_dests <- flights %>% 
  group_by(dest) %>% 
  filter(n() > 365)

## Standardise to compute per group metrics
popular_dests %>% 
  filter(arr_delay > 0) %>% 
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>% 
  select(year:day, dest, arr_delay, prop_delay)

# 5.7.1 Exercises
## 1. Refer back to the lists of useful mutate and filtering functions. 
##    Describe how each operation changes when you combine it with grouping.
flights_sml %>% 
  group_by(year, month, day) %>% # group our data by year, month, day.
  filter(rank(desc(arr_delay)) < 10) # sum each day's most arrival delay, rank, and filter top 9

### group_by() which changes the scope of each function from operating on the 
### entire dataset to operating on it group-by-group

## 2. Which plane (tailnum) has the worst on-time record?
flights %>% 
  filter(dep_delay > 0) %>% 
  group_by(tailnum) %>% 
  summarise(avg_delay = mean(dep_delay)) %>% 
  arrange(desc(avg_delay))

## 3. What time of day should you fly if you want to avoid delays as much as possible?
flights %>% 
  group_by(hour) %>% 
  summarise(
    arr_delay = sum(arr_delay > 5, na.rm = TRUE) / n()
  ) %>% 
  ggplot(mapping = aes(x = hour, y = arr_delay, fill = arr_delay)) + 
  geom_col()

## 4. For each destination, compute the total minutes of delay. For each flight, 
##    compute the proportion of the total delay for its destination.
flights %>% 
  filter(!is.na(arr_delay), arr_delay > 0) %>% 
  group_by(dest) %>% 
  transmute(
    arr_delay_total = sum(arr_delay),
    arr_delay_prop = arr_delay / arr_delay_total
  )

## 5. Delays are typically temporally correlated: even once the problem that caused 
##    the initial delay has been resolved, later flights are delayed to allow earlier 
##    flights to leave. Using lag(), explore how the delay of a flight is related to the
##    delay of the immediately preceding flight.
flights %>% 
  group_by(origin) %>% 
  arrange(year, month, day, hour, minute) %>% 
  mutate(dep_delay_lag = lag(dep_delay)) %>% 
  ggplot(mapping = aes(x = dep_delay_lag, y = dep_delay)) +
  geom_point() +
  geom_smooth(se = FALSE)

## 6. Look at each destination. Can you find flights that are suspiciously fast? 
##    (i.e. flights that represent a potential data entry error). 
##    Compute the air time a flight relative to the shortest flight to that destination. 
##    Which flights were most delayed in the air?
### Reference: https://lokhc.wordpress.com/r-for-data-science-solutions/chapter-5-data-transformation/
flights %>% 
  filter(!is.na(air_time)) %>% 
  group_by(dest) %>% 
  mutate(
    mean_of_air_time = mean(air_time, na.rm = TRUE),
    sd_of_air_time = sd(air_time, na.rm = TRUE),
    z_scope = (air_time - mean_of_air_time) / sd_of_air_time
  ) %>% 
  select(
    z_scope ,
    mean_of_air_time, 
    sd_of_air_time, 
    air_time, 
    everything()
  ) %>% 
  arrange(z_scope)

## 7. Find all destinations that are flown by at least two carriers. 
##    Use that information to rank the carriers.
flights %>% 
  group_by(dest) %>% 
  summarise(
    num_carrier = n_distinct(carrier)
  ) %>% 
  filter(num_carrier >= 2) %>% 
  mutate(rank = dense_rank(desc(num_carrier))) %>% 
  arrange(desc(num_carrier))

## 8. For each plane, count the number of flights before the first delay of greater than 1 hour.
flights %>% 
  filter(!is.na(dep_delay)) %>% 
  group_by(tailnum) %>% 
  mutate(
    max_delay = cummax(dep_delay),
    less_one_hour = max_delay < 60
  ) %>% 
  summarize(count = sum(less_one_hour)) %>% 
  arrange(desc(count))