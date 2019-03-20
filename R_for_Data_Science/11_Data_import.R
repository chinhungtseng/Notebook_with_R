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