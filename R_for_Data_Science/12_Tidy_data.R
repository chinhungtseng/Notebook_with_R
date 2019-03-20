# 12 Tidy data

# 12.1 Introduction
# In this chapter, you will learn a consistent way to organise your data in R, an organisation called tidy data
# This chapter will give you a practical introduction to tidy data and the accompanying tools in the tidyr package. 
# If you’d like to learn more about the underlying theory, you might enjoy the Tidy Data paper 
# published in the Journal of Statistical Software, http://www.jstatsoft.org/v59/i10/paper.

# 12.1.1 Prerequisites
library(tidyverse)

# 12.2 Tidy data
table1
table2
table3
table4a
table4b

# These are all representations of the same underlying data, but they are not equally easy to use. One dataset,
# the tidy dataset, will be much easier to work with inside the tidyverse.

# There are three interrelated rules which make a dataset tidy:
# 1. Each variable must have its own column.
# 2. Each observation must have its own row.
# 3. Each value must have its own cell.

# These three rules are interrelated because it’s impossible to only satisfy two of the three. 
# That interrelationship leads to an even simpler set of practical instructions:
# 1. Put each dataset in a tibble.
# 2. Put each variable in a column.

# In this example, only table1 is tidy. It’s the only representation where each column is a variable.
# Why ensure that your data is tidy? There are two main advantages:

# 1. There’s a general advantage to picking one consistent way of storing data. 
#    If you have a consistent data structure, it’s easier to learn the tools that 
#    work with it because they have an underlying uniformity.
# 2. There’s a specific advantage to placing variables in columns because it allows R’s vectorised nature to shine. 
#    As you learned in mutate and summary functions, most built-in R functions work with vectors of values. 
#    That makes transforming tidy data feel particularly natural.

# dplyr, ggplot2, and all the other packages in the tidyverse are designed to work with tidy data.
# Here are a couple of small examples showing how you might work with table1.

## Compute rate per 10,000
table1 %>% 
  mutate(rate = cases / population)

## Compute rate per year
table1 %>% 
  count(year, wt = cases)

## Visualise changes over time
library(ggplot2)
ggplot(table1, aes(year, cases)) + 
  geom_line(aes(group = country), color = 'grey50') +
  geom_point(aes(color = country))

# 12.2.1 Exercises
# 1. Using prose, describe how the variables and observations are organised in each of the sample tables.

table1
## In table1, each observation has its own row and each variable has its own column.

table2
table3
table4a
table4b

# 2. Compute the rate for table2, and table4a + table4b. You will need to perform four operations:
# (1) Extract the number of TB cases per country per year.
# (2) Extract the matching population per country per year.
# (3) Divide cases by population, and multiply by 10000.
# (4) Store back in the appropriate place.
# Which representation is easiest to work with? Which is hardest? Why?
table2 

(table2_rate <- tibble(
  country = filter(table2, type == 'cases')$country,
  year = filter(table2, type == 'cases')$year,
  cases = filter(table2, type == 'cases')$count,
  population = filter(table2, type == 'population')$count,
  rate = cases / population * 10000
))

table4a
table4b

country <- table4a$country
cases_1990 <- table4a$`1999`
cases_2000 <- table4a$`2000`
population_1990 <- table4b$`1999`
population_2000 <- table4b$`2000`

rate_1990 <- tibble(
  country = country,
  year = 1990,
  rate = cases_1990 / population_1990 * 10000
)
rate_2000 <- tibble(
  country = country,
  year = 2000,
  rate = cases_2000 / population_2000 * 10000
)
(table4_rate <- rbind(rate_1990, rate_2000) %>% arrange(country))

# 3. Recreate the plot showing change in cases over time using table2 instead of table1. 
#    What do you need to do first?
ggplot(filter(table2, type == 'cases'), aes(year, count)) + 
  geom_line(aes(group = country), color = 'grey50') +
  geom_point(aes(color = country))

# 4. 12.3 Spreading and gathering

# most data that you will encounter will be untidy. There are two main reasons:
# 1. Most people aren’t familiar with the principles of tidy data, and it’s hard to 
#    derive them yourself unless you spend a lot of time working with data.
# 2. Data is often organised to facilitate some use other than analysis. For example, 
#    data is often organised to make entry as easy as possible.

# This means for most real analyses, you’ll need to do some tidying. 
# The first step is always to figure out what the variables and observations are. 
# Sometimes this is easy; other times you’ll need to consult with the people who originally generated the data. 
# The second step is to resolve one of two common problems:
# 1. One variable might be spread across multiple columns.
# 2. One observation might be scattered across multiple rows.

# Typically a dataset will only suffer from one of these problems; it’ll only suffer from both if you’re really unlucky! 
# To fix these problems, you’ll need the two most important functions in tidyr: gather() and spread().

# 12.3.1 Gathering

# A common problem is a dataset where some of the column names are not names of variables, 
# but values of a variable. Take table4a: the column names 1999 and 2000 represent values of the year variable, 
# and each row represents two observations, not one.
table4a

# To tidy a dataset like this, we need to gather those columns into a new pair of variables. 
# To describe that operation we need three parameters:
# 1. The set of columns that represent values, not variables. In this example, 
#    those are the columns 1999 and 2000.
# 2. The name of the variable whose values form the column names. 
#    I call that the key, and here it is year.
# 3. The name of the variable whose values are spread over the cells. I call that value, 
#    and here it’s the number of cases.
# Together those parameters generate the call to gather():
table4a %>% 
  gather(`1999`, `2000`, key = 'year', value = 'cases')

table4b %>% 
  gather(`1999`, `2000`, key = 'year', value = 'cases')

# To combine the tidied versions of table4a and table4b into a single tibble, 
# we need to use dplyr::left_join(), which you’ll learn about in relational data.
tidy4a <- table4a %>% 
  gather(`1999`, `2000`, key = 'year', value = 'cases')

tidy4b <- table4b %>% 
  gather(`1999`, `2000`, key = 'year', value = 'population')

left_join(tidy4a, tidy4b)

# 12.3.2 Spreading
# Spreading is the opposite of gathering. You use it when an observation is scattered across multiple rows.
# For example, take table2: an observation is a country in a year, but each observation is spread across two rows.
table2

# To tidy this up, we first analyse the representation in similar way to gather().
# This time, however, we only need two parameters:
# 1. The column that contains variable names, the key column. Here, it’s type.
# 2. The column that contains values from multiple variables, the value column. Here it’s count.

# Once we’ve figured that out, we can use spread(), as shown programmatically below, 
# and visually in Figure 12.3.
table2 %>% 
  spread(key = type, value = count)

# As you might have guessed from the common key and value arguments, spread() and gather() are complements. 
# gather() makes wide tables narrower and longer; spread() makes long tables shorter and wider.

# 12.3.3 Exercises
# 1. Why are gather() and spread() not perfectly symmetrical?
#    Carefully consider the following example:
stocks <- tibble(
  year   = c(2015, 2015, 2016, 2016),
  half  = c(   1,    2,     1,    2),
  return = c(1.88, 0.59, 0.92, 0.17)
)
stocks %>% 
  spread(year, return) %>% 
  gather("year", "return", `2015`:`2016`)
# (Hint: look at the variable types and think about column names.)
# Both spread() and gather() have a convert argument. What does it do?

## original
stocks
# year  half return
# <dbl> <dbl>  <dbl>
# 1  2015     1   1.88
# 2  2015     2   0.59
# 3  2016     1   0.92
# 4  2016     2   0.17

## convert step 1:
stocks %>% spread(year, return)
# half `2015` `2016`
# <dbl>  <dbl>  <dbl>
# 1     1   1.88   0.92
# 2     2   0.59   0.17

## convert step 2:
stocks %>% spread(year, return) %>% gather('year', 'return', `2015`:`2016`)
# stocks %>% spread(year, return) %>% gather(`2015`,`2016`, key = 'year', value = 'return')
# half year  return
# <dbl> <chr>  <dbl>
# 1     1 2015    1.88
# 2     2 2015    0.59
# 3     1 2016    0.92
# 4     2 2016    0.17

# 2. Why does this code fail?
table4a %>% 
  gather(1999, 2000, key = "year", value = "cases")
#> Error in inds_combine(.vars, ind_list): Position must be between 0 and n
## because the variable name: 1999 and 2000 are invalid syntax
## we need to add backticks aroud 1999 and 2000:
table4a %>% 
  gather(`1999`, `2000`, key = 'year', value = 'cases', convert = TRUE)

# 3. Why does spreading this tibble fail? 
#    How could you add a new column to fix the problem?
(people <- tribble(
  ~name,             ~key,    ~value,
  #-----------------|--------|------
  "Phillip Woods",   "age",       45,
  "Phillip Woods",   "height",   186,
  "Phillip Woods",   "age",       50,
  "Jessica Cordero", "age",       37,
  "Jessica Cordero", "height",   156
))

people %>% 
  spread(key, value)
# Error: Duplicate identifiers for rows (1, 3)

people$id <- c(1, 1, 2, 3, 3)
people %>% 
  spread(key, value) %>% 
  arrange(id)

# 4. Tidy the simple tibble below. 
#    Do you need to spread or gather it? 
#    What are the variables?
preg <- tribble(
  ~pregnant, ~male, ~female,
  "yes",     NA,    10,
  "no",      20,    12
)

preg %>% 
  gather('gender', 'value', 'male':'female', na.rm = TRUE)

preg %>% 
  gather(2:3, key = 'gender', value = 'value', na.rm = TRUE)

# 12.4 Separating and uniting

# So far you’ve learned how to tidy table2 and table4, but not table3. 
# table3 has a different problem: we have one column (rate) that contains two variables (cases and population). 
# To fix this problem, we’ll need the separate() function. You’ll also learn about the complement of separate(): 
# unite(), which you use if a single variable is spread across multiple columns.

# 12.4.1 Separate
## separate() pulls apart one column into multiple columns, 
## by splitting wherever a separator character appears. Take table3:
table3

table3 %>% 
  separate(rate, into = c('cases', 'population'))


# By default, separate() will split values wherever it sees a non-alphanumeric character
# (i.e. a character that isn’t a number or letter)
#  If you wish to use a specific character to separate a column, you can pass the character to the sep argument of separate().
table3 %>% 
  separate(rate, into = c('cases', 'population'), sep = '/')
# (Formally, sep is a regular expression, which you’ll learn more about in strings.)

# Look carefully at the column types: you’ll notice that cases and population are character columns. 
# This is the default behaviour in separate(): it leaves the type of the column as is. 
# Here, however, it’s not very useful as those really are numbers. We can ask separate() to try and convert to better types using convert = TRUE:
table3 %>% 
  separate(rate, into = c('cases', 'population'), convert = TRUE)

# You can also pass a vector of integers to sep. separate() will interpret the integers as positions to split at. 
# Positive values start at 1 on the far-left of the strings; negative value start at -1 on the far-right of the strings. 
# When using integers to separate strings, the length of sep should be one less than the number of names in into.
table3 %>% 
  separate(year, into = c('century', 'year'), sep = 2) %>% 
  separate(rate, into = c('cases', 'population'), convert = TRUE)

# 12.4.2 Unite
# unite() is the inverse of separate(): it combines multiple columns into a single column. You’ll need it much less frequently than separate(), 
# but it’s still a useful tool to have in your back pocket.
table5

table5 %>% 
  unite(new, century, year)
# In this case we also need to use the sep argument. The default will place an underscore (_) between the values from different columns. 
# Here we don’t want any separator so we use "":
table5 %>% 
  unite(new, century, year, sep = '')

## use mutate and select function: 
table5 %>% 
  mutate(new = paste(century, year, sep = '')) %>% 
  select(country, new, rate)

# 12.4.3 Exercises
# 1. What do the extra and fill arguments do in separate()? 
#    Experiment with the various options for the following two toy datasets.
## original
tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c("one", "two", "three"))
## add extra = 'drop', instead of default 'warn'
tibble(x = c("a,b,c", "d,e,f,g", "h,i,j")) %>% 
  separate(x, c('one', 'two', 'three'), extra = 'drop')

## original
tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"))
## add fill = 'right'
tibble(x = c("a,b,c", "d,e", "f,g,i")) %>% 
  separate(x, c("one", "two", "three"), fill = 'right')

# 2. Both unite() and separate() have a remove argument. 
#    What does it do? 
#    Why would you set it to FALSE?

## remove: If TRUE, remove input column from output data frame.
## If you want to keep the original column, you can add this argument to FALSE.
table3 %>% 
  separate(rate, into = c('cases', 'population'), convert = TRUE, remove = FALSE)

# 3. Compare and contrast separate() and extract(). 
#    Why are there three variations of separation (by position, by separator,
#    and with groups), but only one unite?

?separate
?extract

table3 %>% 
  separate(rate, into = c('cases', 'population'), convert = TRUE)

table3 %>% 
  extract(rate,into = c('cases', 'population'), "(.+)/(.+)")

# 12.5 Missing values
# Changing the representation of a dataset brings up an important subtlety of missing values. 
# Surprisingly, a value can be missing in one of two possible ways:
# 1. Explicitly, i.e. flagged with NA.
# 2. Implicitly, i.e. simply not present in the data.
# Let’s illustrate this idea with a very simple data set:
stocks <- tibble(
  year   = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr    = c(   1,    2,    3,    4,    2,    3,    4),
  return = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)
stocks

# There are two missing values in this dataset:
# 1. The return for the fourth quarter of 2015 is explicitly missing, 
#    because the cell where its value should be instead contains NA.
# 2. The return for the first quarter of 2016 is implicitly missing, 
#    because it simply does not appear in the dataset.

# The way that a dataset is represented can make implicit values explicit. 
# For example, we can make the implicit missing value explicit by putting years in the columns:
stocks %>% 
  spread(year, return)

# Because these explicit missing values may not be important in other representations of the data, 
# you can set na.rm = TRUE in gather() to turn explicit missing values implicit:
stocks %>% 
  spread(year, return) %>% 
  gather('year', 'return',`2015`:`2016`, na.rm = TRUE)

# Another important tool for making missing values explicit in tidy data is complete():
?complete
stocks %>% 
  complete(year, qtr)

# There’s one other important tool that you should know for working with missing values. 
# Sometimes when a data source has primarily been used for data entry, 
# missing values indicate that the previous value should be carried forward:
treatment <- tribble(
  ~ person,           ~ treatment, ~response,
  "Derrick Whitmore", 1,           7,
  NA,                 2,           10,
  NA,                 3,           9,
  "Katherine Burke",  1,           4
)
treatment

treatment %>% 
  fill(person)

# 12.5.1 Exercises
# 1. Compare and contrast the fill arguments to spread() and complete().

## spread: If set, missing values will be replaced with this value. 
## Note that there are two types of missingness in the input: 
## explicit missing values (i.e. NA), and implicit missings, rows that simply aren't present.
## Both types of missing value will be replaced by fill.
stocks %>% 
  spread(year, return, fill = 0) %>% 
  gather(year, return, 2:3)

## complete: A named list that for each variable supplies a single value to use 
## instead of NA for missing combinations.
stocks %>% 
  complete(year, qtr, fill = list(return = 0))

# 2. What does the direction argument to fill() do?
?fill

## direction argument will fill down or up the value.
stocks %>% 
  fill(return, .direction = 'up')

# 12.6 Case Study

# To finish off the chapter, let’s pull together everything you’ve learned to tackle a realistic data tidying problem. 
# The tidyr::who dataset contains tuberculosis (TB) cases broken down by year, country, age, gender, and diagnosis method. 
# The data comes from the 2014 World Health Organization Global Tuberculosis Report, available at http://www.who.int/tb/country/data/download/en/.

# There’s a wealth of epidemiological information in this dataset, 
# but it’s challenging to work with the data in the form that it’s provided:

# This is a very typical real-life example dataset. It contains redundant columns, odd variable codes, and many missing values.
# In short, who is messy, and we’ll need multiple steps to tidy it. Like dplyr, tidyr is designed so that each function does one thing well. 
# That means in real-life situations you’ll usually need to string together multiple verbs into a pipeline.

# The best place to start is almost always to gather together the columns that are not variables.
# Let’s have a look at what we’ve got:
who

# 1. It looks like country, iso2, and iso3 are three variables that redundantly specify the country.
# 2. year is clearly also a variable.
# 3. We don’t know what all the other columns are yet, but given the structure in the variable names 
#    (e.g. new_sp_m014, new_ep_m014, new_ep_f014) these are likely to be values, not variables.

who1 <- who %>% 
  gather(new_sp_m014:newrel_f65, key = 'key', value = 'cases', na.rm = TRUE)
who1

# We can get some hint of the structure of the values in the new key column by counting them:
who1 %>%
  count(key)

# You might be able to parse this out by yourself with a little thought and some experimentation, 
# but luckily we have the data dictionary handy. It tells us:
# 1. The first three letters of each column denote whether the column contains new or old cases of TB. 
#    In this dataset, each column contains new cases.
# 2. The next two letters describe the type of TB:
#    (1) rel stands for cases of relapse
#    (2) ep stands for cases of extrapulmonary TB
#    (3) sn stands for cases of pulmonary TB that could not be diagnosed by a pulmonary smear (smear negative)
#    (4) sp stands for cases of pulmonary TB that could be diagnosed be a pulmonary smear (smear positive)
# 3. The sixth letter gives the sex of TB patients. The dataset groups cases by males (m) and females (f).
# 4. The remaining numbers gives the age group. The dataset groups cases into seven age groups:
#    (1) 014 = 0 – 14 years old
#    (2) 1524 = 15 – 24 years old
#    (3) 2534 = 25 – 34 years old
#    (4) 3544 = 35 – 44 years old
#    (5) 4554 = 45 – 54 years old
#    (6) 5564 = 55 – 64 years old
#    (7) 65 = 65 or older

# We need to make a minor fix to the format of the column names: 
# unfortunately the names are slightly inconsistent because instead of new_rel we have newrel
# (it’s hard to spot this here but if you don’t fix it we’ll get errors in subsequent steps). 
# You’ll learn about str_replace() in strings, but the basic idea is pretty simple: 
# replace the characters “newrel” with “new_rel”. This makes all variable names consistent.
who2 <- who1 %>% 
  mutate(key = stringr::str_replace(key, 'newrel', 'new_rel'))

# We can separate the values in each code with two passes of separate(). 
# The first pass will split the codes at each underscore.
who3 <- who2 %>% 
  separate(key, c('new', 'type', 'sexage'), sep = '_')

# Then we might as well drop the new column because it’s constant in this dataset. 
# While we’re dropping columns, let’s also drop iso2 and iso3 since they’re redundant.
who3 %>% 
  count(new)

who4 <- who3 %>% 
  select(-new, -iso2, -iso3)

# Next we’ll separate sexage into sex and age by splitting after the first character:
who5 <- who4 %>% 
  separate(sexage, c('sex', 'age'), sep = 1)

# The who dataset is now tidy!
# I’ve shown you the code a piece at a time, assigning each interim result to a new variable. 
# This typically isn’t how you’d work interactively. Instead, you’d gradually build up a complex pipe:
who %>% 
  gather(key, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(key = stringr::str_replace(key, 'newrel', 'new_rel') ) %>% 
  separate(key, c('new', 'var', 'sexage'), sep = '_') %>% 
  select(-c(iso2, iso3, new)) %>% 
  separate(sexage, c('sex', 'age'), sep = 1)

# 12.6.1 Exercises
# 1. In this case study I set na.rm = TRUE just to make it easier to check that we had the correct values. 
#    Is this reasonable? Think about how missing values are represented in this dataset. 
#    Are there implicit missing values? What’s the difference between an NA and zero?
## 1. 

origin_row_num <- who %>% 
  gather(key, value, new_sp_m014:newrel_f65) %>% 
  mutate(key = stringr::str_replace(key, 'newrel', 'new_rel') )

implicit_row_num <- origin_row_num %>% 
  complete(country, year) 

nrow(implicit_row_num) - nrow(origin_row_num)
## 2. there are 206 implicit missing values rows


## 3. 


# 2. What happens if you neglect the mutate() step? 
#    (mutate(key = stringr::str_replace(key, "newrel", "new_rel")))
## It's will suffer from some mistake in the separate() step while neglect mutate() step.
who %>% 
  gather(key, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(key = stringr::str_replace(key, 'newrel', 'new_rel') ) %>% 
  separate(key, c('new', 'var', 'sexage'), sep = '_') %>% 
  select(-c(iso2, iso3, new)) %>% 
  separate(sexage, c('sex', 'age'), sep = 1)

# 3. I claimed that iso2 and iso3 were redundant with country. Confirm this claim.
who %>% 
  summarise(
    country_num = n_distinct(country),
    iso2_num = n_distinct(iso2),
    iso3_num = n_distinct(iso3)
  )

# 4. For each country, year, and sex compute the total number of cases of TB.
#    Make an informative visualisation of the data.
who_new <- who %>% 
  gather(key, value, new_sp_m014:newrel_f65, na.rm = TRUE) %>% 
  mutate(key = stringr::str_replace(key, 'newrel', 'new_rel') ) %>% 
  separate(key, c('new', 'var', 'sexage'), sep = '_') %>% 
  select(-c(iso2, iso3, new)) %>% 
  separate(sexage, c('sex', 'age'), sep = 1)

who_new %>% 
  group_by(country, year, sex) %>% 
  summarise(cases = sum(value)) %>% 
  unite(country_sex, country, sex, remove = FALSE) %>% 
  ggplot(aes(year, cases, group = country_sex, color = sex)) + 
  geom_line()

# 12.7 Non-tidy data

# Before we continue on to other topics, it’s worth talking briefly about non-tidy data. 
# Earlier in the chapter, I used the pejorative term “messy” to refer to non-tidy data. 
# That’s an oversimplification: there are lots of useful and well-founded data structures that are not tidy data. 
# There are two main reasons to use other data structures:
# 1. Alternative representations may have substantial performance or space advantages.
# 2. Specialised fields have evolved their own conventions for storing data that may be quite different to the conventions of tidy data.

# Either of these reasons means you’ll need something other than a tibble (or data frame). 
# If your data does fit naturally into a rectangular structure composed of observations and variables,
# I think tidy data should be your default choice.
# But there are good reasons to use other structures; tidy data is not the only way.
# If you’d like to learn more about non-tidy data, 
# I’d highly recommend this thoughtful blog post by Jeff Leek: http://simplystatistics.org/2016/02/17/non-tidy-data/