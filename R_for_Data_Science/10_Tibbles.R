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
