# 20 Vectors

# 20.1 Introduction

# So far this book has focussed on tibbles and packages that work with them. But as you start to write your own functions, and dig deeper into R,
# you need to learn about vectors, the objects that underline tibbles. If you've learned R in a more traditional way, you're probably already familiar with vectors,
# as most R resources start with vectors and work their way up to tibbles. I think it's better to start with tibbles because they're immediately userful, 
# and then work your way down to the underlying components.

# Vectors are particularly important as most of the functions you will write will work with vectors.
# It is possible to write functions that work with tibbles (like ggplot2, dplyr, and tidyr), but the tools you need to write such functions are currently
# idiosyncratic and immature. I am working on a better approach, https://github.com/hadley/lazyeval, but it will not be ready in time for the publication of the book.
# Even when complete, you'll still need to understand vectors, it'll just make it easier to write a user-friendly layer on top.

# 20.2 Prerequisites

# The focus of this chapter is on base R data structures, so isn't essential to load any packages.
# We'll however, use a handful of functions from the purrr package to avoid some inconsistensies in base R.
library(tidyverse)

# 20.2 Vector basics

# There are two types of vectors:
# 1. Atomic vectors, of which there are six types: logical, integer, double, charactor, complex, and raw.
#    Integer and double vectors are collectively know as nuberic vectors.
# 2. Lists, which are sometimes called recursive recursive vectors because lists can contain other lists.

# The chief difference between atomic vectors and lists is that atomic vectors are homegeneous, while lists can be heterogeneous.
# There's one other related object: NULL. NULL is often used to represent the absence of a vector
# (as opposed to NA which is used to represent the absence of a value in a vector).
# NULL typically behaves like a vector of length 0. Figure 20.1 summarises the interrelationships.

# Vectors
# ----------------------------------
# |                                |   NULL
# |  Atomic vectors                |
# |  --------------------          |
# |  |   logical        |          | 
# |  |                  |          |
# |  |    Numeric       |          |
# |  |   -------------  |          |
# |  |   |  Integer  |  |    List  |
# |  |   |           |  |          |
# |  |   |  Double   |  |          |
# |  |   -------------  |          |
# |  |                  |          |
# |  |   Character      |          |
# |  |                  |          |
# |  --------------------          |
# |                                |
# ----------------------------------
# Figure 20.1: The hierarchy of R's vector types

# Every vector has two key properties:
# 1. Its type, which you can determine with typeof().
typeof(letters)
typeof(1:10)

# 2. Its length, which you can determine with length().
x <- list("a", "b", 1:10)
length(x)

# Vectors can also contain arbitrary additional metadata in the form of attributes.
# These attributes are used to create augmented vectors which build on additional behaviour.
# There are three important types of argmented vector:
# 1. Factors are built on top of integer vectors.
# 2. Dates and date-times are built on top of numeric vectors.
# 3. Data frames and tibbles are built on top of lists.

# This chapter will introduce you to these important vectors from simplest to most complicated.
# You'll start with atomic vectors, then build up to lists, and finish off with augmented vectors.

# 20.3 Inportant types of atomic vecot 
# The four most important typees of atomic vector are logical, integer, double, and character.
# Raw and complex are rarely used during a data analysis, so I won't discuss them here.

# Logical vectors are the simplest type of atomic vector because they can take only three possible values:
# FALSE, TRUE, and NA. Logical vectors are usually constructed with comparison operators, as described in comparisons.
# You can also create them by hand with c():
1:10 %% 3 == 0
c(TRUE, TRUE, FALSE, FALSE)

# 20.3.2 Numeric 

# Integer and double vectors are known collectively as numeric vectors.
# In R, numbers are doubles by default. To make an integer, place an L after the number:
typeof(1)
typeof(1L)

1.5L

# The distinction between integers and doubles is not usually important, but there are two important differences that you should be aware of:
# 1. Doubles are approximations. Doubles represent floating point numbers that can not always be preciesely represented with a fixed amount of memory.
#    This means that you should consider all soubles to be approximations. 
#    For example, what is square of the square root of two?
x <- sqrt(2) ^ 2
x

x - 2

#    This behaviour is common when working with floating point numbers: most calculations include some approximation error.
#    Instead of comparing floating point numbers using ==, you should use dplyr::near() which allows for some numerical tolerance.

# 2. Integers have one special value: NA, while doubles have four: NA, NaN, Inf and -Inf.
#    All three special values NaN, Inf and -Inf can arise during division:
c(-1, 0, 1) / 0

# Avoid using == to check for these other special values.
# Instead use the helper functions is.finite(), is.infinite(), and is.nan():
# -------------------------------------------
#                  0    Inf    NA    NaN
# -------------------------------------------
# is.finite()      x
# -------------------------------------------
# is.infinite()          x
# -------------------------------------------
# is.na()                       x      x
# -------------------------------------------
# is.nan()                             x
# -------------------------------------------

# 20.3.3 Character

# Character vectors are the most complex type of atomic vector, because each element of a character vector is a sting, 
# and a string can contain an arbitrary amount of data.

# You 've already learned a lot about working with strings in strings. Here I wanted to mention one important feature of the underlying string implimentation:
# R uses a global string pool. This means that each unique string is only stored in memory once, and every use of the string points to that representattion.
# This reduces th amount of memory needed by duplicated strings. You can see this befauiour in practice with pryr::object_size():
x <- "This is a reasonably long string."
pryr::object_size(x)

y <- rep(x, 1000)
pryr::object_size(y)

# y doesn't take up 1,000x as much memory as x, because each element of y is just a pointer to that same string. 
# A pointer is 8 bytes, so 1000 pointers to a 136B sting is 8 * 1000 + 136 = 8.13 KB.

# 20.3.4 Missing values

# Note that each type of atomic vector has its own missing values:
NA             # logical
NA_integer_    # integer
NA_real_       # double
NA_character_  # character

# Normally you don't need to know about these different types because you cna always use NA and it will be converted to the 
# correct type using the implicit coercion rules described next.
# However, there are some functions that are strict about their inputs, so it's useful to have this knowledgesitting in your back
# pocket so you can be specific when needed.

# 20.3.5 Exercises

# 1. Describe th difference between is.finite(x) and !is.infinite(x).
?is.infinite()
## is.finite and is.infinite return a vector of the same length as x, indicating which elements are finite
## (not infinite and not missing) or infinite.
is.finite(c(0, NA, NaN, Inf, -Inf))
is.infinite(c(0, NA, NaN, Inf, -Inf))

# 2. Read the source code for dplyr::near() (Hint: to see the source code, drop the () ).
#    How does it work?
dplyr::near
# function (x, y, tol = .Machine$double.eps^0.5) 
# {
#   abs(x - y) < tol
# }
# <bytecode: 0x108494778>
# <environment: namespace:dplyr>

## Instead of checking for exact equality, it checks that two numbers are within a certain tolerance, tol. 
## By default the tolerance is set to the square root of .Machine$double.eps, 
## which is the smallest floating point number that the computer can represent.

# 3 . A logical vector can take 3 possible values. How many possible values can an integer vector take?
#     How many possible values can a double take? Use google to do some research.

## integer 
?integer
.Machine$integer.max
## the largest integer which can be represented. Always 2^31 - 1 = 2147483647.
## but I don't know why the length need to -1 
## so I search on the stackoverflow for answer:
## 2^32 possible values
## − 2^31 values used for negative integers
## − 1 value used for zero
## = 2^31−1 values available for positive integers
## https://stackoverflow.com/questions/3826704/why-int32-has-max-value-231-1

## double 
?double
# Double-precision values
# All R platforms are required to work with values conforming to the IEC 60559 (also known as IEEE 754) standard.
# This basically works with a precision of 53 bits, and represents to that precision a range of absolute values from about 2e-308 to 2e+308. 
# It also has special values NaN (many of them), plus and minus infinity and plus and minus zero (although R acts as if these are the same).
# There are also denormal(ized) (or subnormal) numbers with absolute values above or below the range given above but represented to less precision.
.Machine$double.xmax
## 1.797693e+308
.Machine$double.base
## 2
.Machine$double.digits
## 53
.Machine$double.eps
## 2.220446e-16
.Machine$double.neg.eps
## 1.110223e-16
## .Machine$double.eps 是 R 中不同數值的最小差異值，如果兩個不同數值的差異小於這個值，
## 那麼 R 會將兩個數值視為相同的，而 all.equal 在判斷兩個向量是否相同時，也是使用這個值

## https://blog.gtwang.org/r/r-variables-and-workspace/
## https://en.wikipedia.org/wiki/IEEE_754

# 4. Brainstorm at least four functions that allow you to convert a double to an integer.
#    How do they differ? Be precise.

# 5. What functions from the readr package allow you to turn a string into logical, 
#    integer, and double vector?
readr::parse_logical()
readr::parse_integer()
readr::parse_double()

# 20.4 Using atomic vectors
# Note that you understand the diffenent type os atomic vector, 
# it's useful to review some of the important tools for working with them. These include:
# 1. How to convert from one type to another, and when that happens automatically.
# 2. How to tell if an obect os a specific type of vector.
# 3. What happens when you work with vectors of different lengths.
# 4. How to name the elements of a vector.
# 5. How to pull out elements of interest.

# 20.4.1 Coercion

# There are two ways to convert, or coerce, one type of vector to another:
# 1. Explicit coercion happens when you call a function ike as.logical(), as.integer(), as.double(), or as.character().
#    Whenever you find yourself using explicit coercion, you should always check thether you can make the fix upstream, 
#    so that the vector never had the wrong type in the first place.
#    For example, you may need to tweak your readr col_types specification.
# 2. Implicit coercion happens when you use a vector in a specific context that expects a certain type of vector.
#    For example, when you use a logical vector with a numeric summary function, 
#    or when you use a double vector where an integer vector is expected.

# Because explicit coercion is used relatively rarely, and is largely easy to understand, I'll focus on implicit coercion here.

# You've alerady senn the most important type of implicit coercion: using a logical vector in a numeric context.
# In this case TRUE is converted to 1 and FALSE converted to 0.
# That means the sum of a logical vector is the number of trues, and the mean of a logical vector is the proportion of trues:
x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y) # how many are greater than 10?
mean(y) # what proportion are greater than 10?

# You may see some code (typically older) that relies on implicit coercion in the opposite direction, from intiger to logical:
if (length(x)) {
  # do something
}

# In this case, 0 is converted to FALSE and everything else is converted to TRUE.
# I think this makes it hearder to understand your code, and I don't recommend it. Instead be explicit length(x) > 0.

# It's also important to understand what happens when you try and create a vector containing multiple types with c(): the most complex type always wins.
typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

# An atomic vector can not have a mix of diffenent types because the type is a property of the complete vector, not the individual elements.
# If you need to mix multiple types in the smae vector, you should use a list, thich you'll learn about shortly.

# 20.4.2 Test functions

# Sometimes you want to do different things based on the type of vector. One option is to use typeof().
# Another is to use a test funciton which returns a TRUE or FALSE.
# Base R provedes many functions like is.vector() and is.atomic(), but they often return surprision results.
# Instead, it's safer to use the is_* functions proveded by purrr, which are summarised in the table below.

# |----------------|------|------|------|------|------|
# |                | lgl  | int  | dbl  | chr  | list |
# |----------------|------|------|------|------|------|
# | is_logical()   | x    |      |      |      |      |
# |                |      |      |      |      |      |
# | is_integer()   |      | x    |      |      |      |
# |                |      |      |      |      |      |
# | is_double()    |      |      | x    |      |      |
# |                |      |      |      |      |      |
# | is_numeric()   |      | x    | x    |      |      |
# |                |      |      |      |      |      |
# | is_character() |      |      |      | x    |      |
# |                |      |      |      |      |      |
# | is_atomic()    | x    | x    | x    | x    |      |
# |                |      |      |      |      |      |
# | is_list()      |      |      |      |      | x    |
# |                |      |      |      |      |      |
# | is_vector()    | x    | x    | x    | x    | x    |
# |----------------|------|------|------|------|------|

# Each predicate also comes with a "scalar" version, like is_scalar_atomic(), which checks that the length is 1.
# This is useful, for example, if you want to check that an argument to your function is a single logical value. 

# 20.4.3 Scalars and recycling rules

# As well as implicitly coercing the types of vectors to be compatible, R will also implicitly coerce the length of vectors.
# This is called vector recycling, because the shorter vector is repeated ,or recycled, to the same length as the longer vector.

# This is generally most useful whaen you are micing vectors and "scalars". I put scalars in quotes because R doesn't actually have scalars:
# instead, a single number is a vector of length 1. Because there are no scalars, ost built-in functions are vectorised, 
# meaning that they will operate on a vector of numbers. That's why, for example, this code works:
sample(10) + 100

runif(10) > 0.5

# In R, basic mathematical operations work with vectors. 
# That means that you should never need to perform ecplicit iteration when performing simple mathematical computations.

# It's intuitive what should happen if you add two vectors of the same length, or a vector and a "scalar",
# but what happens if you add two vectors of different lengths?
1:10 + 1:2

# Here, R will expand the shortest vector to the same length as the longest, so called recycling.
# This is silent except when the length of the longer is not an integer mutiple of the length of the shorter:
1:10 + 1:3

# While vector recycling can be used to create very succinct, clever code, it can also slently conceal problems.
# For this reason, the vectorised functions in tidyverse will throw errors when you recyble anything other than a scalar.
# If you do want to recycle, you'll need to do it yourself with rep():
tibble(x = 1:4, y = 1:2)
tibble(x = 1:4, y = rep(1:2, 2))

tibble(x = 1:4, y = rep(1:2, each = 2))

# 20.4.4 Naming vectors

# All types of vectors can be named. You can name them during creation with c():
c(x = 1, y = 2, z = 4)

# Or after the fact with purrr::set_names()
set_names(1:3, c("a", "b", "c"))

# Named vectors are most useful for subsetting, described next.

# 20.4.5 Subsetting

# So far we've used dplyr::filter() to filter the rows in a tibble. 
# filter() only works with tibble, so we'll need new tool for vectors: [.
# [ is the subsetting function, and is called like x[a].
# There are four types of things that you can subset a vector with:
# 1. A numeric vector containing only integers. The integers must either be all positive, all negative, or zero.
#    Subsetting with positive integers keeps the elements at those positions:
x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]

#    By repeating a position, you can actually make a longer output tha n input:
x[c(1, 1, 5, 5, 5, 2)]

#    Negative values drop the elements at the specified positions:
x[c(-1, -3 ,-5)]

#    It's an error to mix poditive and vegative values:
x[c(1 ,-1)]

#    The error message mentions subsetting with zero, thich returns no values:
x[0]

#    This is not useful very often, but it can be helpful if you want to create unusual data structures to test your functions with.

# 2. Subsetting with a logical vector keeps all values corresponding to a TRUE value.
#    This is most often useful in conjunction with the comparison functions.
x <- c(10, 3, NA, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]

# All even(or missing!) values of x
x[x %% 2 == 0]

# 3. If you have a named vector, you can subset it with a character vector:
x <- c(abc = 1, def = 2, xyz = 5)
x[c("xyz", "def")]
#    Like with positive integer, you can also use a character vector to duplicate individual entries.

# 4. The simplest type of subsetting is nothing, x[], which returns the complete x.
#    This is not useful for subsetting, but it is useful when subsetting matrices (and other high dimensional structures)
#    because it lets you select all the rows or all the columns, by leaving that index blank.
#    For exmaple, if x is 2d, x[1, ] selects the first row and all the columns, and x[, -1] selects all rows and all columns except the first.

# To learn more about the applications of subsetting, reading the "Subsetting" chapter of Advanced R:
# http://adv-r.had.co.nz/Subsetting.html#applications.

# there is an important variation of [ called [[. [[ only ever extracts a single element, and always drops names.
# It's good idea to use it whenever you want to make it clear that you're extracting a single item, as in a for loop.
# The distinction between [ and [[ os most important for lists, as we'll see shortly.

# 20.4.6 Exercises

# 1. What does mean(is.na(x)) tell you about a vector x? 
#    What about sum(!is.finite(x))?

## (1) mean(is.na(x)) is calculates the propotion of missing values in the vector of x.
x <- c(1, 2, 3, 4, 5, 6, 7, NA, 8, NA)
mean(is.na(x))

## (2)  sum(!is.finite(x)) will calsulates the number of elements in the vector of x that are equal to NA, NaN, +Inf and -Inf.
x <- c(Inf, -Inf, NA, NaN, -2:2)
sum(!is.finite(x))

x[!is.finite(x)] # Inf -Inf   NA  NaN
x[is.infinite(x)] # Inf -Inf

# 2. Carefully read the documentation of is.vector(). What does it actually test for?
#    Why does is.atomic() not agree with the definition of atomic vectors above?
?is.vector()

## For as.vector, a vector (atomic or of type list or expression). 
## All attributes are removed from the result if it is of an atomic mode, but not in general for a list result. 
## The default method handles 24 input types and 12 values of type: 
## the details of most coercions are undocumented and subject to change.

## For is.vector, TRUE or FALSE. 
## is.vector(x, mode = "numeric") can be true for vectors of types "integer" or "double" whereas 
## is.vector(x, mode = "double") can only be true for those of type "double".

?is.atomic()
## It is common to call the atomic types ‘atomic vectors’, but note that is.vector imposes further restrictions: 
## an object can be atomic but not a vector (in that sense).

# 3. Compare and contrast setNames() with purrr::set_names().
?setNames()
?purrr::set_names()


## (1) the purrr:set_names() will check the length of the nm arguent is the same length as the x that is being named.
##     If the length is not same, then it will prompt a error message.
##     but the setName() not error instead of set vector's name to <NA>
setNames(1:4, c("a", "b"))
set_names(1:4, c("a", "b"))

## (2) If x already has names, you can provide a function or formula to transform the existing names. 
##     In that case, ... is passed to the function.
x <- c(a = 1, b = 2, c = 3, d = 4)
x
purrr::set_names(x, str_to_upper)

## (3) In all other cases, nm and ... are coerced to character. But setName() will prompt error. 
setNames(1:4, "a", "b", "c", "d")
purrr::set_names(1:4, "a", "b", "c", "d")

# 4. Create functions that take a vector as input and returns:
#    (1) The last value. Should you use [ or [[?
#    (2) The elements at even numbered positions.
#    (3) Every element except the last value.
#    (4) Only even numbers (and no missing values).

x <- c(1:20)
## (1)

last_value <- function(x) {
  if(length(x) == 0) {
    return(0)
  } 
  return(x[[length(x)]])
}
last_value(x)

## (2)
even_position <- function(x) {
  return(x[1:length(x) %% 2 == 0])
}
even_position(x)
even_position(letters[1:10])

## (3)
drop_last_element <- function(x) {
  return(x[-length(x)])
}
drop_last_element(x)

## (4) 
x <- c(1:5, NA, -5:5)
even_number <- function(x) {
  return(x[!is.na(x) & x %% 2 == 0])
}
even_number(x)

# 5. Why is x[-which(x > 0)] not the same as x[x <= 0]?
x <- c(Inf, -Inf, NA, NaN, -2:2)
x[-which(x > 0)]
x[x <= 0]

## -Inf   NA  NaN   -2   -1    0
## -Inf   NA   NA   -2   -1    0
## We can see the different between x[-which(x > 0)] and x[x <= 0] is NA value.

# 6. What happens when you subset with a positive integer that's bigger than length of the vector?
#    What happens when you subset with a name that doesn't exist?
## (1) If you subset with bigger value than length of the vector, it will reutrn NA value.
x <- set_names(c(1:20), letters[1:length(x)])
x[length(x) + 1]

## (2) It also return NA value without error.
x[c('a', 'b', 'z')]

## (3) If you want to subset the value with a name theat doesn't exist, it will error.
x[['z']] # Error in x[["z"]] : subscript out of bounds

# 20.5 Recursive vectors (lists)

# Lists are a step up in complexity from atomic vectors, because lists can contain other lists.
# This makes them suitable for representing hierarchical or tree-like structures.
# You create a list with list():
x <- list(1, 2, 3)
x

# A very useful tool for working with lists is str() because it focusses on the structure, not the contents.
str(x)

x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# Unlike atomic vectors, list() can contain a mix of objects:
y <- list("a", 1L, 1.5, TRUE)
str(y)

# Lists can even contain other lists!
z <- list(list(1, 2), list(3, 4))
str(z)

# 20.5.1 Visualising lists

# To explain more complicated list manipulation functions, it's helpful to have a visual representation of lists.
# For example, take these three lists:
x1 <- list(c(1, 2), c(3, 4))
x2 <- list(list(1, 2), list(3, 4))
x3 <- list(1, list(2, list(3)))

# I'll draw them as follows:
#        x1                   X2                         x3
# /------------\   /----------------------\   /---------------------\
# |  |---|---| |   |  /----------------\  |   |        |---|        |
# |  | 1 | 2 | |   |  |  |---|  |---|  |  |   |        | 1 |        |
# |  |---|---| |   |  |  | 1 |  | 2 |  |  |   |        |---|        |
# |  | 3 | 4 | |   |  |  |---|  |---|  |  |   |                     |
# |  |---|---| |   |  \----------------/  |   |  /---------------\  |
# \ -----------/   |                      |   |  |     |---|     |  |
#                  |  /----------------\  |   |  |     | 2 |     |  |
#                  |  |  |---|  |---|  |  |   |  |     |---|     |  |
#                  |  |  | 1 |  | 2 |  |  |   |  |  /---------\  |  |
#                  |  |  |---|  |---|  |  |   |  |  |  |---|  |  |  |
#                  |  \----------------/  |   |  |  |  | 3 |  |  |  |
#                  \----------------------/   |  |  |  |---|  |  |  |
#                                             |  |  \---------/  |  |
#                                             |  \---------------/  |
#                                             \---------------------/

# There are three principles:
# 1. Lists have rounded corners. Atomic vectors have square corners.
# 2. Children are drawn inside their parent, and have a slightly darker beckground to make it easier to see the hierarchy.
# 3. The orientation of the children (i.e. rows or columns) isn't important, so I'll pick a row or column orientation
#    to either save space or illustrate an important property in the example.

# 20.5.2 Subsetting 

# There are three ways to subset a list, which I'll illustrate with a list named a:
a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))

# 1. [ extracts a sub-list. The result will always be a list.
str(a[1:2])
str(a[4])

#    Like with vectors, you can subset with a logical, integer, or character vector.

# 2. [[ extracts a single component from a list. It removes a livel of hierarchy from the list.
str(a[[1]])
str(a[[4]])

# 3. $ is a shorthand for extracting named elements of a list. It works similarly to [[ except that you don't need to use quotes.
a$a
a[["a"]]

# The distinction between [ and [[ is really important for lists, because [[ drills down into the list while [ returns a new, smaller list.
# Compare the code and output above with the visual representation in Figure 20.2.

#          a                  a[1:2]                  a[4]                a[[4]]
# /-----------------\   /-----------------\   /-----------------\    /-------------\
# |  |---|---|---|  |   |  |---|---|---|  |   |                 |    | |---| |---| | 
# |  | 1 | 2 | 3 |  |   |  | 1 | 2 | 3 |  |   |                 |    | |-1 | |-5 | |
# |  |---|---|---|  |   |  |---|---|---|  |   |                 |    | |---| |---| |
# |                 |   |                 |   |                 |    \-------------/ 
# | |-------------| |   | |-------------| |   |                 |
# | | "a string"  | |   | | "a string"  | |   |                 |       a[[4]][1]
# | |-------------| |   | |-------------| |   |                 |    /-------------\
# |                 |   |                 |   |                 |    | |---|       | 
# | |-------------| |   |                 |   |                 |    | |-1 |       |
# | | 3.141525    | |   |                 |   |                 |    | |---|       |
# | |-------------| |   |                 |   |                 |    \-------------/ 
# |                 |   |                 |   |                 |
# | /-------------\ |   |                 |   | /-------------\ |      a[[4]][[1]]
# | | |---| |---| | |   |                 |   | | |---| |---| | |
# | | |-1 | |-5 | | |   |                 |   | | |-1 | |-5 | | |        |---|
# | | |---| |---| | |   |                 |   | | |---| |---| | |        |-1 |
# | \-------------/ |   |                 |   | \-------------/ |        |---|
# |                 |   |                 |   |                 | 
# \-----------------/   \-----------------/   \-----------------/
# Figuare 20.2: Subsetting a list, visually.

# 20.5.3 Lists of condiments

# The difference between [ and [[ is very important, but it's easy to get confused.
# To help you remember, let me show you unusual pepper shaker.

#   |xxxxxxxxxxxxx|
#  |xxxxxxxxxxxxxxx|
#  |xxxxxxxxxxxxxxx|
#  |               |
#  |  |------ -|   |
#  |  |        ||  |
#  |  | pepper ||| |
#  |  |        ||| |   <- pepper shaker conaining multiple pepper packer.
#  |  |--------||| |
#  |  |--------||| |
#  |  |--------||| |
#  |---------------|

# If this pepper shaker is your list x, then, x[1] is a pepper shaker containing a single pepper packet:

#   |xxxxxxxxxxxxx|
#  |xxxxxxxxxxxxxxx|
#  |xxxxxxxxxxxxxxx|
#  |               |
#  |  |------ -|   |   <- pepper shaker containing a single pepper packet.
#  |  |        |   |
#  |  | pepper |   |
#  |  |        |   |
#  |  |--------|   |
#  |               |
#  |               |
#  |---------------|

# x[2] would look the same, but would contain the second packet.
# x[1:2] would be a pepper shaker containing two pepper packets.
# x[[1]] is:

# |--------|   
# |        |   
# | pepper |   <- pepper package
# |        |   
# |--------|   

# If you wanted to get the content of the pepper package, you'd need x[[1]][[1]]:

#     . , .
#   ,. . ., .
#   .., ,...   <- pepper
#   ..... . . 
#    , . , ,

# 20.5.4 Exercises

# 1. Draw the following lists as nested sets:
#    (1) list(a, b, list(c, d), list(e, f))
#    (2) list(list(list(list(list(list(a))))))

## (1) list(a, b, list(c, d), list(e, f))
# /---------------------\
# |    |---|  |---|     |
# |    | a |  | b |     |
# |    |---|  |---|     |
# |                     |
# |  /---------------\  |
# |  |  |---| |---|  |  |
# |  |  | e | | f |  |  |
# |  |  |---| |---|  |  |
# |  \---------------/  |
# |                     |
# |  /---------------\  |
# |  |  |---| |---|  |  |
# |  |  | e | | f |  |  |
# |  |  |---| |---|  |  |
# |  \---------------/  |
# |                     |
# \---------------------/

## (2) list(list(list(list(list(list(a))))))
# /---------------------------------------\
# |                                       |
# |  /---------------------------------\  |
# |  |                                 |  |
# |  |  /---------------------------\  |  |
# |  |  |                           |  |  |
# |  |  |  /---------------------\  |  |  |
# |  |  |  |                     |  |  |  |
# |  |  |  |  /---------------\  |  |  |  |
# |  |  |  |  |               |  |  |  |  |
# |  |  |  |  |  /---------\  |  |  |  |  |
# |  |  |  |  |  |  |---|  |  |  |  |  |  |
# |  |  |  |  |  |  | a |  |  |  |  |  |  |
# |  |  |  |  |  |  |---|  |  |  |  |  |  |
# |  |  |  |  |  \---------/  |  |  |  |  |
# |  |  |  |  |               |  |  |  |  |
# |  |  |  |  \---------------/  |  |  |  |
# |  |  |  |                     |  |  |  |
# |  |  |  \---------------------/  |  |  |
# |  |  |                           |  |  |
# |  |  \---------------------------/  |  |
# |  |                                 |  |
# |  \---------------------------------/  |
# |                                       |   
# \---------------------------------------/

# 2. What happens if you subset a tibble as if you're subsetting a list?
#    What are the key differences between a list and a tibble?

x <- tibble(x = 1:15, y = letters[1:length(x)], z = str_to_upper(y))
x

## subsetting x by column's name
x['x']

## subsetting x by index
x[2:3]

## subsetting x by explict index of row and column
x[1, ]

# 20.6 Attributes

# Any vector can contain arbitrary additional metadata through its attributes.
# You can think of attributes as named list of vectors that can be attached to any object.
# You can get and set individual attribute velues with attr() or see then all at once with attributes().
x <- 1:10
attr(x, "greeting") # NULL

attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x)

# There are three important attributes that are used to implement fundamental parts of R:
# 1. Names are used to name the elemnets of a vector.
# 2. Dimensions (dims, for shourt) make a vector behave like a matrix or array.
# 3. Class is used to implement the s3 object oriented system.

# You've seen names above, and we won't cover dimensions because we don't use matrices in this book.
# It remains to describe the class, which controls how generic funcitons work.
# Generic functions are key to object oriented programming in R, because they make funcitons behave differently for different classes of input.
# A detailed discussion of object oriented programming is beyond the scope of this book, but you can read more about it in Advanced R at
# http://adv-r.had.co.nz/OO-essentials.html#s3.

# Here's what a typical generic function looks like:
as.Date
# The call to "UseMethod " means that this is a generic function, and it will call a specific method, a function, based on the class of the first argument.
# (All methods are funcitons; not all funcitons are methods). You can list all the methods for a generic with methods():
methods("as.Date")

# For example, if x is a character vector, as.Date() will call as.Date.character(); if it's a factor, it'll call as.Date.factor().

# You can see the specific implementation of a methos with getS3method():
getS3method("as.Date", "default")

getS3method("as.Date", "numeric")

# The most important S3 generic is print(): it controls how the object is printed when you type its name at the console.
# Other important generics are the subsetting funciions [, [[, and $.

# 20.7 Augmented vectors

# Atomic vectors and lists are the building blocks for other important vector types like factors and dates.
# I call these augmented vectors, because they are vectors with additional attributes, including class.
# Because augmented vectors have a calss, they behave differently to the atomic vector on which they are built.
# In this book, we make use of four important augmented vectors:
# 1. Factors
# 2. Dates
# 3. Date-times
# 4. Tibbles
# These are described below.

# 20.7.1 Factors 
# Factors are designed to represent catdgorical data that can take a fixed set of possible values.
# Factors are built on top of integers, and have a levels attribute:
x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)

# 20.7.2 Dates and date-times
# Dates in R are numeric vecors that represent the number of days since 1 January 1970.
x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# Date-times are numecir vectors with class POSIXct that represent the number of seconds since 1 January 1970.
# (In case you were wondering, "POSIXct" stands for "Portable Operating System Interface", calendar time.)
x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)
typeof(x)
attributes(x)

# The tzone attribute is optional. It controls how the time is printed, not what absolute time it refers to.
attr(x, "tzone") <- "US/Pacific"
x

attr(x, "tzone") <- "US/Eastern"
x

# There is another type of date-times called POSIXlt. These are built o n top of named lises:
y <- as.POSIXlt(x)
typeof(y)
attributes(y)

# POSIXlts are rare inside the tidyverse. They do crop up in base R, because they are needed to extract specific components of a data, 
# like the year or month. Since lubridate provides helpers for you to do this instead, you don't need them.
# POSIXlt, you should always convert it to a regular data time lubriadate::as_datetime().

# 20.7.3 Tibbles

# Tibbles are augmented lists:they have calss "tbl_df" + "tbl" + "date.frame", and names(column) and row.names attributes:
tb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(tb)
attributes(tb)

# The difference between a tibble and a list is that all the elements of a data frame must be vectors with the same length.
# All functions that work with tibbles enforce this constraint.

# Traditional data.frames have a very similar structure:
df <- data.frame(x = 1:5, y = 5:1)
typeof(df)
attributes(df)

# The main difference is the class. The calss of tibble includes "data.frame" 
# which means tibbels inherit the regular data frame beharviour by default.

# 20.7.4 Exercises
# 1. What does hms::hms(3600) return? How doed it print? 
#    What primitive type is the augmeted vector built on top of? What attributes does it use?
x <- hms::hms(3600)
x
## It's return 3600 seconds == 1 hrs.

typeof(x)
## the primitive type is "double"

attributes(x)
## $class
## [1] "hms"      "difftime"
## $units
## [1] "secs"

# 2. Try and make a tibble that has columns wtih different lengths. What happens?

## If you give the column with different, there are two situation:
## (1) give a value and a vector: this will recycle the value as same as the length of vector.
x <- tibble::tibble(x = 1:6, y = 2)
x

## (2) But if you give two different length of vector, it will prompt error message.
x <- tibble::tibble(x = 1:6, y = 1:3)
x

# 3. Based on the definition above, is it ok to have a list as a column of a tibble? 
## yes
x <- tibble::tibble(a = 1:5, b = list(letters[1:5]))