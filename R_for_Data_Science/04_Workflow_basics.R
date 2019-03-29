# 4 Workfolw: basics
# https://r4ds.had.co.nz/workflow-basics.html

# 4.1 Coding basics
## calculator
1 / 200 * 30

(59 + 73 + 2) / 3

sin(pi / 2)

## Create new objects with <-:
## object_name <- value
## assignment operator's short cut: " Alt + - "
x <- 3 * 4

# 4.2 What's in a name?
## Object names must start with a letter, 
## and can only contain letters, numbers, _ and .
## If you want to have a descriptive variable's name, 
## this book recommand separate lowercase words with _ .
## e.g: i_use_snake_case, And_aFew.People_RENOUNCEconvention

this_is_a_really_long_name <- 2.5

# 4.3 Calling functions
## function_name(arg1 = val1, arg2 = val2, ...)
seq(1, 10)

y <- seq(1, 10, length.out = 5)
## This common action can be shortened by surrounding the assignment with parentheses, 
## which causes assignment and “print to screen” to happen.
(y <- seq(1, 10, length.out = 5))

# 4.4 Practice
# 1. Why does this code not work?
my_variable <- 10
my_varıable
#> Error in eval(expr, envir, enclos): object 'my_varıable' not found

## not my_var ı able, instead is my_var i able.

# 2. Tweak each of the following R commands so that they run correctly:
library(tidyverse)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

fliter(mpg, cyl = 8)
filter(diamond, carat > 3)

## filter(mpg, cyl == 8)
## filter(diamonds, carat > 3)

# 3. Press Alt + Shift + K. What happens? 
# How can you get to the same place using the menus?
## In the tool bar, help > keyboard shortcuts help