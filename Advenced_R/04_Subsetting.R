set.seed(1014)

# 4 Subsetting 

# 4.1 Introduction 

# R's subsetting opereators are fast and powerful.
# Mastering them allows you to succintly perform complex operations in a way that few other languages can match.
# Subsetting in R is easy to learn but heard to master becuase you need to internalise a number of interrelated concepts:

# - There are six way to subset atomic vectors.
# - There are three subsetting operators, `[[`, `[`, and `$`.
# - Subsetting operators interact differnetly with different vector types(e.g. atomic vectors, lists, factors, matrices, and data frames).
# - Subsetting can be combined with assignment.

# subsetting is a natural complement to `str()`.
# While `str()` shows yo all the peices of any object (its structure), subsetting allows you to pull out the pieces that you're interested in.
# For large, complex objects, I highly recommend using the interactive RStudio Viewer, which you can active with `View(my_object)`.

# Quiz

# Take this short quiz to determine if you need to read this chapter. 
# If the answers quickly come to mind, you can comfortably skip this chapter. 
# Check your answers in Section 4.6.

# 1. What is the result of subsetting a vector with positive integers, negative integers, a logical vector, or a character vector?
# 2. What’s the difference between [, [[, and $ when applied to a list?
# 3. When should you use drop = FALSE?
# 4. If x is a matrix, what does x[] <- 0 do? How is it different from x <- 0?
# 5. How can you use a named vector to relabel categorical variables?

# Outline

# - Section 4.2 starts by teaching you about [. You’ll learn the six ways to subset atomic vectors. 
#   You’ll then learn how those six ways act when used to subset lists, matrices, and data frames.

# - Section 4.3 expands your knowledge of subsetting operators to include [[ and $ and focuses on the important principles of simplifying versus preserving.
                                                                         
# - In Section 4.4 you’ll learn the art of subassignment, which combines subsetting and assignment to modify parts of an object.
                                                                         
# - Section 4.5 leads you through eight important, but not obvious, applications of subsetting to solve problems that you often encounter in data analysis.

# 4.2 Selecting multiple elements

# Use `[` to select any number of elements from a vector.
# To illlustrate, I'll apply `[` to 1D atomic vectors, and then show how this generalises to more compolex objects and more dimensions.

# 4.2.1 Atomic vectors

# Let's explore the different types of subsetting with a simple vector, `x`.
x <- c(2.1, 4.2, 3.3, 5.4)

# Note that the number after the decimal point represents the original position in the vector.

# There are six things that you can use to subset a vector:

# __Positive integers__ return elements at the specified positions:
x[c(3, 1)]
#> [1] 3.3 2.1
x[order(x)]
#> [1] 2.1 3.3 4.2 5.4

# Duplicate indices will duplicate values
x[c(1, 1)]
#> [1] 2.1 2.1

# Real numbers are silently truncated to integers
x[c(2.1, 2.9)]
#> [1] 4.2 4.2

# __Negative integers__ exclude elements at the specified positions:
x[-c(3, 1)]
#> [1] 4.2 5.4

# Note that you can't positive and negative integers in a single subset:
x[c(-1, 2)]
#> Error in x[c(-1, 2)] : only 0's may be mixed with negative subscripts

# __Lgical vectors__ select elements where the corresponding logical value is `TRUE`.
# This is probably the most useful type of subsetting because you can write an expression that uses a logical vector:
x[c(TRUE, TRUE, FALSE, FALSE)]
#> [1] 2.1 4.2
x[x > 3]
#> [1] 4.2 3.3 5.4

# In `x[y]`, what happens if `x` and `y` are different lengths?  
# The behaviour is controlled by the __recycling rules__ where the shorter of the two is recycled to the length of the longer.
# This is convenient and easy to ungerstand when one of `x` and `y` si length one,
# but I recommend avoiding recycling for other lengths because the rule are incondidtently applied throughout base R.
x[c(TRUE, FALSE)]
#> [1] 2.1 3.3
# Equivalent to 
x[c(TRUE, FALSE, TRUE, FALSE)]
#> [1] 2.1 3.3

# Note that a missing value in the index always yields a missing value in the output:
x[c(TRUE, TRUE, NA, FALSE)]
#> 2.1 4.2  NA

# __Nothing__ returns the riginal vactor. 
# This is not useful for 1D vectors, but, as you'll see shortly, is very useful for matrices, data frames, and arrays.
# It can also be useful in conjunction with assignment.
x[]
#> [1] 2.1 4.2 3.3 5.4

# __Zero__ returns a zero-length vector.
# This is not something you usually do on purpose, but it can be helpful for generating test data.
x[0]
#> numeric(0)

# If the vector is named, you can also use __character vectors__ to return elements with matching names.
(y <- setNames(x, letters[1:4]))
#>   a   b   c   d 
#> 2.1 4.2 3.3 5.4
y[c("d", "c", "a")]
#>   d   c   a 
#> 5.4 3.3 2.1

# Like integer indices, you can repeat indices
y[c("a", "a", "a")]
#>   a   a   a 
#> 2.1 2.1 2.1

# When sugsetting with [, names are always matched exactly
z <- c(abc = 1, def = 2)
z[c("a", "d")]
#> <NA> <NA> 
#>   NA   NA

# NB: Factor are not treated specially when subsetting.
# This means that subsetting will use the underlying integer vector, not the character levels.
# This is typically unexpected, so you should avoid subsetting with factors:
y[factor("b")]
#>   a 
#> 2.1

# 4.2.2 Lists

# Subsetting a list works in the same way as subsetting an atomic vector.
# Using `[` alawys returns a list;
# `[[` and `$`, as described in Section 4.3, lets you pull uot elements of a list.

# 4.2.3 Matrices and arrays

# You can subset higher-dimensional strctures in three ways:

# - With multiple vectors.
# - With a single vector.
# - With a matrix.

# The most common way of subsetting mateices (2D) and arrays (> 2D) is a simple generalisation of 1 D subsetting:
# supply a 1 D index for each dimension, separated by a comma.
# Blank subsetting is now useful because it lets you keep all rows or all columns.
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a[1:2, ]
#>      A B C
#> [1,] 1 4 7
#> [2,] 2 5 8
a[c(TRUE, FALSE, TRUE), c("B", "A")]
#>      B A
#> [1,] 4 1
#> [2,] 6 3
a[0, -2]
#>      A C

# By default, `[` simplifies the results to the lowest possible dimensionality.
# For exmaple, both of the dollowing expressions return 1D vectors.
# You'll learn how to avoid "dropping" dimensions in Section 4.2.5:
a[1, ]
#> A B C 
#> 1 4 7
a[1, 1]
#> A 
#> 1 

# Because both matrices and arrays are just vectors with special attributes, you can subset them with a single vector, as if they were a 1D vector.
# Note that arrays in R are stored in column-major order:
vals <- outer(1:5, 1:5, FUN = "paste", sep = ",")
vals
#>      [,1]  [,2]  [,3]  [,4]  [,5] 
#> [1,] "1,1" "1,2" "1,3" "1,4" "1,5"
#> [2,] "2,1" "2,2" "2,3" "2,4" "2,5"
#> [3,] "3,1" "3,2" "3,3" "3,4" "3,5"
#> [4,] "4,1" "4,2" "4,3" "4,4" "4,5"
#> [5,] "5,1" "5,2" "5,3" "5,4" "5,5"

vals[c(4, 15)]
#> [1] "4,1" "5,3"

# You can also subset higher-dimensional data structures with an integer matrix (or, if named, a character matrix).
# Each row in the matrix specifies the location of noe value, and each column corresponds to a dimension in the array.
# This means that you can use a 2 column matrix to subset a matrix, a 3 column matrix to subset a 3D array, and so on.
# The result is a vector of values:
select <- matrix(ncol = 2, byrow = TRUE, c(
  1, 1,
  3, 1,
  2, 4
))
vals[select]
#> [1] "1,1" "3,1" "2,4"

# 4.2.4 Data frames and tibbles

# Data frames have the characteristics of both lists and matrices:

# - When subsetting with a single index, they behave like lists and index the columns, so `df[1:2]` selects the first two columns.

# - When subsetitng with two indices, they behae like matirces, so `df[1:3, ]` selects the first three rows (and all the columns).

df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df[df$x == 2, ]
#>   x y z
#> 2 2 2 b
df[c(1, 3), ]
#>   x y z
#> 1 1 3 a
#> 3 3 1 c

# There are two ways to select columns from a data frame 
# Like a list
df[c("x", "z")]
#>   x z
#> 1 1 a
#> 2 2 b
#> 3 3 c

# Like a matrix 
df[, c("x", "z")]
#>   x z
#> 1 1 a
#> 2 2 b
#> 3 3 c

# There's an important difference if you select a single 
# column: matrix subsetting simplifies by default, list 
# subsetitng does not.
str(df["x"])
#> 'data.frame':	3 obs. of  1 variable:
#> $ x: int  1 2 3
str(df[, "x"])
#> int [1:3] 1 2 3

# Subseting a tibble with `[` always returns a tibble:
df <- tibble::tibble(x = 1:3, y = 3:1, z = letters[1:3])
str(df["x"])
#> Classes 'tbl_df', 'tbl' and 'data.frame':    3 obs. of  1 variable:
#>  $ x: int  1 2 3
str(df[, "x"])
#> Classes 'tbl_df', 'tbl' and 'data.frame':    3 obs. of  1 variable:
#>  $ x: int  1 2 3

# 4.2.5 Preserving dimensionality 

# By default, subsetting a matrix or data frame with a single number, a single names, or a logical vector containing a single `TRUE`, will simplify the returned output,
# i.e. it will return an object with lower dimensionality.
# To preserver the original dimensionality, you must use `drop = FALSE`.

# For matrices and arrays, any dimensions with length 1 will be dropped:
a <- matrix(1:4, nrow = 2)
str(a[1, ])
#>  int [1:2] 1 3
str(a[1, , drop = FALSE])
#> int [1, 1:2] 1 3

# Data frames with a single column will retyrn just that column:
df <- data.frame(a = 1:2, b = 1:2)
str(df[, "a"])
#>  int [1:2] 1 2
str(df[, "a", drop = FALSE])
#> 'data.frame':	2 obs. of  1 variable:
#>   $ a: int  1 2

# The default `drop = TRUE` behaviour is a common source of bugs in function: 
# you check your code with a data frame or matrix with multiple columns, and it works.
# Six months later, you (or someone else) uses it with a single column data frame and it fails with a mystifying error.
# When writing function, get in the habit of always using `drop = FALSE`, and `[` always returns another tibble.

# Factor subsetting also has `drop` argument, but its meaning is rather different.
# It controls whether or not levels (rather than dimensions) are preserved, and ti defaults to `FALSE`.
# If you're using `drop = TRUE` a lot it's often a sign that you should be using a character vector instread of a factor.
z <- factor(c("a", "b"))
z[1]
#> [1] a
#> Levels: a b
z[1, drop = TRUE]
#> [1] a
#> Levels: a

# 4.2.6 Exercises

# 1. Fix each of the following common data frame subsetting errors:
mtcars[mtcars$cyl = 4, ]      # use `==`              
mtcars[-1:4, ]                # use `-(1:4)`
mtcars[mtcars$cyl <= 5]       # use `,` is missing
mtcars[mtcars$cyl == 4 | 6, ] # use `mtcars$cyl == 6`

# 2. Why does the following code yield five missing values? (Hint: why is it different from `x[NA_real_]`?)
x <- 1:5
x[NA]

# `NA` has logical type and logical vectors are recycled to the same length as the vector being subset, i.e. `x[NA]` is recycled to `x[NA, NA, NA, NA, NA]`

# 3. What does `upper.tir()` return? How does subsetting a matrix with it work?
#    Do we need any additional subsetting rules to describe its behaviour?
x <- outer(1:5, 1:5, FUN = "*")
x[upper.tri(x)]

# `upper.tri()` returns logical matrix containint `TRUE` for all upper diagonal elements and `FALSE` otherwise.
# The implementation of `upper.tri()` si straightforward, but quite interesting as it uses `.row(dim(x)) <= .col(dim(x))` to crate the logical matrix.
# Its subsetting-behaviour will be identical to subsetting with logical matrices, where all elements that correspond to `TRUE` will be selected.
# We don't need to treat this from of subsetting in a special way.

# 4. Why does `mtcars[1:20]` reutrn an error? How does it differ from the similar `mtcars[1:20, ]`?

# When subsetting a data frame with a single vector, it behaves the same way as subsetting a list of the columns, so  mtcars[1:20] would return a data frame of the first 20 columns of the dataset.
# But `mtcars` has only 11 columns, so the index will be out of bounds and an error is thrown.
# `mtcars[1:20, ]` is subsetted with two vectors, so 2d subsetting kicks in, and the first index refers to rows.

# 5. Implement your own function that extracts the diagonal entries from a matrix (it should bahave like `diag(x)` where `x` is a matrix).
diag2 <- function(x) {
  n <- min(nrow(x), ncol(x))
  idx <- cbind(seq_len(n), seq_len(n))
  
  x[idx]
}

# Let's check if it works
(x <- matrix(1:30, 5))

diag2(x)
#> [1]  1  7 13 19 25
diag(x)
#> [1]  1  7 13 19 25

x[.row(dim(x)) == .col(dim(x))]

# 6. What does `df[is.na(df)] <- 0` do? How does it work?

# This expression replaces the `NA`s in `df` with `0`.
# Here `is.na(df)` returns a logical matrix that encodes the position of the missing values in `df`.
# Subsetting and assignment are then combined to replace only the missing values.

# 4.3 Selecting a single element

# There are two other subsetting operators: `[[` is used for extracting single items, while `x$y` is a useful sorthand for `x[["y"]]`.

# 4.3.1 [[

# `[[` is most important when working with lists because subsetting a list with `[` always returns a smaller list.
# To help make this easier to understand we can use a metaphor:

# If list x is a train carrying objects, then x[[5]] is the object in car 5; x[4:6] is a train of cars 4-6.
# — @RLangTip, https://twitter.com/RLangTip/status/268375867468681216

# Let's use this metaphor to make a simple list:
x <- list(1:3, "a", 4:6)

# When extracting a single element, you have two options: you can crate a smaller train, i.e., fewer carriages, or you can extract the contents fo a particular carriage.
# This is the difference between `[` and `[[`:
x[1]
#> [[1]]
#> [1] 1 2 3
x[[1]]
#> [1] 1 2 3

# When extracting multiple (or even zero!) elements, you have to make a smaller train:
x[1:2]
#> [[1]]
#> [1] 1 2 3
#> 
#> [[2]]
#> [1] "a"
x[-2]
#> [[1]]
#> [1] 1 2 3
#> 
#> [[2]]
#> [1] 4 5 6
x[c(1, 1)]
#> [[1]]
#> [1] 1 2 3
#> 
#> [[2]]
#> [1] 1 2 3
x[0]
#> list()

# Because `[[` can return only a single item, you must use it with either a single positive integer or a single string.
# If you use a vector with `[[`, it will subset recursively, i.e. `x[[c(1, 2)]]` is equivalent to `x[[1]][[2]]`.
# This is a quirky feature that few know about, so I recommend avoiding it in favour of `purrr:pluck()`, which you'll learn about in Section 4.3.3.

# While you must use `[[` when working with lists, I'd also recommend using it with atomic vectors whenever you want to extract a single value.
# For exmaple, instead of writing:
for (i in 2:length(x)) {
  out[i] <- fun(x[i], out[i - 1])
}

# It's better to write:
for (i in 2:length(x)) {
  out[[i]] <- fun(x[[i]], out[[i - 1]])
}

# Doign so reinforces the expectation that you are getting and setting individual values.

# 4.3.2 $

# `$` is a shorthand operator: `x$y` si roughly equivalent to `x[["y"]]`.
# It's often used to access variables in a data frame, as in `mtcars$cyl` or `diamonds$carat`.
# One common mistake with `$` is to use it when you have the name of a column stored in a variable:
var <- "cyl"
# Doesn't work - mtcars$var translated to mtcars[["var"]]
mtcars$var
#> NULL

# Instead use [[
mtcars[[var]]
#>  [1] 6 6 4 6 8 6 8 4 4 6 6 8 8 8 8 8 8 4 4 4 4 8 8 8 8 4 4 4 8 6 8 4

# The one important difference between `$` and `[[` is that `$` does (left-to-rigth) partial matching:
x <- list(abc = 1)
x$a
#> [1] 1
x[["a"]]

# To help avoid this behaviour I highly recommend setting the glogal option `warnPartialMatchDollar` to `TRUE`:
options(warnPartialMatchDollar = TRUE)
x$a
#> [1] 1
#> Warning message: In x$a : partial match of 'a' to 'abc'

# (For data frames, you cna also avoid this problem by using tibbles, which never do partial matching.)

# 4.3.3 Missing and out-of-bounds indices

# It’s useful to understand what happens with [[ when you use an “invalid” index. 
# The following table summarises what happens when you subset a logical vector, 
# list, and NULL with a zero-length object (like NULL or logical()), 
# out-of-bounds values (OOB), or a missing value (e.g. NA_integer_) with [[. 
# Each cell shows the result of subsetting the data structure named in the row by the type of index described in the column. 
# I’ve only shown the results for logical vectors, but other atomic vectors behave similarly, 
# returning elements of the same type (NB: int = integer; chr = character).

# |------------|--------------|-----------|-----------|---------|
# | row[[col]] | Zero-length	| OOB (int)	| OOB (chr)	| Missing |
# |------------|--------------|-----------|-----------|---------|
# | Atomic	   | Error	      | Error	    | Error	    | Error   |
# | List	     | Error        |	Error	    | NULL    	| NULL    |
# | NULL	     |NULL          |	NULL      |	NULL	    | NULL    |
# |------------|--------------|-----------|-----------|---------|

# If the vector being indexed is named, then the names of OOB, missing, or NULL components will be <NA>.

# The inconsistencies in the table above led to the development of purrr::pluck() and purrr::chuck(). 
# When the element is missing, pluck() always returns NULL (or the value of the .default argument) and chuck() always throws an error. 
# The behaviour of pluck() makes it well suited for indexing into deeply nested data structures where the component you want may not exist
# (as is common when working with JSON data from web APIs). 
# pluck() also allows you to mix integer and character indices, and provides an alternative default value if an item does not exist:
x <- list(
  a = list(1, 2, 3),
  b = list(3, 4, 5)
)

purrr::pluck(x, "a", 1)
#> [1] 1
purrr::pluck(x, "c", 1)
#> NULL
purrr::pluck(x, "c", 1, .default = NA)

# 4.3.4 @ and slot()

# There are two additional subsetting operators, which are needed for S4 objcts: `@` (equivalent to `$`), and `slot()`(equivalent to `[[`).
# `@` is more restrictive than `$` in that it will return an error if the slot does not exist.
# These are described in more detail in Chapter 15.

# 4.3.5 Exercises 

# 1. Brainstorm as many ways as possible to extract the third value from the cyl variable in the mtcars dataset.

# select coumn first
mtcars$cyl[[3]]
#> [1] 4
mtcars[, "cyl"][[3]]
#> [1] 4
mtcars[["cyl"]][[3]]
#> [1] 4
with(mtcars, cyl[[3]])
#> [1] 4

# Select row first
mtcars[3, ]$cyl
#> [1] 4
mtcars[3, "cyl"]
#> [1] 4
mtcars[3, ][, "cyl"]
#> [1] 4
mtcars[3, ][["cyl"]]
#> [1] 4

# select simultaneously
mtcars[3, 2]
#> [1] 4
mtcars[[c(2, 3)]]
#> [1] 4

# 2. Given a linear model, e.g., mod <- lm(mpg ~ wt, data = mtcars), extract the residual degrees of freedom. 
#    Then extract the R squared from the model summary (summary(mod))

# `mod` has the type list, which opens up several possibilities:
mod <- lm(mpg ~ wt, data = mtcars)
mod$df.residual        # output preserved
#> [1] 30
mod$df.res
#> [1] 30
mod[["df.residual"]]  # `$` allows partial matching
#> [1] 30
mod["df.residual"]    # output preseved
#> $df.residual       # list outputß
#> [1] 30

# The same also applies to `summary(mod)`, so we could use i.e.:
summary(mod)$r.squared
# (Tip: The broom-package provides a very useful approach to work with models in a tidy way).

# 4.4 Subsetting and assigment

# All subsetting operators can be combined with assignment to modify selected values of an input vector: this is called subassignment.
# The basic form is `x[i] <- value`:
x <- 1:5
x[c(1, 2)] <- c(101, 102)
x
#> [1] 101 102   3   4   5

# I recommend that you should make sure that `length(value)` is the same as `length(x[i])`, and that `i` is unique.
# This is because, while R will recycle if needed, those rules are complex (partibularly if `i` contains missing or duplicated values) and may cause problems.

# With lists, you can use `x[[i]] <- NULL` to remove a component.
# To add a literal `NULL`, use `x[i] <- list(NULL)`:
x <- list(a = 1, b = 2)
x[["b"]] <- NULL
str(x)

y <- list(a = 1, b = 2)
y["b"] <- list(NULL)
str(y)

# Subsetting with nothin can be useful with assignment because it preserves the structrue of the original object. Compare the following tow expressions.
# In the first, `mtcars` remains a data frame because you are only changed the contents of `mtcars`, not `mtcars` itself.
# In the second, `mtcars` becomes a lsit because you are changing the object it is bound to.
mtcars[] <- lapply(mtcars, as.integer)
is.data.frame(mtcars)
#> [1] TRUE

mtcars <- lapply(mtcars, as.integer)
is.data.frame(mtcars)
#> [1] TRUE

# 4.5 Applications

# This principles described above have a wide variety of useful applications.
# Some of the most important are described below.
# While many of the basic principle of subsetting have already been incorporated into funcitons like `subset()`, `merge()`, `dplyr::arrange()`, 
# a deeper understanding of how those principles have been implimented will be valuable when you run into situations wherer the functions you need don't exist.

# 4.5.1 Loopup tables (character subsetting)

# Character matching is a powerful way to create loopup tables.
# Say you want ot convert abbreviations:
x <- c("m", "f", "u", "f", "f", "m", "m")
lookup <- c(m = "Male", f = "Female", u = NA)
lookup[x]
#>        m        f        u        f        f        m        m 
#>   "Male" "Female"       NA "Female" "Female"   "Male"   "Male"

# Note that if you don't want names in the result, use `unname()` to remove them.
unname(lookup[x])
#> #> [1] "Male"   "Female" NA       "Female" "Female" "Male"   "Male"

# 4.5.2 Matching and merging by hand (integer subsetting)

# You can also have more complicated lookup tables with multiple columns of information.
# For exmaple, suppose we have a vector of integer grades, and a table that describes their properties:
grades <- c(1, 2, 2, 3, 1)

info <- data.frame(
  grade = 3:1,
  desc = c("Excellent", "Good", "Poor"),
  fail = c(F, F, T)
)

# Then, let’s say we want to duplicate the info table so that we have a row for each value in grades. 
# An elegant way to do this is by combining match() and integer subsetting (match(needles, haystack) returns the position where each needle is found in the haystack).
id <- match(grades, info$grade)
id
#> [1] 3 2 2 1 3
info[id, ]
#>     grade      desc  fail
#> 3       1      Poor  TRUE
#> 2       2      Good FALSE
#> 2.1     2      Good FALSE
#> 1       3 Excellent FALSE
#> 3.1     1      Poor  TRUE

# If you’re matching on multiple columns, you’ll need to first collapse them into a single column (with e.g. interaction()). 
# Typically, however, you’re better off switching to a function designed specifically for joining multiple tables like merge(), or dplyr::left_join().

# 4.5.3 Random smaples and bootstraps (integer subsetting)

# You can use integer indices to randomly sample or bootstrap a vector or data frame.
# Just use `sample(n)` to genreate a ransom permutation of `1:n`, and then use the results to subset the values:
df <- data.frame(x = c(1, 2, 3, 1, 2), y = 5:1, z = letters[1:5])

# Randomly reorder
df[sample(nrow(df)), ]
#>   x y z
#> 5 2 1 e
#> 3 3 3 c
#> 4 1 2 d
#> 1 1 5 a
#> 2 2 4 b

# Select 3 random rows
df[sample(nrow(df), 3), ]
#>   x y z
#> 4 1 2 d
#> 2 2 4 b
#> 1 1 5 a

# Select 6 bootstrap replicates
df[sample(nrow(df), 6, replace = TRUE), ]
#>     x y z
#> 5   2 1 e
#> 5.1 2 1 e
#> 5.2 2 1 e
#> 2   2 4 b
#> 3   3 3 c
#> 3.1 3 3 c

# The arguments of `sample()` control the number of samples to extract, and also whether sample is done with or without replacement.

# 4.5.4 Ordering (integer subsetting)

# `order()` takes a vector as its input and returns an integer vector describing how to order the subsetted vector:
x <- c("b", "c", "a")
order(x)
#> [1] 3 1 2
x[order(x)]
#> [1] "a" "b" "c"

# To break ties, you can supply additional variables to order(). 
# You can also change the order from ascending to descending by using decreasing = TRUE.
# By default, any missing values will be put at the end of the vector; 
# however, you can remove them with na.last = NA or put them at the front with na.last = FALSE.

# For two or more dimensions, `order()` and integer subsetting makes it easy to order either the rows or columns of an object:

# Randomly reorder df
df2 <- df[sample(nrow(df)), 3:1]
#>   z y x
#> 4 d 2 1
#> 1 a 5 1
#> 2 b 4 2
#> 3 c 3 3
#> 5 e 1 2

df2[order(df2$x), ]
#>   z y x
#> 4 d 2 1
#> 1 a 5 1
#> 2 b 4 2
#> 5 e 1 2
#> 3 c 3 3

df2[order(names(df2))]
#>   x y z
#> 4 1 2 d
#> 1 1 5 a
#> 2 2 4 b
#> 3 3 3 c
#> 5 2 1 e

# You can sort vectors directly with `sort()`, or similarly `dplyr::arrange()`, to sort a data frame.

# 4.5.5 Expanding aggregated counts (integer subsetting)

# Sometimes you get a data frame where identical rows have been collapsed into one and a count column has been added.
# `rep()` and integer subsetting make it easy to uncollapse, because we can take advantage of `rep()`s vectorisation: `rep(x, y)` repeats `x[i] y[i]` times.
df <- data.frame(x = c(2, 4, 1), y = c(9, 11, 6), n = c(3, 5, 1))
rep(1:nrow(df), df$n)
#> [1] 1 1 1 2 2 2 2 2 3
df[rep(1:nrow(df), df$n), ]
#>     x  y n
#> 1   2  9 3
#> 1.1 2  9 3
#> 1.2 2  9 3
#> 2   4 11 5
#> 2.1 4 11 5
#> 2.2 4 11 5
#> 2.3 4 11 5
#> 2.4 4 11 5
#> 3   1  6 1

# 4.5.6 Removing columns from data frames (character)

# There are two ways to remove columns from a data frame.
# You can set individual columns to `NULL`:
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df$z <- NULL

# Or you can subset to return only the columns yuo want:
df <- data.frame(x = 1:3, y = 3:1, z = letters[1:3])
df[c("x", "y")]
#>   x y
#> 1 1 3
#> 2 2 2
#> 3 3 1

# If yo only know the columns you don't want, use set operations to work out which cloumns to keep:
df[setdiff(names(df), "z")]
#>   x y
#> 1 1 3
#> 2 2 2
#> 3 3 1

# 4.5.6 Selecting rows based on a condition (logical subsetting)

# Because logical subsetting allows you to easily combine conditions from multiple columns, it's probably the most commonly used technique for extracting rows out of a data frame.
mtcars[mtcars$gear == 5, ]
#>                 mpg cyl  disp  hp drat   wt qsec vs am gear carb
#> Porsche 914-2  26.0   4 120.3  91 4.43 2.14 16.7  0  1    5    2
#> Lotus Europa   30.4   4  95.1 113 3.77 1.51 16.9  1  1    5    2
#> Ford Pantera L 15.8   8 351.0 264 4.22 3.17 14.5  0  1    5    4
#> Ferrari Dino   19.7   6 145.0 175 3.62 2.77 15.5  0  1    5    6
#> Maserati Bora  15.0   8 301.0 335 3.54 3.57 14.6  0  1    5    8

mtcars[mtcars$gear == 5 & mtcars$cyl == 4, ]
#>                mpg cyl  disp  hp drat   wt qsec vs am gear carb
#> Porsche 914-2 26.0   4 120.3  91 4.43 2.14 16.7  0  1    5    2
#> Lotus Europa  30.4   4  95.1 113 3.77 1.51 16.9  1  1    5    2

# Remember to use the vector boolean operators `&` and `|`, not the shotr-curcuiting scalar operators `&&` and `||`, which are more useful iinside if statements.
# And don't forget De Morgan's laws, which can be useful to simplify negations:

# - `!(X & Y)` is the same as `!X & !Y`
# - `!(X | Y)` is the same as `!X | !Y`

# For exmaple, `!(X & Y | Z)` simplifies to `!X | !!(Y | Z)`, and then to `!X | Y | Z`.

# 4.5.8 Boolean algebra versus sets (logical and integer)

# It's useful to be aware of the natural equivalence between set operations (integer subsetting) and Boolean algebra (logical subsetting).
# Using set operation is more effective when:

# - You want to find the first (or last) `TRUE`.
# - You have very few `TRUE`s and very many `FALSE`s;; a set representatino may be faster and require less storage.

# `which()` allows you to convert a Boolean representation to an integer represnetation.
# There's no reverse operation in base R but we can easily create one:
x <- sample(10) < 4
which(x)
#> [1] 1 4 6

unwhich <- function(x, n) {
  out <- rep_len(FALSE, n)
  out[x] <- TRUE
  out
}
unwhich(which(x), 10)
#>  [1]  TRUE FALSE FALSE  TRUE FALSE  TRUE FALSE FALSE FALSE FALSE

# Let's create two logical vectors and their intefer equivalents, and then explore the relationship between Boolean and set operations.
(x1 <- 1:10 %% 2 == 0)
#>  [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE
(x2 <- which(x1))
#> [1]  2  4  6  8 10
(y1 <- 1:10 %% 5 == 0)
#> [1] FALSE FALSE FALSE FALSE  TRUE FALSE FALSE FALSE FALSE  TRUE
(y2 <- which(y1))
#> [1]  5 10

# X & Y <-> intersect(x, y)
x1 & y1
#>  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE  TRUE
intersect(x2, y2)
#> [1] 10

# X | Y <-> union(x, y)
x1 | y1
#>  [1] FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE FALSE  TRUE
union(x2, y2)
#> [1]  2  4  6  8 10  5

# X & !Y <-> setdiff(x, y)
x1 & !y1
#>  [1] FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE  TRUE FALSE FALSE
setdiff(x2, y2)
#> [1] 2 4 6 8

# xor(X, Y) <-> setdiff(union(x, y), interset(x, y))
xor(x1, y1)
#> [1] FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE  TRUE FALSE FALSE

# When first learning subsetting, a common mistake is to use `x[which(y)]` instead of `x[y]`.
# Here the `which()` achieves nothing: it switches from logical to integer subsetting but the result is exactly the same.
# In more general cases, there are two important differences.

# - When the logical vector contains `NA`, logical subsetting replaces these values with `NA` whicl `which()` simply drops these values.
#   It's not uncommon to use `which()` for this side-effect, but I don't recommend it: nothing about the name "which" implies the removal of missing values.

# - `x[-which(y)]` is __not__ equivalent to `x[!y]`: if `y` is all FALSE, `which(y)` will be `integer(0)` and `-integer(0)` is still `integer(0)`, 
#    so you'll get no values, instead of all values.

# In general, avoid switching from logical to integer subsetting unless  you want, for exmaple, the first or last `TRUE` value.

# 4.9.5 Exercises 

# 1. How would you randomly permute the columns of a data frame? 
#    (This is an important technique in random forests.) 
#    Can you simultaneously permute the rows and cloumns in one step?

# Permute columns
iris[sample(ncol(iris))]

# Permute columns and rows in one step
mtcars[sample(nrow(mtcars)), sample(ncol(mtcars)), drop = FALSE]

# 2. How would you select a random sample of `m` rows from a data frame?
#    What if the sample had to be contiguous
#    (i.e., with an initial row, a final row, and every row in between)?

# Selecting `m` random rows from a data frame can be achieved through subsetting.
m <- 10
iris[sample(nrow(iris), m), , drop = FALSE]

# Keeping subsequent rows together as a “blocked sample” requires only some caution to get the start- and end-index correct.
start <- sample(nrow(iris) - m + 1, 1)
end <- start + m - 1
iris[start:end, , drop = FALSE]

# How could you put the columns in a data frame in alphabetical order?
mtcars[sort(names(mtcars))]
mtcars[order(names(mtcars))]

# 4.6 Quiz answers

# 1. Positive integers select elements at specific position, negative integers drop elements;
#    logicla vectors keep elements at positions corresponging to `TRUE`;
#    character vectors select elements with matching names.

# 2. `[` sleects sub-lists: it always returns a list.
#     If you use it with a single positive  integer, it returns a list of length one.
#     `[[` select an elemnt within a list.
#     `$` is a convenient shorthand: `x$y` si equivalent to `x[["y"]]`.

# 3. Use `drop = FALSE` if you are subsetting a matrix, array, or data frame and you wnat to preserve the original dimensions.
#    You should almost always use it when subsetting inside a funciton.

# 4. If `x` is a matrix, `x[] <- 0` will replace every element with 0, keeping the same number of rows and columns.
#    In contrast, `x <- 0` completely replaces the matrix with the value 0.

# 5. A named character vector can act as a simple lookup table: `c(x = 1, y = 2, z = 3)[c("y", "z", "x")]`



















