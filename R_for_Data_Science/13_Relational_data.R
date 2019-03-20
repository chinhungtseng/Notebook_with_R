# 13 Relational data

# 13.1 Introduction
# Multiple tables of data are called relational data because it is the relations, 
# not just the individual datasets, that are important.

# Relations are always defined between a pair of tables. 

# To work with relational data you need verbs that work with pairs of tables. 
# There are three families of verbs designed to work with relational data:

# 1. Mutating joins, which add new variables to one data frame from matching observations in another.
# 2. Filtering joins, which filter observations from one data frame based on whether 
#    or not they match an observation in the other table.
# 3. Set operations, which treat observations as if they were set elements.

# 13.1.1 Prerequisites
# We will explore relational data from nycflights13 using the two-table verbs from dplyr.
library(tidyverse)
library(nycflights13)

# 13.2 nycflights13

# 1. airlines lets you look up the full carrier name from its abbreviated code:
airlines

# 2. airports gives information about each airport, identified by the faa airport code:
airports

# 3. planes gives information about each plane, identified by its tailnum:
planes

# 4. weather gives the weather at each NYC airport for each hour:
weather

# 5. flights
flights

# One way to show the relationships between the different tables is with a drawing:
#############################################################
#                   flights                 weather         #
#                 ------------             ---------        #
# airports             yaer *                * year         #
# -------              month *               * month        #
# * faa *              day *                 * day          #
#   ...                hour *                * hour         #
#                     flight *               * origin       #
#                   * origin                  ...           #
#  planes            * dest                                 #
# --------          * tailnum               airlines        #
# tailnum *           carrier *            ----------       #
#   ...                 ...                * carrier        #
#                                             names         #
#############################################################

# For nycflights13:
# 1. flights connects to planes via a single variable, tailnum.
# 2. flights connects to airlines through the carrier variable.
# 3. flights connects to airports in two ways: via the origin and dest variables.
# 4. flights connects to weather via origin (the location), and year, month, day and hour (the time).

# 13.2.1 Exercises
# 1. Imagine you wanted to draw (approximately) the route each plane flies from its origin to its destination. 
#    What variables would you need? What tables would you need to combine?

## we need to combine the tables of airports and flights.
## and select the origin and dest columns in flights; faa column in airports

# 2. I forgot to draw the relationship between weather and airports. 
#    What is the relationship and how should it appear in the diagram?
weather %>% names()
airports %>% names()
## origin column in weather and faa column in airport

# 3. weather only contains information for the origin (NYC) airports. 
#    If it contained weather records for all airports in the USA, what additional relation would it define with flights?
## dest

# 4. We know that some days of the year are “special”, and fewer people than usual fly on them. 
#    How might you represent that data as a data frame? What would be the primary keys of that table? 
#    How would it connect to the existing tables?
## year, month, day

# 13.3 Keys
# The variables used to connect each pair of tables are called keys. 
# A key is a variable (or set of variables) that uniquely identifies an observation. 
# In simple cases, a single variable is sufficient to identify an observation. 
# For example, each plane is uniquely identified by its tailnum. In other cases, multiple variables may be needed. 
# For example, to identify an observation in weather you need five variables: year, month, day, hour, and origin.

# There are two types of keys:
# 1. A primary key uniquely identifies an observation in its own table. 
#    For example, planes$tailnum is a primary key because it uniquely identifies each plane in the planes table.

# 2. A foreign key uniquely identifies an observation in another table. 
#    For example, the flights$tailnum is a foreign key because it appears in the flights table where it matches each flight to a unique plane.

# A variable can be both a primary key and a foreign key. 
# For example, origin is part of the weather primary key, and is also a foreign key for the airport table.

# Once you’ve identified the primary keys in your tables, it’s good practice to verify that they do indeed uniquely identify each observation. 
# One way to do that is to count() the primary keys and look for entries where n is greater than one:

planes %>% 
  count(tailnum) %>% 
  filter(n > 1)

weather %>% 
  count(year, month, day, hour, origin) %>% 
  filter(n > 1)

# Sometimes a table doesn’t have an explicit primary key: 
# each row is an observation, but no combination of variables reliably identifies it. 
# For example, what’s the primary key in the flights table? 
# You might think it would be the date plus the flight or tail number, but neither of those are unique:
flights %>% 
  count(year, month, day, flight) %>% 
  filter(n > 1)

flights %>% 
  count(year, month, day, tailnum) %>% 
  filter(n > 1)

# When starting to work with this data, I had naively assumed that each flight number would be only used once per day:
# that would make it much easier to communicate problems with a specific flight. 
# Unfortunately that is not the case! If a table lacks a primary key, it’s sometimes useful to add one with mutate() and row_number().
# That makes it easier to match observations if you’ve done some filtering and want to check back in with the original data. 
# This is called a surrogate key.

flights %>% 
  count(year, month, day, tailnum) %>% 
  filter(n > 1)

## surrogate key
flights %>% 
  mutate(index = row_number()) %>% 
  select(index, everything())

# A primary key and the corresponding foreign key in another table form a relation.  
# Relations are typically one-to-many. For example, each flight has one plane, 
# but each plane has many flights. In other data, you’ll occasionally see a 1-to-1 relationship. 
# You can think of this as a special case of 1-to-many.

# You can model many-to-many relations with a many-to-1 relation plus a 1-to-many relation. 
# For example, in this data there’s a many-to-many relationship between airlines and airports: 
# each airline flies to many airports; each airport hosts many airlines.

# 13.3.1 Exercises
# 1. Add a surrogate key to flights.
flights %>% 
  mutate(index = row_number()) %>% 
  select(index, everything())

# 2. Identify the keys in the following datasets
#    (You might need to install some packages and read some documentation.)
Lahman::Batting
babynames::babynames
nasaweather::atmos
fueleconomy::vehicles
ggplot2::diamonds

## (1) primary key is:
Lahman::Batting %>% 
  count(playerID, yearID, stint, teamID, lgID) %>% 
  filter(n > 1)

## (2) primary key is:
babynames::babynames %>% 
  count(name, year, sex) %>% 
  filter(n > 1)

## (3) primary key is:
nasaweather::atmos %>% 
  count(lat, long, year, month) %>% 
  filter(n > 1)

## (4) primary key is:
fueleconomy::vehicles %>% 
  count(id) %>% 
  filter(n > 1)

## (5) I can't find the primary key with diamonds, so it would be appropriate to add surrogate key.
ggplot2::diamonds %>% 
  count(carat, cut, color, clarity, depth , table, x, y, z) %>% 
  filter(n > 1)

# 3. Draw a diagram illustrating the connections between the Batting, Master, 
#    and Salaries tables in the Lahman package. Draw another diagram that shows the relationship between Master, 
#    Managers, AwardsManagers.
Lahman::Batting %>% head(5)
Lahman::Master %>% head(5)
Lahman::Salaries %>% head(5)

## primary key is: 
Lahman::Batting %>% 
  count(playerID, yearID, stint, teamID, lgID) %>% 
  filter(n > 1)
#############################################################
#                                                           #
#  Batting               Master              Salaries       #
# ----------          ----------           ----------       #
#  playreID *        * playerID            * yearID         #
#   yearID  *          birthYear           * teamID         #
#   stint             BirthMonth           *  lgID          #
#   teamID *           BrthDay             * playerID       #
#   lgID *           BirthCountry            salary         #
#    ...              BirthState                            #
#                      BirthCity                            # 
#                        ...                                #
#                                                           #
#############################################################

Lahman::Master %>% head(5)
Lahman::Managers %>% head(5)
Lahman::AwardsManagers %>% head(5)

#############################################################
#                                                           #
#                                                           #
#  Managers               Master           AwardsManagers   #
# ----------          ----------           ----------       #
#  playreID *        * playerID            * PlayerID       #
#   yearID  *          birthYear             awardID        #
#   teamID             BirthMonth           * yearID        #
#   lgID *              BrthDay              * lgID         #
# inseasion *           BirthCountry           tie          #
#    ...              BirthState              notes         #
#                      BirthCity                            # 
#                        ...                                #
#                                                           #
#############################################################

#   How would you characterise the relationship between the Batting, Pitching, and Fielding tables?
Lahman::Batting %>% head(5)
Lahman::Pitching %>% head(5)
Lahman::Fielding %>% head(5)

## These tables all can match the playerID, yearID, stint, teamID, lgID.

# 13.4 Mutating joins
# The first tool we’ll look at for combining a pair of tables is the mutating join. 
# A mutating join allows you to combine variables from two tables. 
# It first matches observations by their keys, then copies across variables from one table to the other.

# Like mutate(), the join functions add variables to the right, so if you have a lot of variables already,
# the new variables won’t get printed out. For these examples, we’ll make it easier to see what’s going on 
# in the examples by creating a narrower dataset:
flights2 <- flights %>% 
  select(year:day, hour, origin, dest, tailnum, carrier)

flights2
# (Remember, when you’re in RStudio, you can also use View() to avoid this problem.)

# Imagine you want to add the full airline name to the flights2 data.
# You can combine the airlines and flights2 data frames with left_join():
flights2 %>% 
  select(-c(origin, dest)) %>% 
  left_join(airlines, by = "carrier")

# The result of joining airlines to flights2 is an additional variable: name. 
# This is why I call this type of join a mutating join. In this case, 
# you could have got to the same place using mutate() and R’s base subsetting:
flights2 %>% 
  select(-c(origin, dest)) %>% 
  mutate(name = airlines$name[match(carrier, airlines$carrier)])

# The following sections explain, in detail, how mutating joins work. 
# You’ll start by learning a useful visual representation of joins. 
# We’ll then use that to explain the four mutating join functions: the inner join, and the three outer joins. 
# When working with real data, keys don’t always uniquely identify observations, 
# so next we’ll talk about what happens when there isn’t a unique match. 
# Finally, you’ll learn how to tell dplyr which variables are the keys for a given join.

# 13.4.1 Understanding joins

# To help you learn how joins work, I’m going to use a visual representation:
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# The coloured column represents the “key” variable: these are used to match the rows between the tables. 
# The grey column represents the “value” column that is carried along for the ride. 
# In these examples I’ll show a single key variable, but the idea generalises in a straightforward way to multiple keys and multiple values.

# A join is a way of connecting each row in x to zero, one, or more rows in y. 
# The following diagram shows each potential match as an intersection of a pair of lines.

# (If you look closely, you might notice that we’ve switched the order of the key and value columns in x. 
# This is to emphasise that joins match based on the key; the value is just carried along for the ride.)

# In an actual join, matches will be indicated with dots.
# The number of dots = the number of matches = the number of rows in the output.

# 13.4.2 Inner join

# The simplest type of join is the inner join.
# An inner join matches pairs of observations whenever their keys are equal:

# (To be precise, this is an inner equijoin because the keys are matched using the equality operator. 
# Since most joins are equijoins we usually drop that specification.)

# The output of an inner join is a new data frame that contains the key, the x values, 
# sand the y values. We use by to tell dplyr which variable is the key:
x %>% 
  inner_join(y , by = 'key')

# 13.4.3 Outer joins

# An inner join keeps observations that appear in both tables. 
# An outer join keeps observations that appear in at least one of the tables.
# There are three types of outer joins:

# 1. A left join keeps all observations in x.
# 2. A right join keeps all obsevations in y.
# 3. A full join keeps all observations in x and y.

# These joins work by adding an additional “virtual” observation to each table.
# This observation has a key that always matches (if no other key matches), and a value filled with NA.

# The most commonly used join is the left join: 
# you use this whenever you look up additional data from another table, 
# because it preserves the original observations even when there isn’t a match. 
# The left join should be your default join: 
# use it unless you have a strong reason to prefer one of the others.

# 13.4.4 Duplication keys

# So far all the diagrams have assumed that the keys are unique. 
# But that’s not always the case. This section explains what happens when the keys are not unique. 
#There are two possibilities:

# 1. One table has duplicate keys. T
#    his is useful when you want to add in additional information as there is typically a one-to-many relationship.
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)

left_join(x, y, by = 'key')

# 2. Both tables have duplicate keys. 
#    This is usually an error because in neither table do the keys uniquely identify an observation. 
#    When you join duplicated keys, you get all possible combinations, the Cartesian product:
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)

left_join(x, y, by = 'key')

# 13.4.5 Defining the key columns

# So far, the pairs of tables have always been joined by a single variable, and that variable has the same name in both tables. 
# That constraint was encoded by by = "key". You can use other values for by to connect the tables in other ways:

# 1. The default, by = NULL, uses all variables that appear in both tables, the so called natural join. 
#    For example, the flights and weather tables match on their common variables: year, month, day, hour and origin.
flights2 %>% 
  left_join(weather)

# 2. A character vector, by = "x". This is like a natural join, but uses only some of the common variables. 
#    For example, flights and planes have year variables, but they mean different things so we only want to join by tailnum.
flights2 %>% 
  left_join(planes, by = 'tailnum')
#    Note that the year variables (which appear in both input data frames, but are not constrained to be equal) 
#    are disambiguated in the output with a suffix.

# 3. A named character vector: by = c("a" = "b"). 
#    This will match variable a in table x to variable b in table y. 
#    The variables from x will be used in the output.

#    For example, if we want to draw a map we need to combine the flights data with the airports data 
#    which contains the location (lat and lon) of each airport. Each flight has an origin and destination airport,
#    so we need to specify which one we want to join to:

flights2 %>% 
  left_join(airports, c('dest' = 'faa'))

# 13.4.6 Exercises
# 1. Compute the average delay by destination, then join on the airports data frame so you can show 
#    the spatial distribution of delays. Here’s an easy way to draw a map of the United States:
airports %>%
  semi_join(flights, c("faa" = "dest")) %>%
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point() +
  coord_quickmap()
#    (Don’t worry if you don’t understand what semi_join() does — you’ll learn about it next.)
#    You might want to use the size or colour of the points to display the average delay for each airport.
flights %>% 
  group_by(dest) %>% 
  summarise(avg_arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  left_join(airports, by = c('dest' = 'faa')) %>% 
  ggplot(aes(lon, lat, size = avg_arr_delay, alpha = avg_arr_delay)) + 
  geom_point() + 
  borders('state') + 
  coord_quickmap()

# 2. Add the location of the origin and destination (i.e. the lat and lon) to flights.
flights %>% 
  left_join(airports, by = c('origin' = 'faa')) %>% 
  left_join(airports, by = c('dest' = 'faa'), suffix = c('.origin', '.dest')) %>% 
  select(origin, dest, contains('lat'), contains('lon'))

# 3. Is there a relationship between the age of a plane and its delays?
## step 1: compute the average delay by tailnum.
## step 2: join the planes by tailnum.
## step 3: graph the relationship between tailnum' year and average delay.
flights %>% 
  group_by(tailnum) %>% 
  summarise(
    avg_arr_delay = mean(arr_delay, na.rm = TRUE), 
    avg_dep_delay = mean(dep_delay, na.rm = TRUE)
  ) %>% 
  left_join(planes, by = 'tailnum') %>%
  mutate(aircraft_age = (max(planes$year, na.rm = TRUE) - year)) %>%
  group_by(aircraft_age) %>% 
  summarise(
    avg_arr_delay = mean(avg_arr_delay, na.rm = TRUE),
    avg_dep_delay = mean(avg_dep_delay, na.rm = TRUE)
  ) %>% 
  ggplot() + 
  geom_smooth(aes(aircraft_age, avg_arr_delay), se = FALSE, color = 'red') + 
  geom_smooth(aes(aircraft_age, avg_dep_delay), se = FALSE, color = 'blue')

flights %>% 
  group_by(tailnum) %>%
  summarise(
    avg_dep_delay = mean(dep_delay, na.rm = TRUE),
    avg_arr_delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  gather(key = 'mode', value = 'delay', 2:3) %>% 
  left_join(planes) %>% 
  ggplot() +
  geom_smooth(aes(year, delay))

# 4. What weather conditions make it more likely to see a delay?
flights %>% 
  left_join(weather, by = c("year", "month", "day", "origin", "hour", "time_hour")) %>% 
  gather(key = 'conditions', value = 'value', temp:visib) %>% 
  filter(!is.na(dep_delay)) %>% 
  ggplot(aes(value, dep_delay)) + 
  geom_point() + 
  facet_grid(.~conditions, scales = 'free_x')

# 5. What happened on June 13 2013? Display the spatial pattern of delays, 
#    and then use Google to cross-reference with the weather.
flights %>% 
  filter(year == 2013, month == 6, day == 13) %>% 
  group_by(dest) %>% 
  summarise(avg_arr_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  left_join(airports, by = c('dest' = 'faa')) %>% 
  ggplot(aes(lon, lat, size = avg_arr_delay, color = avg_arr_delay)) + 
  geom_point() + 
  borders('state') +
  coord_quickmap()
## https://en.wikipedia.org/wiki/June_12–13,_2013_derecho_series

# 13.4.7 Other implementations
# base::merge() can perform all four types of mutating join:
# --------------------|-----------------------------------------|
# dplyr	              | merge                                   |
# --------------------|-----------------------------------------|
# inner_join(x, y)    | merge(x, y)                             |
# left_join(x, y)	    | merge(x, y, all.x = TRUE)               |
# right_join(x, y)	  | merge(x, y, all.y = TRUE)               |
# full_join(x, y)	    | merge(x, y, all.x = TRUE, all.y = TRUE) |
# --------------------|-----------------------------------------|

# The advantages of the specific dplyr verbs is that they more clearly convey the intent of your code: 
# the difference between the joins is really important but concealed in the arguments of merge(). 
# dplyr’s joins are considerably faster and don’t mess with the order of the rows.

# SQL is the inspiration for dplyr’s conventions, so the translation is straightforward:
# -----------------------------|----------------------------------------------|
# dplyr                        | SQL                                          |
# -----------------------------|----------------------------------------------|
# inner_join(x, y, by = "z")	 | SELECT * FROM x INNER JOIN y USING (z)       |
# left_join(x, y, by = "z")	   | SELECT * FROM x LEFT OUTER JOIN y USING (z)  |
# right_join(x, y, by = "z")	 | SELECT * FROM x RIGHT OUTER JOIN y USING (z) |
# full_join(x, y, by = "z")	   | SELECT * FROM x FULL OUTER JOIN y USING (z)  |
# -----------------------------|----------------------------------------------|
# Note that “INNER” and “OUTER” are optional, and often omitted.

# Joining different variables between the tables, e.g. inner_join(x, y, by = c("a" = "b")) 
# uses a slightly different syntax in SQL: SELECT * FROM x INNER JOIN y ON x.a = y.b. 
# As this syntax suggests, SQL supports a wider range of join types than dplyr because 
# you can connect the tables using constraints other than equality (sometimes called non-equijoins).

# 13.5 Filtering joins
# Filtering joins match observations in the same way as mutating joins,
# but affect the observations, not the variables. There are two types:

# 1. semi_join(x, y) keeps all observations in x that have a match in y.
# 2. anti_join(x, y) drops all observations in x that have a match in y.

# Semi-joins are useful for matching filtered summary tables back to the original rows. 
# For example, imagine you’ve found the top ten most popular destinations:

top_dest <- flights %>% 
  count(dest, sort = TRUE) %>% 
  head(10)
top_dest

# Now you want to find each flight that went to one of those destinations. 
# You could construct a filter yourself:
flights %>% 
  filter(dest %in% top_dest$dest)

# But it’s difficult to extend that approach to multiple variables. 
# For example, imagine that you’d found the 10 days with highest average delays. 
# How would you construct the filter statement that used year, month, and day to match it back to flights?
# Instead you can use a semi-join, which connects the two tables like a mutating join, 
# but instead of adding new columns, only keeps the rows in x that have a match in y:
flights %>% 
  semi_join(top_dest)

# Only the existence of a match is important; it doesn’t matter which observation is matched. 
# This means that filtering joins never duplicate rows like mutating joins do:

# The inverse of a semi-join is an anti-join. An anti-join keeps the rows that don’t have a match:
# Anti-joins are useful for diagnosing join mismatches. 
# For example, when connecting flights and planes, 
# you might be interested to know that there are many flights that don’t have a match in planes:
flights %>% 
  anti_join(planes, by = 'tailnum') %>% 
  count(tailnum, sort = TRUE) 

# 13.5.1 Exercises
# 1. What does it mean for a flight to have a missing tailnum? 
#    What do the tail numbers that don’t have a matching record in planes have in common? 
#    (Hint: one variable explains ~90% of the problems.)
flights %>% 
  filter(is.na(tailnum))
## It's seems that the flights have a missing tailnum is all the canceled flight.
flights %>% 
  filter(is.na(tailnum)) %>% 
  count(origin, sort = TRUE) %>% 
  left_join(airports, c('origin' = 'faa')) %>% 
  ggplot(aes(lon, lat)) + 
  geom_point(size = 3) + 
  coord_quickmap() + 
  borders('state')

flights %>% 
  anti_join(planes, by = 'tailnum') %>% 
  count(carrier, sort = TRUE)

# 2. Filter flights to only show flights with planes that have flown at least 100 flights.
## count the flights that have flown at least 1000 flights.
at_least_100 <- flights %>% 
  count(tailnum, sort = TRUE) %>% 
  filter(n >= 100)

## join two table with flights and planes.
flights %>% 
  semi_join(at_least_100, by = 'tailnum')

# 3. Combine fueleconomy::vehicles and fueleconomy::common to find only the records for the most common models.
## Quick look the tables:
fueleconomy::vehicles
fueleconomy::common

fueleconomy::vehicles %>% 
  left_join(fueleconomy::common, by = c('make', 'model'))

# 4. Find the 48 hours (over the course of the whole year) that have the worst delays. 
#    Cross-reference it with the weather data. Can you see any patterns?
worst_hour <-flights %>% 
  mutate(hour = sched_dep_time %/% 100) %>% 
  group_by(origin, year, month, day, hour) %>% 
  summarise(dep_delay = mean(dep_delay, na.rm  = TRUE)) %>% 
  ungroup() %>% 
  arrange(desc(dep_delay)) %>% 
  head(48)

weather_most_delay <- weather %>% 
  semi_join(worst_hour, by = c('origin', 'year', 'month', 'day', 'hour'))

flights_2_days <- flights %>%  
  group_by(year, month, day) %>% 
  summarise(
    dep_delay = mean(dep_delay, na.rm = TRUE),
    arr_delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  unite(date, year, month, day, sep = '-') %>% 
  mutate(date = parse_date(date, '%Y-%m-%d')) %>% 
  gather(key = 'mode', value = 'delay', 2:3) %>% 
  mutate(mode = factor(mode, labels = c('Average departure delay', 'Average arrival delay')))

weather_2_days <- weather %>% 
  group_by(year, month, day) %>% 
  summarise(
    wind_speed = mean(wind_speed, na.rm = TRUE),
    wind_gust = mean(wind_gust, na.rm = TRUE),
    precip = mean(precip, na.rm = TRUE),
    visib = mean(visib, na.rm = TRUE)
  ) %>% 
  unite(date, year, month, day, sep = '-') %>% 
  mutate(date = parse_date(date, '%Y-%m-%d'))

flights_2_days %>% 
  left_join(weather_2_days)

# 5. What does anti_join(flights, airports, by = c("dest" = "faa")) tell you? 
#    What does anti_join(airports, flights, by = c("faa" = "dest")) tell you?
anti_join(flights, airports, by = c('dest' = 'faa'))
## It's will show the destination of flights that not in airports table.

anti_join(airports, flights, by = c('faa' = 'dest'))
## It's will show the airport's name and destination that no planes fling to .

# 6. You might expect that there’s an implicit relationship between plane and airline, 
#    because each plane is flown by a single airline.
#    Confirm or reject this hypothesis using the tools you’ve learned above.
flights %>% 
  select(carrier, tailnum) %>% 
  group_by(tailnum) %>% 
  summarise(n = n_distinct(carrier)) %>% 
  filter( n > 1)

# 13.6 Join problems

# The data you’ve been working with in this chapter has been cleaned up so that you’ll have as few problems as possible.
# Your own data is unlikely to be so nice, so there are a few things that you should do with your own data to make your joins go smoothly.

# 1. Start by identifying the variables that form the primary key in each table. 
#    You should usually do this based on your understanding of the data, 
#    not empirically by looking for a combination of variables that give a unique identifier.
#    If you just look for variables without thinking about what they mean, 
#    you might get (un)lucky and find a combination that’s unique in your current data 
#    but the relationship might not be true in general.
# For example, the altitude and longitude uniquely identify each airport, but they are not good identifiers!
airports %>% count(alt, lon) %>% filter(n > 1)

# 2. Check that none of the variables in the primary key are missing. 
#    If a value is missing then it can’t identify an observation!

# 3. Check that your foreign keys match primary keys in another table. 
#    The best way to do this is with an anti_join().
#    It’s common for keys not to match because of data entry errors. Fixing these is often a lot of work.

#    If you do have missing keys, you’ll need to be thoughtful about your use of inner vs. outer joins, 
#    carefully considering whether or not you want to drop rows that don’t have a match.

# Be aware that simply checking the number of rows before and after the join is not sufficient to 
# ensure that your join has gone smoothly. If you have an inner join with duplicate keys in both tables, 
# you might get unlucky as the number of dropped rows might exactly equal the number of duplicated rows!

# 13.7 Set operations
# The final type of two-table verb are the set operations.
# Generally, I use these the least frequently, 
# but they are occasionally useful when you want to break a single complex filter into simpler pieces. 
# All these operations work with a complete row, comparing the values of every variable. 
# These expect the x and y inputs to have the same variables, and treat the observations like sets:

# 1. intersect(x, y): return only observations in both x and y.
# 2. union(x, y): return unique observations in x and y.
# 3. setdiff(x, y): return observations in x, but not in y.

df1 <- tribble(
  ~x, ~y,
  1,  1,
  2,  1
)

df2 <- tribble(
  ~x, ~y, 
  1,  1, 
  1,  2
)

# The four possibilities are:
intersect(df1, df2)

union(df1, df2)

setdiff(df1, df2)

setdiff(df2, df1)
