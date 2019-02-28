## Wrangle: https://r4ds.had.co.nz/wrangle-intro.html

# 9 Introduction

# This part of the book proceeds as follows:
## 1. In tibbles, you’ll learn about the variant of the data frame that we use in this book: the tibble. 
##    You’ll learn what makes them different from regular data frames, and how you can construct them “by hand”.

## 2. In data import, you’ll learn how to get your data from disk and into R. We’ll focus on plain-text rectangular formats, 
##    but will give you pointers to packages that help with other types of data.

## 3. In tidy data, you’ll learn about tidy data, a consistent way of storing your data that makes transformation, 
##    visualisation, and modelling easier. You’ll learn the underlying principles, and how to get your data into a tidy form.

# Data wrangling also encompasses data transformation. 
# Now we’ll focus on new skills for three specific types of data you will frequently encounter in practice:
## 1. Relational data will give you tools for working with multiple interrelated datasets.
## 2. Strings will introduce regular expressions, a powerful tool for manipulating strings.
## 3. Factors are how R stores categorical data. 
## 4. Dates and times will give you the key tools for working with dates and date-times.

# --------------------------------------------------------------------------------------------------
# 10 Tibbles

# 10.1 Introduction
## Tibbles are data frames, but they tweak some older behaviours to make life a little easier. 

## Learn more
vignette("tibble")

# 10.1.1 Prerequisites
library(tidyverse)

# 10.2 Creating tibbles

# with as_tibble() function.
iris
as_tibble(iris)

# create a new tibble from individual vectors with tibble()
tibble(
  x = 1:5, 
  y = 1, # tibble() will automatically recycle inputs of length 1.
  z = x^2 + y # allows you to refer to variables that you just created.
)

# tibble() does much less than data.frame(): 
# 1. it never changes the type of the inputs 
#    (e.g. it never converts strings to factors!), it never changes the names of variables, 
# 2. and it never creates row names.

# It’s possible for a tibble to have column names that are not valid R variable names,
# aka non-syntactic names. 
tb <- tibble(
  `:)` = "smile", 
  ` ` = "space", 
  `2000` = "number"
)

# Another way to create a tibble is with tribble(), short for transposed tibble. 
# tribble() is customised for data entry in code: column headings are defined by formulas 
# (i.e. they start with ~), and entries are separated by commas
tribble(
  ~x, ~y, ~z, 
  #--|--|----
  "a", 2, 3.6, 
  "b", 1, 8.5
)
## recommand add a comment (the line starting with #), to make it really clear where the header is.

# 10.3 Tibbles vs. data.frame

# There are two main differences in the usage of a tibble vs. a classic data.frame: 
# printing and subsetting.

# 10.3.1 Printing
# Tibbles have a refined print method that shows only the first 10 rows, 
# and all the columns that fit on screen.
# In addition to its name, each column reports its type, a nice feature borrowed from str():
tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# Tibbles are designed so that you don’t accidentally overwhelm your console when you print large data frames. 
# But sometimes you need more output than the default display. There are a few options that can help.
package?tibble

# 1. explicitly print() the data frame and control the number of rows (n) 
#    and the width of the display. width = Inf will display all columns:

nycflights13::flights %>% 
  print(n = 10, width = Inf)

# 2. control the default print behaviour by setting options:
#    (1) options(tibble.print_max = n, tibble.print_min = m): if more than n rows, print only m rows. 
#        Use options(tibble.print_min = Inf) to always show all rows.
#    (2) Use options(tibble.width = Inf) to always print all columns, regardless of the width of the screen.

# 3. use RStudio’s built-in data viewer
nycflights13::flights %>% 
  View()

# 10.3.2 Subsetting

# pull out a single variable: $ and [[. 
# 1. [[ can extract by name or position; 
# 2. $ only extracts by name but is a little less typing

df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

# Extract by name
df$x
df[["x"]]

# Extract by position
df[[1]]

# To use these in a pipe, you’ll need to use the special placeholder .:
df %>% .$x

df %>% .[['x']]

# 10.4 Interacting with older code

# Some older functions don’t work with tibbles. If you encounter one of these functions, 
# use as.data.frame() to turn a tibble back to a data.frame:
class(as.data.frame(tb))

# The main reason that some older functions don’t work with tibble is the [ function.

# 10.5 Exercises
# 1. How can you tell if an object is a tibble? (Hint: try printing mtcars, 
#    which is a regular data frame).

mtcars
## tibble just print 10 rows in the console, and print the columns fit your console's width.
mtcars_tbl <- as_tibble(mtcars)
mtcars_tbl
## there are another different is that the tibble won't show the row names...

# 2. Compare and contrast the following operations on a data.frame and equivalent tibble. 
#    What is different? Why might the default data frame behaviours cause you frustration?

df <- data.frame(abc = 1, xyz = "a")
df$x
df[, "xyz"]
df[, c("abc", "xyz")]

str(df)
## data.frame will auto convert the string to factor property

# 3. If you have the name of a variable stored in an object, e.g. var <- "mpg", 
#    how can you extract the reference variable from a tibble?

var <- 'mpg'
mtcars[[var]]

# 4. Practice referring to non-syntactic names in the following data frame by:
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

#    1. Extracting the variable called 1.
annoying$`1`
annoying[[1]]

#    2. Plotting a scatterplot of 1 vs 2.
annoying %>% 
  ggplot(aes(`1`, `2`)) + 
    geom_point()

#    3. Creating a new column called 3 which is 2 divided by 1.
annoying$`3` <- annoying$`2` / annoying$`1`

annoying <- annoying %>% mutate(`3` = `2` / `1`)

#    4. Renaming the columns to one, two and three.
names(annoying) <- c('one', 'two', 'three')

annoying %>% rename(one = `1`, 
                    two = `2`, 
                    three = `3`)

# 5. What does tibble::enframe() do? When might you use it?
?enframe
## enframe() converts named atomic vectors or lists to one- or two-column data frames. 
## deframe() converts two-column data frames to a named vector or list, using the first column as name and the second column as value

enframe(1:3)
enframe(c(a = 5, b = 7))
enframe(list(one = 1, two = 2:3, three = 4:6))
deframe(enframe(1:3))
deframe(tibble(a = 1:3))
deframe(tibble(a = as.list(1:3)))

# 6. What option controls how many additional column names are printed at the footer of a tibble?
nycflights13::flights

# --------------------------------------------------------------------------------------------------
# 11 Data import

# 11.1 Introduction

# 11.1.1 Prerequisites
# learn how to load flat files in R with the readr package
library(tidyverse)

# 11.2 Getting started
# Most of readr’s functions are concerned with turning flat files into data frames:
# 1. read_csv() reads comma delimited files, read_csv2() reads semicolon separated files 
#    (common in countries where , is used as the decimal place), read_tsv() reads tab delimited files, 
#    and read_delim() reads in files with any delimiter.

# 2. read_fwf() reads fixed width files. You can specify fields either by their widths with fwf_widths() or 
#    their position with fwf_positions(). read_table() reads a common variation of fixed width files 
#    where columns are separated by white space.

# 3. read_log() reads Apache style log files. (But also check out webreadr which is built on top of read_log() 
#    and provides many more helpful tools.)

# The first argument to read_csv() is the most important: it’s the path to the file to read.
mtcars_tbl <- read_csv("data/mtcars.csv")

# You can also supply an inline csv file.
read_csv("a,b,c
1,2,3
4,5,6")


# There are two cases where you might want to tweak this behaviour:
# 1. Sometimes there are a few lines of metadata at the top of the file. 
#    You can use skip = n to skip the first n lines; or use comment = "#" to drop all lines that 
#    start with (e.g.) #.
read_csv("The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3", skip = 2)

read_csv("# A comment I want to skip
  x,y,z
  1,2,3", comment = "#")

# 2. The data might not have column names. You can use col_names = FALSE to tell read_csv() 
#    not to treat the first row as headings, and instead label them sequentially from X1 to Xn:
read_csv("1,2,3\n4,5,6", col_names = FALSE)

## pass col_names a character vector
read_csv("1,2,3\n4,5,6", col_names = c("x", "y", "z"))

## this specifies the value (or values) that are used to represent missing values in your file:
read_csv("a,b,c\n1,2,.", na = ".")

# 11.2.1 Compared to base R

# 1. They are typically much faster (~10x) than their base equivalents. 
# 2. They produce tibbles, they don’t convert character vectors to factors, use row names, or munge the column names. 
# 3. They are more reproducible.

# 11.2.2 Exercises

# 1. What function would you use to read a file where fields were separated with “|”?
?read_delim
args(read_delim)
read_delim("a|b|c\n1|2|3\n4|5|6", delim = '|')

# 2. Apart from file, skip, and comment, what other arguments do read_csv() and read_tsv() have in common?
args(read_csv)
args(read_tsv)

# 3. What are the most important arguments to read_fwf()?
?read_fwf()
args(read_fwf)
## col_positions

# 4. Sometimes strings in a CSV file contain commas. To prevent them from causing problems 
#    they need to be surrounded by a quoting character, like " or '. 
#    By convention, read_csv() assumes that the quoting character will be ",
#    and if you want to change it you’ll need to use read_delim() instead. 
#    What arguments do you need to specify to read the following text into a data frame?
read_csv("x,y\n1,'a,b'", quote = "'")  
  
# 5. Identify what is wrong with each of the following inline CSV files. What happens when you run the code?
read_csv("a,b\n1,2,3\n4,5,6")
read_csv("a,b,c\n1,2\n1,2,3,4")
read_csv("a,b\n\"1")
read_csv("a,b\n1,2\na,b")
read_csv("a;b\n1;3") # read_delim("a;b\n1;3", delim = ';')

# 11.3 Parsing a vector
# parse_*() functions take a character vector and return a more specialised vector
# like a logical, integer, or date:

str(parse_logical(c("TRUE", "FALSE", "NA")))

str(parse_integer(c('1', '2', '3')))

str(parse_date(c("2010-01-01", "1979-10-14")))

# Like all functions in the tidyverse, the parse_*() functions are uniform: 
# the first argument is a character vector to parse, and the na argument specifies
# which strings should be treated as missing:

parse_integer(c("1", "231", ".", "456"), na = ".")

# If parsing fails, you’ll get a warning:
x <- parse_integer(c("123", "345", "abc", "123.45"))

# And the failures will be missing in the output:
x

# If there are many parsing failures, you’ll need to use problems() to get the complete set. 
problems(x)

# Using parsers is mostly a matter of understanding what’s available and how they deal with different types of input. 
# 1. parse_logical() and parse_integer() parse logicals and integers respectively. 
# 2. parse_double() is a strict numeric parser, and parse_number() is a flexible numeric parser. 
# 3. parse_character()
# 4. parse_factor() create factors, the data structure that R uses to represent categorical variables with fixed and known values.
# 5. parse_datetime(), parse_date(), and parse_time() allow you to parse various date & time specifications. 
#    These are the most complicated because there are so many different ways of writing dates.

# 11.3.1 Numbers
# 1. People write numbers differently in different parts of the world. 
#    For example, some countries use . in between the integer and fractional 
#    parts of a real number, while others use ,.
# 2. Numbers are often surrounded by other characters that provide some context, like “$1000” or “10%”.
# 3. Numbers often contain “grouping” characters to make them easier to read, like “1,000,000”, 
#    and these grouping characters vary around the world.

# To address the first problem, readr has the notion of a “locale”, 
# an object that specifies parsing options that differ from place to place. 
# When parsing numbers, the most important option is the character you use for the decimal mark. 
# You can override the default value of . by creating a new locale and setting the decimal_mark argument:
parse_double('1.23')
parse_double('1,23', locale = locale(decimal_mark = ','))

# readr’s default locale is US-centric
# parse_number() addresses the second problem: 
# it ignores non-numeric characters before and after the number. 
# This is particularly useful for currencies and percentages, 
# but also works to extract numbers embedded in text.
?args(parse_number)

parse_number("$100")

parse_number("20%")

parse_number("It cost $123.45")

# The final problem is addressed by the combination of parse_number() and 
# the locale as parse_number() will ignore the “grouping mark”:

# # Used in America
parse_number("$123,456,789")

# Used in many parts of Europe
parse_number("$123.456.789", locale = locale(grouping_mark = '.'))

# Used in Switzerland
parse_number("$123'456'789", locale = locale(grouping_mark = "'"))

# 11.3.2 Strings
# parse_character()
# we can get at the underlying representation of a string using charToRaw():

charToRaw("Hadley")
# Each hexadecimal number represents a byte of information: 48 is H, 61 is a,
# and so on. The mapping from hexadecimal number to character is called the encoding, 
# and in this case the encoding is called ASCII. ASCII does a great job of representing English characters, 
# because it’s the American Standard Code for Information Interchange.

# readr uses UTF-8 everywhere: it assumes your data is UTF-8 encoded when you read it, 
# and always uses it when writing. This is a good default, but will fail for data produced by 
# older systems that don’t understand UTF-8.
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
x1
x2
# To fix the problem you need to specify the encoding in parse_character():
parse_character(x1, locale = locale(encoding = 'Latin1'))
parse_character(x2, locale = locale(encoding = 'Shift-JIS'))

# How do you find the correct encoding?
guess_encoding(charToRaw(x1))
guess_encoding(charToRaw(x2))
# The first argument to guess_encoding() can either be a path to a file, or,
# as in this case, a raw vector (useful if the strings are already in R).

# Learn more: http://kunststube.net/encoding/

# 11.3.3 Factors

# R uses factors to represent categorical variables that have a known set of possible values. 
# Give parse_factor() a vector of known levels to generate a warning whenever an unexpected value is present:
fruit <- c("apple", "banana")
parse_factor(c('apple', 'banana', 'bananana'), levels = fruit)

# 11.3.4 Dates, date-times, and times

# You pick between three parsers depending on whether you want a date (the number of days since 1970-01-01), 
# a date-time (the number of seconds since midnight 1970-01-01), or a time (the number of seconds since midnight). 

# 1. parse_datetime() expects an ISO8601 date-time. ISO8601 is an international standard in which 
#    the components of a date are organised from biggest to smallest: year, month, day, hour, minute, second.

parse_datetime("2010-10-01T2010")
## If time is omitted, it will be set to midnight
parse_datetime("20101001")
## read more: https://en.wikipedia.org/wiki/ISO_8601

# 2. parse_date() expects a four digit year, a - or /, the month, a - or /, then the day:
parse_date("2010-10-01")

# 3. parse_time() expects the hour, :, minutes, optionally : and seconds, and an optional am/pm specifier:
library(hms)
parse_time("01:10 pm")
parse_time("20:10:01")

# If these defaults don’t work for your data you can supply your own date-time format, built up of the following pieces:
# Year
## %Y (4 digits).
## %y (2 digits); 00-69 -> 2000-2069, 70-99 -> 1970-1999.

# Month
## %m (2 digits).
## %b (abbreviated name, like “Jan”).
## %B (full name, “January”).

# Day
## %d (2 digits).
## %e (optional leading space).

# Time
## %H 0-23 hour.
## %I 0-12, must be used with %p.
## %p AM/PM indicator.
## %M minutes.
## %S integer seconds.
## %OS real seconds.
## %Z Time zone (as name, e.g. America/Chicago). Beware of abbreviations: if you’re American, note that “EST” is a Canadian time zone that does not have daylight savings time. It is not Eastern Standard Time! We’ll come back to this time zones.
## %z (as offset from UTC, e.g. +0800).

# Non-digits
## %. skips one non-digit character.
## %* skips any number of non-digits.

# For example: 
parse_date("01/02/15", "%m/%d/%y")

parse_date("01/02/15", "%d/%m/%y")

parse_date("01/02/15", "%y/%m/%d")


# If you’re using %b or %B with non-English month names, you’ll need to set the lang argument to locale().
# See the list of built-in languages in date_names_langs(), or if your language is not already included, 
# create your own with date_names().
parse_date("1 Jan 2015", "%d %b %Y")

parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))

# 11.3.5 Exercises

# 1. What are the most important arguments to locale()?


# 2. What happens if you try and set decimal_mark and grouping_mark to the same character? 
#    What happens to the default value of grouping_mark when you set decimal_mark to “,”? 
#    What happens to the default value of decimal_mark when you set the grouping_mark to “.”?




# 3. I didn’t discuss the date_format and time_format options to locale(). 
#    What do they do? Construct an example that shows when they might be useful.






# 4. If you live outside the US, create a new locale object that encapsulates 
#    the settings for the types of file you read most commonly.







# 5. What’s the difference between read_csv() and read_csv2()?








# 6. What are the most common encodings used in Europe? 
#    What are the most common encodings used in Asia? Do some googling to find out.






# 7. Generate the correct format string to parse each of the following dates and times:
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014
t1 <- "1705"
t2 <- "11:15:10.12 PM"








# --------------------------------------------------------------------------------------------------