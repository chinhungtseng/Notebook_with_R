# 16 Dates and times

# 16.1 Introduction
# This chapter will show you how to work with dates and times in R. At first glance, dates and times seem simpe.
# You use them all the time in your regular life, and they don't seem to cause much confusion.
# However, the more you learn about dates and times, the more complicated they seem to get.
# To warm up, try these three seemingly simple questions:
# 1. Does every year have 365 days?
# 2. Does every day have 24 hours?
# 3. Does every minute have 69 seconds?

# I'm sure you know that not every year has 365 days, but do you know the full rule for determining if a year is a leap year? (It has three parts.)
# You might have remembered that many parts of the world use daylight savings time(DST), so that some days have 23 hours, and other have 25.
# You might not have known that some minutes have 61 seconds because every now and then leap seconds are added because the Earth's rotation is gradully slowing down.

# Dates and times are hard because they have to reconcile two physical phenomena(the retation of the Earth and its orbit around the sun)
# with a whole raft of geopolitical phenomena includin months, time zones, and DST. This chapter won't teach you every last detail about dates and times, 
# but it will give you a solid grounding of practical skill that will help you with common data analysis challenges.

# 16.1.1 Prerequisites

# This chapter will focus on th lubridate package, which makes it easier to work with dates and times in R.
# lubridate is not part of core tidyverse because you only need it when you're working with dates/times.
# We will also need nycflights13 for practice data.
library(tidyverse)

library(lubridate)
library(nycflights13)

# 16.2 Creating date/times

# There are three types of date/time data that refer to an instant in time:
# 1. A date. Tibbles print this as <date>.
# 2. A time within a day. Tibbles print this as <time>.
# 3. A date-time is a date plus a time: it uniquely identifies an instant in time (typically to the nearest second).
#    Tibbles print this as <dttm>. Elsewhere in R these are called POSIXct, but I don't think that's a very useful name.

# In this chapter we are only going to focus on dates and date-times as R doesn't have a native class for storing times.
# If you need one, you can use the hms package.

# You should always use the simplest possible data type that works for your needs.
# That means if you can use a date instead of a date-time, you should. Date-times are substantially more complicated because of 
# the need to handle time zones. which we'll come back to at the end of the chapter.

# To get the current date or date-time you can use today() or now():
today()
now()

# Otherwise, there are three ways you're likely to create a date/time:
# 1. From a string.
# 2. From individual date-time components.
# 3. From an existing date/time object.
# They work as follows.

# 16.2.1 From strings

# Date/time data often comes as strings. You've seen one approach to parsing strings into date=times in date-times.
# Another approach is to use the helpers proveded by lubridate.
# They automatically work out the format once you specify the order of the component.
# To use them, identify the order in which year, month, and day appear in your dates, then arrange "y', "m", and "d" in the same order.
# That gives you the nameof the lubridate function that will parse your date. For example:
ymd("2017-01-31")
mdy("January 31st, 2017")
dmy("31-Jan-2017")

# These functions also take unquoted numbers. This is the most concise way to create a single date/time object,
# as you might need when diltering date/time data. ymd() is short and unambiguous:
ymd(20170131)

# ymd() and friends create dates. To create a date-time, add an underscore and one or more of "h", "m", and "s to the name of the parsing function:
ymd_hms("2017-01-31 20:11:59")
mdy_hm("01/31/2017 08:01")

# You can also force the creation of a date-time from a date by supplying a timezone:
ymd(20170131, tz = "UTC")

# 16.2.2 From individual components

# Instead of a single string, sometimes you'll have the individual components of the date-time spread across multiple columns.
# This is what we have in the flights data:
flights %>% 
  select(year, month, day, hour, minute)

# To create a date/time from this sort of input, use made_date() for dates, or make_datetime() for date-times:
flights %>% 
  select(year, month, day, hour, minute) %>% 
  mutate(departure = make_datetime(year, month, day, hour, minute))

# Let's do the same thing for each of the four time columns in flights. The times are represented in a slightly odd format, 
# so we use modulus arithmetic to pull out the hour and minute components.
# Once I've created the date-time variables, I focus in on the variables we'll explore in the rest of the chapter.
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>% 
  filter(!is.na(dep_time), !is.na(arr_time)) %>% 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time), 
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time), 
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>% 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt

flights_dt %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 second = 1 day

# Or within a single day:
flights_dt %>% 
  filter(dep_time < ymd(20130102)) %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes

# Note that when you use date-times in a numeric context (like in a histogram), 1 means 1 secon, so a binwidth of 86400 means one day, For dates, 1 means 1 day.

# 16.2.3 From other types

# You may want to switch between a date-time and a date. That's the job of as_datetime() and as_date():
as_datetime(today())
as_date(now())

# Sometimes you'll get date/times as numeric offsets from the "Unix Epoch", 1970-01-01. 
# If the offset is in seconds, use as_datetime(); if it's in days, use as_date().
as_datetime(60 * 60 * 10)
as_date(354 * 10 + 2)

# 16.2.4 Exercises

# 1. What happens if you parse a string that contains invalid dates?
ymd(c("2010-10-10", "bananas"))
## It's will convert to NA.

# 2. What does the tzone argument to today() do? Why is it important?
today()
## a character vector specifying which time zone you would like to find the current date of. 
## tzone defaults to the system time zone set on your computer.

# 3. Use the appropriate lubridate function to parse each of the following dates:
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014

## (1)
d1 %>% mdy()

## (2)
d2 %>% ymd()

## (3)
d3 %>% dmy()

## (4)
d4 %>% mdy()

## (5)
d5 %>% mdy()

# 16.3 Date-time components

# Now that you know how to get date-time data into R's date-time data structures, let's explore what you can do with them.
# This section will focus on the accessor functions that let you get and set individual components.
# The next section will look at how arithmetic works with date-times.

# 16.3.1 Getting components
# You can pull out individual parts of the date with the accessor functions year(), month(), mday() (day of the month),
# yday() (day of the year), wday() (day of the week), hour(), minute(), and second().
datetime <- ymd_hms("2016-07-08 12:34:56")

year(datetime)
month(datetime)
mday(datetime)
yday(datetime)
wday(datetime)

# For month() and wday() you can set label = TRUE to return the abbreviated name of the month or day of the week.
# Set abbr = FALSE to return the full name.
month(datetime, label = TRUE)

wday(datetime, label = TRUE, abbr = FALSE)

# We can use wday() to see that more flights depart during the week than on the weekend:
flights_dt %>% 
  mutate(wday = wday(dep_time, label = TRUE)) %>% 
  ggplot(aes(x = wday)) + 
  geom_bar()

# There's an interesting pattern if we look at the average departure delay by minute within the hour.
# It looks like flights leaving in minutes 20-30 and 50-60 have much lower delays than the rest of the hour!
flights_dt %>% 
  mutate(minute = minute(dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  ) %>% 
  ggplot(aes(minute, avg_delay)) + 
  geom_line()

# Interestingly, if we look at the scheduled departure time we don't see such a strong pattern:
sched_dep <- flights_dt %>% 
  mutate(minute = minute(sched_dep_time)) %>% 
  group_by(minute) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )
ggplot(sched_dep, aes(minute, avg_delay)) + 
  geom_line()

# So why do we see that pattern with the actual departure times" Well, like much data collected by humans, 
# there's a strong bias towards flights leaving at "nice" departure times. 
# Always be alert for this sort of pattern whenever you work with date that involves human judgement!
ggplot(sched_dep, aes(minute, n)) + 
  geom_line()

# 16.3.2 Rounding 
# An alternative approach to plotting individul components is to round the date to a nearby unit of time, with floor_date(), round_date(), and ceiling_date().
# Each function takes a vector of dates to adhust and then the name of the unit round down(floor), round up(ceilling), or round to.
# This, for example, allows us to plot the number of flights per week.
flights_dt %>% 
  count(week = floor_date(dep_time, "week")) %>% 
  ggplot(aes(week, n)) + geom_line()

# Computing the difference between a rounded and unrounded date can be particularly useful.

# 16.3.3 Setting components
# You can alse use each accessor function to set the components of a date/time:
(datetime <- ymd_hms("2016-07-08 12:34:56"))

year(datetime) <- 2020
datetime

month(datetime) <- 01
datetime

hour(datetime) <- hour(datetime) + 1
datetime

# Alternatively, rather than modifying in place, you can create a new date-time with update().
# This also allows you to set multuple values at once.
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)

# If values are too big, they will roll-over:
ymd("2015-02-01") %>% 
  update(mday = 30)

ymd("2015-02-01") %>% 
  update(hour = 400)

# You can use update() to show the distribution of flights across the course of the day for every day of the year:
flights_dt %>% 
  mutate(dep_hour = update(dep_time, yday = 1)) %>% 
  ggplot(aes(dep_hour)) + 
  geom_freqpoly(binwidth = 300)

# Setting larger components of a date to a constant is a powerful technique that allows you explore patterns in the smaller components.

# 16.3.4 Exercises 
# 1. How does the distribution of the flight times within a day change over the course of the year?
flights_dt %>% 
  mutate(
    date = make_date(year(dep_time), month(dep_time), mday(dep_time)),
    hour = hour(dep_time)
  ) %>%
  group_by(date, hour) %>% 
  ggplot(aes(hour, group = date)) + 
  geom_density()

# 2. Compare dep_time, sched_dep_time and dep_delay. Are they consistent? Explain your findings.
flights_dt %>% 
  mutate(cal_delay = as.numeric(dep_time - sched_dep_time) / 60) %>% 
  filter(dep_delay != cal_delay) %>% 
  select(dep_delay, cal_delay, everything())

flights_dt %>% 
  mutate(cal_delay = as.numeric(dep_time - sched_dep_time) / 60) %>% 
  filter(dep_delay != cal_delay) %>% 
  select(dep_delay, cal_delay, everything()) %>% 
  mutate(
    dep_time = update(dep_time, mday = mday(dep_time) + 1),
    cal_delay = as.numeric(dep_time - sched_dep_time)
  ) %>% 
  filter(dep_delay != cal_delay)

# 3. Compare air_time with the duratin between the departure and arrival. Explain you findings.
#    (Hint: consider the location of the airport.)
flights_dt %>% 
  mutate(cal_air_time = as.numeric(arr_time - dep_time)) %>% 
  select(contains("air"))

flights_dt %>% 
  left_join(airports, by = c("origin" = "faa")) %>% 
  left_join(airports, by = c("dest" = "faa"), suffix = c(".origin", ".dest")) %>% 
  select(dep_time, arr_time, air_time, contains('tzone'))

# 4. How does the average delay time change over the course of a day? Should you use dep_time or sched_dep_time? Why?
flights_dt %>% 
  mutate(hour = hour(sched_dep_time)) %>% 
  group_by(hour) %>% 
  summarize(
    avg_dep_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) %>% 
  ggplot(aes(hour, avg_dep_delay)) + 
  geom_smooth(se = FALSE) + 
  geom_point()

# 5. On what day of the week should you leave if you want to minimise the chance of a delay?
flights_dt %>% 
  mutate(wday = wday(sched_dep_time, label = TRUE)) %>% 
  group_by(wday) %>% 
  summarise(
    avg_dep_delay = mean(dep_delay, na.rm = TRUE),
    avg_arr_delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  gather(key = "delay", value = "minutes", 2:3) %>% 
  ggplot() + 
  geom_col(aes(wday, minutes, fill = delay), position = "dodge")

## Saturday

# 6. What makes the distribution of diamonds$carat and flights$sched_dep_time similar?
diamonds %>% 
  ggplot() + 
  geom_freqpoly(aes(carat), binwidth = .01)

flights_dt %>% 
  mutate(minutes = minute(sched_dep_time)) %>% 
  ggplot(aes(minutes)) + 
  geom_freqpoly(binwidth = 1)

# 7. Confirm my hypothesis that the early departures of flights in minutes 20-30 and 50-60 are caused by scheduled flights that leave early.
#    Hint: create a binary variable that tells you whether or not a flight was delayed.
flights_dt %>% 
  mutate(
    delayed = dep_delay > 0,
    minutes = minute(sched_dep_time) %/% 10 * 10,
    minutes = factor(minutes, levels = c(0, 10, 20, 30, 40, 50))
  ) %>% 
  group_by(minutes) %>% 
  summarise(prop_early = 1 - mean(delayed, na.rm = TRUE)) %>% 
  ggplot(aes(minutes, prop_early)) + 
  geom_point()

# 16.4 Time spans

# Next you'll learn about how arithmetic with dates works, including subtraction, addition, and division.
# Along the way, you'll learn about three important classes that represent time spans:

# 1. durations, which represent an exact number of seconds.
# 2. periods, which represent human unites like weeks and months.
# 3. intervals, which represent a starting and ending point.

# 16.4.1 Durations

# In R, when you subtract two dates, you get a difftime object:
# How old is Hadley?
h_age <- today() - ymd(19791014)
h_age

# A difftime class object records a time span of seconds, minutes, hours, days, or weeks.
# This ambiguity can make difftimes a little painful to work with, so lubridate provides an alternative
# which always uses seconds: the duration.
as.duration(h_age)

# Durations come with a bunch of convenient constructors:
dseconds(15)
dminutes(10)
dhours(c(12, 24))
ddays(0:5)
dweeks(3)
dyears(1)

# Durations always record the time span in seconds.
# Larger units are created by converting minutes, hours, days, weeks, and years to seconds at the standard rate
# (60 seconds in a minute, 60 minutes in an hour, 24 hours in day, 7 days in a week, 365 days in a year).

# You can add and multiply durations:
2 * dyears(1)

dyears(1) + dweeks(12) + dhours(15)

# You can add and subtract durations to and from days:
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)

# However, because durations represent an exact number of seconds, sometimes you might get an unexpected result:
one_pm <- ymd_hms("2016-03-12 13:00:00", tz ="America/New_York")
one_pm + ddays(1)

# Why is one day after 1pm on March 12, 2pm on March 13?! 
# If you look carefully at the date you might also notice that the time zones have changed. 
# Because of DST, March 12 only has 23 hours, so if we add a full days worth of seconds we end up with a different time.

# 16.4.2 Periods

# To solve this problem, lubridate provides periods. Periods are time spans but don't have a fixed length in seconds, 
# instead they work with "human" times, like days and months. That allows them work in a more intuitive way:
one_pm
one_pm + days(1)

# Like durations, periods can be created with a number of friendly constructor functions.
seconds(15)
minutes(10)
hours(c(12, 24))
days(7)
months(1:6)
weeks(3)
years(1)

# You can add and multiply periods:
10 * (months(6) + days(1))

days(50) + hours(25) + minutes(2)

# And of course, add them to dates. Compared to durations, periods are more likely to do what you expect:
# A leap year
ymd("2016-01-01") + dyears(1)
ymd("2016-01-01") + years(1)

# Daylight Savings Time
one_pm + ddays(1)
one_pm + days(1)

# Let's use periods to fix an oddity related to our flight dates.
# Somw planes appear to have arrived at their destination before they departed from New York City.
flights_dt %>% 
  filter(arr_time < dep_time)

# These are overnight flights. We used the same date information for both the departure and the arrival times, 
# but these flights arrived on the following day. We can dix this by adding days(1) to the arrival time of each overnight flight.
flights_dt <- flights_dt %>% 
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight * 1),
    sched_arr_time = sched_arr_time + days(overnight * 1)
  ) 

# Now all of our flights obey the laws of physics.
flights_dt %>% 
  filter(overnight, arr_time < dep_time)

# 16.4.3 Intervals

# It's obvious what dyears(1) / ddays(365) should return: one, because duration are always represented by a number of seconds,
# and a duration of a year is defined as 365 days worth of seconds.
dyears(1) / ddays(1)

# What should years(1) / days(1) return? Well, if the year was 2015 it shuld return 365, but if it was 2016, it should return 366!
# There's not quite enough information for lubuidate to give a single clear answer. What it does instead is give an estimate, with a warning:
years(1) / days(1) ## estimate only: convert to intervals for accuracy

# If you want a accurate measurement, you'll have to use an interval. An interval is a duration with a starting point: 
# that makes it precise so you can determin exactly how long it is:
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)

# To find out how many periods fall into an interval, you need to use inteeger division:
(today() %--% next_year) %/% days(1)

# 16.4.4 Summary

# How do you pick between duration, periods, and intercals? As always, pick the simplest data structure that solves your problem.
# If you moly care about physical time, use a duration; if you need to add human times, use a period; 
# if you need to figure ou how long a span is in human unites, use an intercal.

# 16.4.5 Exercises

# 1. Why is there months() but no dmonths()?
## Because month did't have a fixed number in seconds. There are 29, 30, 31 days in different month.

# 2. Explain days(overnight * 1) to someone who has just started learning R. How does it work?
## Because the variable: overnight is logical testing, if true, then the values will be 1; vice versa, the value will be 0.
## So, if overnight is false: days(overnight * 1) == 0, and the value won't change.

# 3. Create a vector of dates giving the first day of every month in 2015. 
#    Create a vector of dates giving the first day of every month in the current year.
## (1)
seq(ymd('2015-01-01'), ymd('2015-12-01'), 'month')
ymd(20150101) + months(0:11)

# (2)
make_date(year(today()), 1, 1) + months(0:11)
update(today(), month = 1, day = 1) + months(0:11) 
floor_date(today(), 'year') + month(0:11)

# 4. Write a funciton that given your birthday (as a date), returns how old you are in years.
count_age <- function(birth_day) {
  year <- (ymd(birth_day) %--% today()) %/% years(1)
  return(str_c("You're ", year, " years old"))
}

count_age(19920808)

# 5. Why can't (today() %--% (today() + years(1)) / months(1) work?
## missing the parentheses
(today() %--% (today() + years(1)) / months(1))
(today() %--% (today() + years(1)) / days(30))

# 16.5 Time zones

# Time zones are an enormously complicated topic because of their interaction with geopolitical entities.
# Fortunately we don't need to dig into all the details as they're not all important for data analysis, 
# but there are a few challengs we'll need to tackle head on.

# The first challenge is that everyday names of time zones tend to be ambiguous. For example, if you're American you 're probably familiar with EST, 
# or Eastern Standard Time. However, both Australia and Canada also have EST! To avoid confusion, R uses the international standard IANA time zones.
# These use a consistent naming scheme "/", typically in th form "<continent>/<city>" (there are a few exctoptions because not every country lies on a continent).
# Examples include "America/New_York", "Europe/Paris", and "Pacific/Auckland".

# You might wonder why the zone uses a city, when typically you think of time zones as associated with a country or region within a country.
# This is because the IANA database has to record decades worth of time zone relus. In the course of decades, countries change names (or bread apart) fairly frequently, 
# but city names tend to stay the same. Another problem is that name needs to reflect not only to the current behaviour, but also the complete history.
# For example, there are time zones for both "America/New_York" and "America/Detroit".
# These cities both currently use Eastern Standard Time but in 1969-1972 Michigan (the state in which Detroit is located), did not follow DST,
# so it needs a different name. It's worth reading the raw time zone datebase(available at http://www.iana.org/time-zones) just to read come of these stories!

# You can find out what R thinks your current time zone is with Sys.timezone():
Sys.timezone()
# (If R doesn't know, you'll get an NA.)

# And see the complite list of all time zone names with OlsonNames():
length(OlsonNames())
head(OlsonNames())

# In R, the time zone is an attribute of the date-time that only controls printing. For example, these three objects represent the same instant in time:
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))

# You can verify that they're the same time using substraction:
x1 - x2
x1 - x3

# Unless otherwise specified, lubridate always uses UTC. UTC (Coordinated Universal Time) is the standard time zone
# use by the scientific community and roughly equivalent to its predecessor GMT (Greenwich Mean Time).
# It does not have DST, which makes a convenient representation for computation. Operations that combine date-times,
# like c(), will often drop the time zone. In the case, the date-times will display in your local time zone:
x4 <- c(x1, x2, x3)
x4

# You can change the time zone in two ways:
# 1. Keep the instant in time the same, and change how it's displayed. Use this when the instant is correct, but you wnat a more natural display.
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a

x4a - x4
# (This also illustrates another challenge of times zones: they’re not all integer hour offsets!)

# 2. Change the underlying instant in time. 
#    Use this when you have an instant that has been labelled with the incorrect time zone, and you need to fix it.
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b

x4b - x4
