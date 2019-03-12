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
args(locale)
?locale
## The most important arguments is :
## 1. decimal_mark (Symbols used to indicate the decimal place.)
## 2. grouping_mark ()
## 3. encoding (readr always converts the output to UTF-8.)

# 2. What happens if you try and set decimal_mark and grouping_mark to the same character? 
#    What happens to the default value of grouping_mark when you set decimal_mark to “,”? 
#    What happens to the default value of decimal_mark when you set the grouping_mark to “.”?
parse_number("123,456,789", locale = locale(grouping_mark = ','))
parse_number("123,456,789", locale = locale(grouping_mark = '.'))
parse_number("123.456.789", locale = locale(grouping_mark = ','))

parse_number("123.456.789", locale = locale(decimal_mark = '.', grouping_mark = '.'))
## Error: `decimal_mark` and `grouping_mark` must be different

# 3. I didn’t discuss the date_format and time_format options to locale(). 
#    What do they do? Construct an example that shows when they might be useful.
?parse_date
args(parse_date)

parse_date("01/05/2018", "%d/%m/%Y")
parse_date("01/05/2018", locale = locale(date_format = "%d/%m/%Y"))
## The locale controls defaults that vary from place to place. The default locale is US-centric (like R), 
## but you can use locale() to create your own locale that controls things like the default time zone, 
## encoding, decimal mark, big mark, and day/month names.

# 4. If you live outside the US, create a new locale object that encapsulates 
#    the settings for the types of file you read most commonly.
?locale

parse_date("01/05/2018", locale = locale(date_format = "%d/%m/%Y", date_names = 'uk'))


# 5. What’s the difference between read_csv() and read_csv2()?
?read_csv2
## read_csv() is comma delimited. read_csv2() is semi-colon delimited.

# 6. What are the most common encodings used in Europe? 
#    What are the most common encodings used in Asia? Do some googling to find out.

## https://en.wikipedia.org/wiki/Character_encoding

# 7. Generate the correct format string to parse each of the following dates and times:
d1 <- "January 1, 2010"
parse_date(d1, '%B %d, %Y')

d2 <- "2015-Mar-07"
parse_date(d2, '%Y-%b-%d')

d3 <- "06-Jun-2017"
parse_date(d3, '%d-%b-%Y')

d4 <- c("August 19 (2015)", "July 1 (2015)")
parse_date(d4, '%B %d (%Y)')

d5 <- "12/30/14" # Dec 30, 2014
parse_date(d5, '%m/%d/%y')

t1 <- "1705"
parse_time(t1, '%H%M')

t2 <- "11:15:10.12 PM"
parse_time(t2, '%H:%M:%OS %p')

# 11.4 Parsing a file

# 1. How readr automatically guesses the type of each column.
# 2. How to override the default specification.

# 11.4.1 Strategy
# readr uses a heuristic to figure out the type of each column: 
# it reads the first 1000 rows and uses some (moderately conservative) heuristics to figure out the type of each column. 
# You can emulate this process with a character vector using guess_parser(), 
# which returns readr’s best guess, and parse_guess() which uses that guess to parse the column:
guess_parser('2010-10-01')
guess_parser('15:01')
guess_parser(c('TRUE', 'FALSE'))
guess_parser(c('1', '5', '9'))
guess_parser(c('12,352,561'))
str(parse_guess('2010-10-10'))

?parse_guess()
# parse_guess() returns the parser vector;
# guess_parser() returns the name of the parser. 

# The heuristic tries each of the following types, stopping when it finds a match:
# 1. logical: contains only “F”, “T”, “FALSE”, or “TRUE”.
# 2. integer: contains only numeric characters (and -).
# 3. double: contains only valid doubles (including numbers like 4.5e-5).
# 4. number: contains valid doubles with the grouping mark inside.
# 5. time: matches the default time_format.
# 6. date: matches the default date_format.
# 7. date-time: any ISO8601 date.
# If none of these rules apply, then the column will stay as a vector of strings.

# 11.4.2 Problems

# These defaults don’t always work for larger files. There are two basic problems:
# 1. The first thousand rows might be a special case, and readr guesses a type that is not sufficiently general. 
#    For example, you might have a column of doubles that only contains integers in the first 1000 rows.

# 2. The column might contain a lot of missing values. If the first 1000 rows contain only NAs, 
#    readr will guess that it’s a character vector, whereas you probably want to parse it as something more specific.

# readr contains a challenging CSV that illustrates both of these problems:
challenge <- read_csv(readr_example('challenge.csv'))

problems(challenge)

challenge <- read_csv(
  readr_example('challenge.csv'),
  col_type = cols(
    x = col_integer(),
    y = col_character()
  )
)

# Then you can tweak the type of the x column:
challenge <- read_csv(
  readr_example('challenge.csv'),
  col_types = cols(
    x = col_double(),
    y = col_character()
  )
)

# That fixes the first problem, but if we look at the last few rows, 
# you’ll see that they’re dates stored in a character vector:
tail(challenge)

# You can fix that by specifying that y is a date column:
challenge <- read_csv(
  readr_example('challenge.csv'),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

tail(challenge)

# Every parse_xyz() function has a corresponding col_xyz() function. 
# You use parse_xyz() when the data is in a character vector in R already; 
# you use col_xyz() when you want to tell readr how to load the data.

# I highly recommend always supplying col_types, building up from the print-out provided by readr. 
# This ensures that you have a consistent and reproducible data import script. 
# If you rely on the default guesses and your data changes, readr will continue to read it in. 
# If you want to be really strict, use stop_for_problems(): 
# that will throw an error and stop your script if there are any parsing problems.

# 11.4.3 Other strategies
# There are a few other general strategies to help you parse files:

# 1. In the previous example, we just got unlucky: if we look at just one more row than the default, 
#    we can correctly parse in one shot:
challenge2 <- read_csv(readr_example('challenge.csv'), guess_max = 1001)
challenge2

# 2. Sometimes it’s easier to diagnose problems if you just read in all the columns as character vectors:
challenge2 <- read_csv(readr_example('challenge.csv'), 
                       col_types = cols(.default = col_character()))

# This is particularly useful in conjunction with type_convert(), 
# which applies the parsing heuristics to the character columns in a data frame.
df <- tribble(
  ~x,  ~y,
  "1", "1.21",
  "2", "2.32",
  "3", "4.56"
)
df

type_convert(df)

# 3. If you’re reading a very large file, you might want to set n_max to a smallish number 
#    like 10,000 or 100,000. That will accelerate your iterations while you eliminate common problems.

# 4. If you’re having major parsing problems, sometimes it’s easier to just read into a character vector of lines with read_lines(), 
#    or even a character vector of length 1 with read_file(). 
#    Then you can use the string parsing skills you’ll learn later to parse more exotic formats.

# 11.5 Writing to a file

# readr also comes with two useful functions for writing data back to disk: write_csv() and write_tsv(). 
# Both functions increase the chances of the output file being read back in correctly by:
# 1. Always encoding strings in UTF-8.
# 2. Saving dates and date-times in ISO8601 format so they are easily parsed elsewhere.

# If you want to export a csv file to Excel, use write_excel_csv() — this writes a special character 
# (a “byte order mark”) at the start of the file which tells Excel that you’re using the UTF-8 encoding.

# The most important arguments are x (the data frame to save), and path (the location to save it). 
# You can also specify how missing values are written with na, and if you want to append to an existing file.
write_csv(challenge, 'data/challenge.csv')

# Note that the type information is lost when you save to csv:
challenge

write_csv(challenge, 'data/challenge-2.csv')
read_csv('data/challenge-2.csv')

# This makes CSVs a little unreliable for caching interim results—you need to recreate
# the column specification every time you load in. There are two alternatives:

# 1. write_rds() and read_rds() are uniform wrappers around the base functions readRDS() and saveRDS(). 
#    These store data in R’s custom binary format called RDS:
write_rds(challenge, 'data/challenge.rds')
read_rds('data/challenge.rds')

# 2. The feather package implements a fast binary file format that can be shared across programming languages:
if(!require(feather)) install.packages('feather')
library(feather)

write_feather(challenge, 'data/challenge.feather')
read_feather('data/challenge.feather')
# Feather tends to be faster than RDS and is usable outside of R. RDS supports list-columns 
# (which you’ll learn about in many models); feather currently does not.

# 11.6 Other types of data
# To get other types of data into R, we recommend starting with the tidyverse packages listed below. 
# They’re certainly not perfect, but they are a good place to start. For rectangular data:
# 1. haven reads SPSS, Stata, and SAS files.
# 2. readxl reads excel files (both .xls and .xlsx).
# 3. DBI, along with a database specific backend (e.g. RMySQL, RSQLite, RPostgreSQL etc) 
#    allows you to run SQL queries against a database and return a data frame.

# For hierarchical data: use jsonlite (by Jeroen Ooms) for json, and xml2 for XML. 
# Jenny Bryan has some excellent worked examples at https://jennybc.github.io/purrr-tutorial/.

# For other file types, try the R data import/export manual and the rio package.
# Read more: 
# 1. https://cran.r-project.org/doc/manuals/r-release/R-data.html
# 2. https://github.com/leeper/rio

# --------------------------------------------------------------------------------------------------
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
  extract(rate,'cases')

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

# --------------------------------------------------------------------------------------------------
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

# --------------------------------------------------------------------------------------------------
# Strings

# 14.1 Introduction
# This chapter introduces you to string manipulation in R. 
# You’ll learn the basics of how strings work and how to create them by hand, 
# but the focus of this chapter will be on regular expressions, or regexps for short. 
# Regular expressions are useful because strings usually contain unstructured or semi-structured data,
# and regexps are a concise language for describing patterns in strings. 
# When you first look at a regexp, you’ll think a cat walked across your keyboard, 
# but as your understanding improves they will soon start to make sense.

# 14.1.1 Prerequisites
# This chapter will focus on the stringr package for string manipulation. 
# stringr is not part of the core tidyverse because you don’t always have textual data, 
# so we need to load it explicitly.
library(tidyverse)
library(stringr)

# 14.2 String basics
# You can create strings with either single quotes or double quotes. 
# Unlike other languages, there is no difference in behaviour. 
# I recommend always using ", unless you want to create a string that contains multiple ".
string1 <- "This is a string"
string2 <- 'If I want to include "quote" inside a string, I use single quotes'

# If you forget to close a quote, you’ll see +, the continuation character:
# "This is a string without a closing quote
# > "This is a string without a closing quote
# + 
# + 

# If this happen to you, press Escape and try again!
# To include a literal single or double quote in a string you can use \ to “escape” it:
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"

# That means if you want to include a literal backslash, you’ll need to double it up: "\\".

# Beware that the printed representation of a string is not the same as string itself,
# because the printed representation shows the escapes.
# To see the raw contents of the string, use writeLines():
x <- c("\"", "\\")
x

writeLines(x)

# There are a handful of other special characters. 
# The most common are "\n", newline, and "\t", tab, 
# but you can see the complete list by requesting help on ": ?'"', or ?"'". 
# You’ll also sometimes see strings like "\u00b5", 
# this is a way of writing non-English characters that works on all platforms:

# Multiple strings are often stored in a character vector, which you can create with c():
c("one", "two", "there")

# 14.2.1 String length

# Base R contains many functions to work with strings but we’ll avoid them because they can be inconsistent, 
# which makes them hard to remember. Instead we’ll use functions from stringr. 
# These have more intuitive names, and all start with str_. 
# For example, str_length() tells you the number of characters in a string:

str_length(c("a", "R for data science", NA))

# The common str_ prefix is particularly useful if you use RStudio, 
# because typing str_ will trigger autocomplete, allowing you to see all stringr functions:

# 14.2.2 Combining strings

# To combine two or more strings, use str_c():

str_c("x", "y")

str_c("x", "y", "z")

# Use the sep argument to control how they’re separated:
str_c("x", "y", sep = ",")

# Like most other functions in R, missing values are contagious. 
# If you want them to print as "NA", use str_replace_na():
x <- c("abc", NA)
str_c("|-", x, "-|")

str_c("|-", str_replace_na(x), "-|")

# As shown above, str_c() is vectorised, 
# and it automatically recycles shorter vectors to the same length as the longest
str_c("prefix-", c("a", "b", "c"), "-suffix")

# Objects of length 0 are silently dropped. This is particularly useful in conjunction with if:
name <- "Hdley"
time_of_day <- "morning"
birthday <- FALSE

str_c(
  "Good ", time_of_day, " ", name, 
  if(birthday) " and HAPPY BIRTHDAY",
  "."
)

# To collapse a vector of strings into a single string, use collapse:
str_c(c("x", "y", "z"), collapse = ", ")

# 14.2.3 Subsetting strings

# You can extract parts of a string using str_sub(). 
# As well as the string, str_sub() takes start and end arguments
# which give the (inclusive) position of the substring:

x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)

str_sub(x, -3, -1)

# Note that str_sub() won’t fail if the string is too short: 
# it will just return as much as possible:
str_sub("a", 1, 5)

# You can also use the assignment form of str_sub() to modify strings:
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))

# 14.2.4 Locales

# Above I used str_to_lower() to change the text to lower case. 
# You can also use str_to_upper() or str_to_title(). 
# However, changing case is more complicated than it might at first appear 
# because different languages have different rules for changing case. 
# You can pick which set of rules to use by specifying a locale:
str_to_upper(c("i", "ı"))

str_to_upper(c("i", 'ı'), locale = "tr")

# The locale is specified as a ISO 639 language code, which is a two or three letter abbreviation. 
# If you don’t already know the code for your language, Wikipedia has a good list. 
# If you leave the locale blank, it will use the current locale, as provided by your operating system.

# Another important operation that’s affected by the locale is sorting. 
# The base R order() and sort() functions sort strings using the current locale. 
# If you want robust behaviour across different computers, you may want to use str_sort() and str_order() 
# which take an additional locale argument:
x <- c("apple", "eggplant", "banana")

str_sort(x, locale = "en") # Englich
str_sort(x, locale = "haw") # Hawaiian

# 14.2.5 Exercises
# 1. In code that doesn’t use stringr, you’ll often see paste() and paste0(). 
#    What’s the difference between the two functions? 
#    What stringr function are they equivalent to? 
#    How do the functions differ in their handling of NA?
?paste()
## paste0(..., collapse) is equivalent to paste(..., sep = "", collapse), slightly more efficiently.
x <- c("abc", NA)

## paste() will auto coerces NA to string of NA.
paste0("|-", x, "-|") 

## But str_c() need to add str_replace_na() function to coerces NA.
str_c("|-", str_replace_na(x) , "-|") 

# 2. In your own words, describe the difference between the sep and collapse arguments to str_c().

## sep: String to insert between input vectors.
## collapse: Combine input vectors into single string.

# 3. Use str_length() and str_sub() to extract the middle character from a string. 
#   What will you do if the string has an even number of characters?
test <- c("a", "ab", "abc", "abcd", "abcde")

test %>% str_sub(ceiling(str_length(.) / 2), ceiling(str_length(.) / 2))

ifelse(
  str_length(test) %% 2 == 1,
  str_sub(test, ceiling(str_length(test) / 2), ceiling(str_length(test) / 2)), 
  str_sub(test, ceiling(str_length(test) / 2) + 1, ceiling(str_length(test) / 2) + 1))

# 4. What does str_wrap() do? When might you want to use it?
?str_wrap
## str_wrap() function will Wrap strings into nicely formatted paragraphs.
test <- "별이 둥실 떠오른다\n
너도 함께 떠오른다\n
두 손을 휘이 젖고\n
다시 또 저어도\n
그대는 계속 떠오르죠\n
눈물이 툭 떨어진다\n
들킬까 닦아버린다\n
그대는 왜 이리 모질게 아픈가요\n
나의 마음에 이렇게도\n
멀리 저 멀리 들려오네요\n
그대 숨소리 그대의 목소리\n
꿈에서도 아픈 그대의 소리\n
구름따라서 바람따라서\n
매일 걸으면\n
혹시나 보일까\n
너의 그 아름다운\n
웃음"

cat(str_wrap(test, width = 40))

# 5. What does str_trim() do? What’s the opposite of str_trim()?
?str_trim
## str_trim() function will removes whitespace from start and end of string.

test <- " abcdefg "
str_trim(test) # This will trim the space from right side and left side.
str_trim(test, side = "left")

# 6. Write a function that turns (e.g.) a vector c("a", "b", "c") into the string a, b, and c. 
#    Think carefully about what it should do if given a vector of length 0, 1, or 2.
test <- c("a", "b", "c")
for (i in test){print(i)}

str_c(test, sep = "")

# 14.3 Matching patterns with regular expressions

# Regexps are a very terse language that allow you to describe patterns in strings. 
# They take a little while to get your head around, but once you understand them, 
# you’ll find them extremely useful.

# To learn regular expressions, we’ll use str_view() and str_view_all(). 
# These functions take a character vector and a regular expression, and show you how they match.
# We’ll start with very simple regular expressions and then gradually get more and more complicated. 
# Once you’ve mastered pattern matching, 
# you’ll learn how to apply those ideas with various stringr functions.

# 14.3.1 Basic matches

# The simplest patterns match exact strings:
x <- c("apple", "banana", "pear")
str_view(x, "an")

# The next step up in complexity is ., which matches any character (except a newline):
str_view(x, ".a.")

# But if “.” matches any character, how do you match the character “.”? 
# You need to use an “escape” to tell the regular expression you want to match it exactly, 
# not use its special behaviour. Like strings, regexps use the backslash, \, to escape special behaviour.
# So to match an ., you need the regexp \.. 
# Unfortunately this creates a problem. We use strings to represent regular expressions,
# and \ is also used as an escape symbol in strings. 
# So to create the regular expression \. we need the string "\\.".

## To create the regular expression, we need \\
dot <- "\\."

## But the expression itself only contains one:
writeLines(dot)

## And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a\\.c")

# If \ is used as an escape character in regular expressions, how do you match a literal \? 
# Well you need to escape it, creating the regular expression \\.
# To create that regular expression, you need to use a string, which also needs to escape \. 
# That means to match a literal \ you need to write "\\\\" — you need four backslashes to match one!
x <- "a\\b"
writeLines(x)

str_view(x, "\\\\")

# In this book, I’ll write regular expression as \. 
# and strings that represent the regular expression as "\\.".

# 14.3.1.1 Exercises
# 1. Explain why each of these strings don’t match a \: "\", "\\", "\\\".

x <- "a\\b"
# \: 
## str_view(x, "\")
## this case will escape last quote.

# \\:
str_view(x, "\\")
## if we want to find \ in string, we need to escape the \ in string and \ in regex, like: "\\\\"

# \\\:
## str_view(x, "\\\")

# 2. How would you match the sequence "'\?
x <- "\"\'\\"
cat(x)
str_view(x, "\\\"\\\'\\\\")

# 3. What patterns will the regular expression \..\..\.. match? 
#    How would you represent it as a string?
x <- c("a\\b\\c\\d", "aa\\bb\\cc\\dd")

str_view(x, "\\\\..\\\\..\\\\..")

# 14.3.2 Anchors

# By default, regular expressions will match any part of a string. 
# It’s often useful to anchor the regular expression so that it matches from the start
# or end of the string. You can use:

# 1. ^ to match the start of the string.
# 2. $ to match the end of the string.

x <- c("apple", "banana", "pear")
str_view(x, "^a")

str_view(x, "a$")

# To remember which is which, try this mnemonic which I learned from Evan Misshula: 
# if you begin with power (^), you end up with money ($).
# https://twitter.com/emisshula/status/323863393167613953

# To force a regular expression to only match a complete string, anchor it with both ^ and $:
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple") ## This will show all string that contains "apple"

str_view(x, "^apple$")

# You can also match the boundary between words with \b. 
# I don’t often use this in R, but I will sometimes use it when I’m doing a search in RStudio 
# when I want to find the name of a function that’s a component of other functions. 
# For example, I’ll search for \bsum\b to avoid matching summarise, summary, rowsum and so on.

# 14.3.2.1 Exercises

# 1. How would you match the literal string "$^$"?
x <- "$^$"
## use the escape sympol.
str_view(x, "\\$\\^\\$")

# 2. Given the corpus of common words in stringr::words, 
#    create regular expressions that find all words that:
#    (1) Start with “y”.
#    (2) End with “x”
#    (3) Are exactly three letters long. (Don’t cheat by using str_length()!)
#    (4) Have seven letters or more.
# Since this list is long, you might want to use the match argument 
# to str_view() to show only the matching or non-matching words.
words <- stringr::words
## 1. 
str_view(words, "^y", match = TRUE)
words[str_sub(words, 1, 1) == "y"]

## 2. 
str_view(words, "x$", match = TRUE)
words[str_sub(words, str_length(words), str_length(words)) == "x"]

## 3. 
str_view(words, "^...$", match = TRUE)
words[str_length(words) == 3]

## 4. 
str_view(words, "^.......", match = TRUE)
words[str_length(words) >= 7]

# 14.3.3 Character classes and alternatives

# There are a number of special patterns that match more than one character. 
# You’ve already seen ., which matches any character apart from a newline. 
# There are four other useful tools:

# 1. \d: matches any digit.
# 2. \s: matches any whitespace (e.g. space, tab, newline).
# 3. [abc]: matches a, b, or c.
# 4. [^abc]: matches anything except a, b, or c.

# Remember, to create a regular expression containing \d or \s, 
# you’ll need to escape the \ for the string, so you’ll type "\\d" or "\\s".

# A character class containing a single character is a nice alternative to backslash escapes
# when you want to include a single metacharacter in a regex. 
# Many people find this more readable.

# Look for a literal character that normally has special meaning in a regex
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]c")

str_view(c("abc", "a.c", "a*c", "a c"), ".[*]c")

str_view(c("abc", "a.c", "a*c", "a c"), ".[ ]c")

# This works for most (but not all) regex metacharacters: $ . | ? * + ( ) [ {. 
# Unfortunately, a few characters have special meaning even inside a character class 
# and must be handled with backslash escapes: ] \ ^ and -.
str_view(c("a-c", "a]c", "a^c"), "a[\\^]c")

# You can use alternation to pick between one or more alternative patterns. 
# For example, abc|d..f will match either ‘“abc”’, or "deaf". 
# Note that the precedence for | is low, so that abc|xyz matches abc or xyz not abcyz or abxyz. 
# Like with mathematical expressions, if precedence ever gets confusing, use parentheses to make it clear what you want:
str_view(c("grey", "gray"), "gr(e|a)y")

# 14.3.3.1 Exercises
# 1. Create regular expressions to find all words that:
#    (1) Start with a vowel.
#    (2) That only contain consonants. (Hint: thinking about matching “not”-vowels.)
#    (3) End with ed, but not with eed.
#    (4) End with ing or ise.

## (1)
str_view(words, "^[aeiou]", match = TRUE)

## (2)
str_view(words, "^[^aeiou]*$", match = TRUE)

## (3)
str_view(words, "[^e]ed$", match = TRUE)

## (4)
str_view(words, "i(ng|se)$", match = TRUE)

# 2. Empirically verify the rule “i before e except after c”.
str_view(words, "([^c]|)ei", match = TRUE)

# 3. Is “q” always followed by a “u”?
str_view(words, "q[^u]", match = TRUE)
## yes.

# 4. Write a regular expression that matches a word if it’s probably written in British English, not American English.
## colour, color
str_view(c("colour", "color"), "colo(|u)r")

# 5. Create a regular expression that will match telephone numbers as commonly written in your country.
## (1) start with 09
## (2) 10 digits
phone_numbers <- c("0987654321", "091234rs78", "0988", "0123456789", "092a456789", "0987-654-321")
str_view(phone_numbers, "^09\\d\\d\\d\\d\\d\\d\\d\\d")
str_view(phone_numbers, "^09\\d{8}")
str_view(phone_numbers, "^09\\d{2}(|\\-)\\d{3}(|\\-)\\d{3}")

# 4.3.4 Repetition

# The next step up in power involves controlling how many times a pattern matches:
# 1. ?: 0 or 1
# 2. +: 1 or more
# 3. *: 0 or more

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"

str_view(x, "CC?")

str_view(x, "CC+")

str_view(x, "C[LX]+")

# Note that the precedence of these operators is high, 
# so you can write: colou?r to match either American or British spellings. 
# That means most uses will need parentheses, like bana(na)+.
str_view(c("color", "colour"), "colou?r")

# You can also specify the number of matches precisely:
# 1. {n}: exactly n
# 2. {n,}: n or more
# 3. {,m}: at most m
# 4. {n,m}: between n and m

str_view(x, "C{2}") # str_view(x, "CC)

str_view(x, "C{2,}") # str_view(x, "CC+)

str_view(x, "C{2,3}")

# By default these matches are “greedy”: they will match the longest string possible. 
# You can make them “lazy”, matching the shortest string possible by putting a ? after them. 
# This is an advanced feature of regular expressions, but it’s useful to know that it exists:

str_view(x, "C{2,3}?")

str_view(x, 'C[LX]+?')

# 14.3.4.1 Exercises

# 1. Describe the equivalents of ?, +, * in {m,n} form.
## (1)
str_view(c("colour", "color"), "colou?r")
str_view(c("colour", "color"), "colo(|u)r")

## (2)
str_view("aaabbbccc123", "b+")
str_view("aaabbbccc123", "b{1,}")

## (3) 
str_view("aaabbbccc123", "cc*")
str_view("aaabbbccc123", "cc{0,}")

## (4)
str_view("abbcccdddd123", "d{2,3}")
str_view("abbcccdddd123", "d{3}|d{2}")

# 2. Describe in words what these regular expressions match: 
#    (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)
#    (1) ^.*$
#    (2) "\\{.+\\}"
#    (3) \d{4}-\d{2}-\d{2}
#    (4) "\\\\{4}"

## (1) this will match all string with any length. start any charactor, any length of string, end with anything.
str_view(c("123", "ddd", "5tg", " ", ""), "^.*$")

## (2) this will match string with "{" + "at least one charactor" + "}".
str_view(c("abbcccdd123 {123}", "{}"), "\\{.+\\}")

## (3) this will match string with "4 digis" + "-" + "2 digits" + "-" + "2 digis"
str_view(c("1234-12-12", "1234 12 12", " 12341212", "1234+12+12"), "\\d{4}-\\d{2}-\\d{2}")

## (4) this will match string with 4 times "\"
str_view(c("\\", "\\\\", "\\\\\\", "\\\\\\\\"), "\\\\{4}")

# 3. Create regular expressions to find all words that:
#    (1) Start with three consonants.
#    (2) Have three or more vowels in a row.
#    (3) Have two or more vowel-consonant pairs in a row.

## (1) 
str_view(words, "^[^aeiou]{3}+", match = TRUE)
str_view(words, "^[^aeiou]{3,}", match = TRUE)

## (2) 
str_view(words, "[aeiou]{3,}", match = TRUE)

## (3) 
str_view(words, "([aeiou][^aeiou]){2,}", match = TRUE)

# 4. Solve the beginner regexp crosswords at https://regexcrossword.com/challenges/beginner.
## Tutorial done.
## Beginner done.
## Intermediate done.

# 14.3.5 Grouping and backreferences

# Earlier, you learned about parentheses as a way to disambiguate complex expressions. 
# Parentheses also create a numbered capturing group (number 1, 2 etc.). 
# A capturing group stores the part of the string matched by the part of 
# the regular expression inside the parentheses.
# You can refer to the same text as previously matched by a capturing group with backreferences, 
# like \1, \2 etc. For example, the following regular expression
# finds all fruits that have a repeated pair of letters.














# --------------------------------------------------------------------------------------------------
