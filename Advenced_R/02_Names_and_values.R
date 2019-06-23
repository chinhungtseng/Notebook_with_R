set.seed(1014)

library(tidyverse)

# 02 Names and values

# Introduction =========================================================================================================================================

# To start your journey in mastering R, the following six chapters will help you learn the foundational componenets of R.

# 1. Chapter 2 teaches you about the difference between an object and its name.
# 2. Chapter 3 dives into the details of vectors, attributes, and form the basis for two of R's object-oriented programming toolkits.
# 3. Chapter 4 describes how to use subsetting to write clear, condise, and effcient R code.
# 4. Chapter 5 presents tools of control flow that allow you to only execute code under certain conditions, or to repeatedly execute code with changing inputs.
# 5. Chapter 6 deals with functions, the most important building blocks of R code.
# 6. Chapter 7 describes a data structure that is crucial for understanding how R works.
# 7. Chapter 8 concludes the foundations of R with an exploration of "conditions", the umbrella term used to describe errors, warnings, and messages.

# ======================================================================================================================================================

# 2 Names and values

# 2.1 Inroduction

# In R, it is important to understand the distinction between an object and its name.
# Doing so will help you:

# - More accurately predict the performance and memory usage of your code.
# - Write faster code by avoiding accidental copies, a major source of slow code.
# - Better understand R's functional programming tools.

# The goal of this chapter is to help you understand the distinction between names and values, and when R will copy an object.

# Quiz

# Answer the following questions to see if you can safely skip this chapter. You can find the answers at the end of the chapter in Section 2.7.

# 1. Given the following data grame, how do I create a new column called "3" that contaoins the sum of `1` and `2`?
#    You may only use `$`, not `[[`. What makes `1`, `2`, and `3` challenging as variable names?
df <- data.frame(runif(3), runif(3))
names(df) <- c(1, 2)

# my solution
df$`3` <- df$`1` + df$`2`

# 2. In the following code, how much memory does `y` occupy?
x <- runif(1e6)
y <- list(x, x, x)

# my solution 
object.size(x)
#> the size of y is `8000048 bytes`
# y: x + a object of list = 8000048 bytes + 48 bytes = 8000096 byte.

# 3. On which line does `a` get copied in the following example?
a <- c(1, 5, 3, 2)
b <- a
b[[1]] <- 10

# my solution
# In the line 3.

# Outline 

# - Section 2.2 introduces you to the distinction between names and values, and discusses how `<-` creates a binding, or reference, between a name and a value.

# - Seciton 2.3 describes when R makes a copy: whenever you modify a vector, you're almost certainly creating a new, modified vector.
#   You'll learn how to use `tracemem()` to figure out when a copy actually occurs.
#   then you'll explore the implications as they apply to function calls, lists, data grames, and character vectors.

# - section 2.4 explores teh implicaitions of the previous two sections on how much memory an object occupies.
#   Since your intuition may be profoundly wrong and dince `utils::object.size()` is unfortunately inaccurate, you'l learn how to use `lobstr::obj_size()`.

# - section 2.5 describes the two important exceptions to copy-on-modify: with environments and values with a single name, objects are actually modified in place.

# - Section 2.6 concludes the chapter with a discussion of th garbage collector, which frees up the memory used by objects no longer referenced by a name.

# Prerequisites

# We'll use the `lobstr` package to dig into the internal representation of R objects.
library(lobstr)

# Sources

# The details of R's memory management are not documented in a single place.
# Much of the information in this chapter was gleaned from a close reading of teh documentation (particularly `?memory` and `?gc`), the memory profilling section fo Writing R extensions (R Core Team 2018b), and the SEXPs section fo R internals(R Core Team 2018a).
# Teh reast I figured out by reading the C source code, performing small experiments, and asking questions on R-deval. Any mistakes are entirely mine.

# 2.2 Binding basics

# Consider this code:
x <- c(1, 2, 3)

# It's easy to read it as: "create an object named 'x', containing the values 1, 2, and 3".
# Unfortunately, that's a simplification that will lead to inaccurate predictions about what R is actually doing behind the scenes.
# It's more accurate to say that this code is doing two things:

# - It's creating an object, a vector of values, `c(1, 2, 3)`.
# - And it's binding that object to a name, `x`.

# In other words, the object, or value, doesn't have a name; it's actually the name that has a value.

# To further clarify this distinction, I'll draw diagrams like this:

# The name, `x` is drawn with a rounded rectangle. It ahs an arrow that points to (or binds or references) the value, the vector `c(1, 2, 3)`.
# the arrow points in opposite direction to the assignment arrow: `<-` creates a binding from the name on the left-hand side to the ovject on the right-hand side.

# Thus, you can think of a name as a refernece to a value. For example, if you fun this code, you don't get another copy of the value `c(1, 2, 3)`, you get another binding to the existing object:
y <- x

# You might have noticed that the value `c(1, 2, 3)` has a label: `0x74b`. While the vector doesn't have a name, I'll occasionally need to refer to an object independent of its bindings.
# To make that possible , I'll label values with a unique identifier. These identifiers have a special form that looks like the object's memory "address", i.e. the location in memory where the object is stored.
# But because the actual memory addresses changes every time the code is run, we use these identifiers instead.

# You can access an object's identifier with `lobstr::obj_adddr()`. Doing so allows you to see that both `x` and `y` point to the smae identifier:
obj_addr(x)
#> [1] "0x10f31cd18"
obj_addr(y)
#> [1] "0x10f31cd18"

# These identifiers are long, and change every time you restart R.

# It can take some time to get your head around the distinction between names and values, but understanding this is really helpful in functional programming where functions can have different names in different contexts.

# 2.2.1 Non-syntactic names

# R has strict rules about what constitutes a valid name. A __syntactic__ name must consist of letters, digits, `.` and `_` but can't begin with `_` or a digit.
# Additionally, you can't use any of the __reserved words__ like `TRUE`, `NULL`, `if`, and `function` (see the complete list in `?Resered`). 
# A name that doesn't follow these rules is a _non-syntacitc__ name; if you try to use them, you'll get an error:
# _abc <- 1
#> Error: unexpected input in "_"
# if <- 10
#> Error: unexpected assignment in "if <-"

# It's possible to override these rules and use any name, i.e., any sequence of characters, by surrounding it with backticks:
`_abc` <- 1
`_abc`
#> [1] 1
`if` <- 10
`if`
#> [1] 10

# > You can also create non-syntactic bindings using single or double quotes (e.g. "_abc" <- 1) instead of backticks, but you shouldn’t, because you’ll have to use a different syntax to retrieve the values.
# > The ability to use strings on the left hand side of the assignment arrow is an historical artefact, used before R supported backticks.

# 2.2.2 Exercies 

# 1. Explain the relationship between `a`, `b`, `c`, and `d` in the following code:
a <- 1:10
b <- a
c <- b
d <- 1:10

list_of_names <- list(a, b, c, d)
lobstr::obj_addrs(list_of_names)
#> [1] "0x2b18620" "0x2b18620" "0x2b18620" "0x299e968"

# a, b, c points to the same object (with the same address in memory). This object has the value 1:10. 
# d points to a different object with the same value.

# 2. The following code accesses the mean fucntion in multiple ways.
#    Do they all point to the same underlying function object? Verify this with `lobstr::obj_addr()`.
mean
base::mean
get("mean")
evalq(mean)
match.fun("mean")

mean_functions <- list(mean, 
                       base::mean,
                       get("mean"),
                       evalq(mean),
                       match.fun("mean"))
unique(obj_addrs(mean_functions))
#> [1] "0x1025238b0"

# Yes, they point to the same object. We confirm this by inspecting the address of the underlying function object.

# 3. By default, base R data import functions, like `read.csv()`, will automatically convert non-syntactic names to syntactic ones.
#    Why might this be problematic? What option allows you to suppress this behaiour?
?read.csv

# When automatic and implicit (name) conversion occurs, the prediction of a scripts output will b more difficult.
# For example when R is used non-interactively and some data is read, transformed and written, then the output may not contain the same names as the original data source.
# This behaviour may introduce problems in downstream analysis. To avoid automatic name conversion set `check.names = FALSE`.

# 4. What rules does `make.names()` use to convert non-syntactic names into syntacitc ones?
?make.names()

# A valid name starts with a letter or a dot(which must not be followed by a number).
# It also consists of letters, unbers, dots and underscores only (`"_"` aer allowed since R version 1.9.0).

# Three main mechanisms ensure syntactially valid names (see `?make.nanmes`):

# - The variable name will be prepended by an `X` when names do not start with a letter or start with a dot followed by a number
make.names("")
#> [1] "X"
make.names(".1")
#> [1] "X.1"

# - (additionally) non-valid characters are replaced by a dot
make.names("@")          # prepending + . replacement
#> [1] "X."
make.names("  ")         # prepending + .. replacement
#> [1] "X.."
make.names("non-valid")  # . replacement 
#> [1] "non.valid"

# - reserved R keywords (see `?reserved`) are suffixed by a dot
make.names("if")
#> [1] "if."

# 5. I slightly simplified the rules that govern syntactic names. Why is .123e1 not a syntactic name? Read ?make.names for the full details.

# `.123e1` is not a syntactic name, because it starts with one dot which is followed b a number.
# This makes it a double, `1.23`.

# 2.2 Copy-on-modify

# Consider the following code. It binds `x` and `y` to the same underying value, then modifies `y`.
x <- c(1, 2, 3)
y <- x

y[[3]] <- 4
x
#> [1] 1 2 3

# Modifying `y` clearly didn't modify `x`. So what happened to the shared binding?
# While thevalues associated with `y` changed, the original object did not.
# Instread, R created a new object, `0xcd2`, a copy of `0x74b` with one value changed, then rebound `y` to that object.

# This behaviour is called __copy-on-modify__. Understandign it will radically improve your intuition about the performance fo R code.
# A related way to describe this behaviour is to say that R objects are unchangeable, or __immutable__.
# However, I'll generally avoid that term because there are a couple of important exceptions to copy-on-modify that you'll learn about in Section 2.5.

# When exploring copy-on-modify behaviour interactively, be aware that you'll get different results inside of RStudio.
# That's because the envionment pane must make a reference to each object in order to display information about it.
# This distorts your interactive exploration but doesn't affect code inside of functions, and so doesn't affect performance during data analysis.
# For experimentation, I recommend either runnign R directly from the terminal, or using RMarkdown(like this book).

# 2.3.1 tracemem()

# You can see when an object gets copied with the help of base::tracemem().
# Once you call that function with an object, you'll get the object's current address:
x <- c(1, 2, 3)
cat(tracemem(x), "\n")
#> <0x112c452c8> 

# From then on, whenever that object is copied, `tracemem()` will print a meassage telling you which object was copied, its new address, and the sequence of calls that led to the copy:
y <- x
y[[3]] <- 4L
#> tracemem[0x112c452c8 -> 0x112c4db88]: 

# If you modify `y` again. it won't get copied. That's because th new object now only has single name bound to it, so R applies modify-in-place optimisation.
# We'll come back to this in Setion 2.5.
y[[3]] <- 5L
#> tracemem[0x112c4db88 -> 0x112c41318]:

untracemem(x)

# `untracemem()` is the opposite of `tracemem()`; it turns tracign off.

# 2.3.2 Function calls 

# The same rules for copying also apply to funciton calls. Take this code:
f <- function(a) {
  a
}

x <- c(1, 2, 3)
cat(tracemem(x), "\n")
#> <0x10fdff8a8> 

z <- f(x)
# there's no copy here!

untracemem(x)

# While `f()` is running, the `a` inside the function points to the same values as the `x` does outside the function:

# You'll learn more about the concentions used in this diagram in Section 7.4.4. In brief: the function `f()` si depicted by the yellow object on the right.
# It has a formal argument, `a`, which becomes a binding (indicated by dotted black line) in the execution environment (the gray box) when the function is run.

# Once `f()` completes, `x` and `z` will points to the same object. `0x74b` nevergets copied because it never gets modified.
# If f() did modify `x`, R would create a new copy, and then `z` would bind that object.

# 2.3.3 Lists 

# It's not just names(i.e. variables) that point to values; elements of list do too.
# Consider this list, which is superficially very similar to the numeric vector above:
l1 <- list(1, 2, 3)

# This list is more compolex because instead of storing the vlues itself, it stores references to them:

# This is particularly important when we modefy a list:
l2 <- l1
l2[[3]] <- 4

# Like vectors, lists use copy-on-modiify behaviour; the original list is left unchanged, and R creates a modifued copy.
# This, however, is a __shallow__ copy: the list object and its bindings are copied, but the values pointed to by the bindings are not.
# The opposite of a shallow copy is a deep copy where the contents of every reference are copied.
# Prior to R 3.1.0, copies were always deep copied.

# To see values that are shared across liests, use `lobstr::ref()`. 
# `ref()` prints the memeory address fo each object, along with a local ID so that you can easily cross-reference shared components.
ref(l1, l2)
#> █ [1:0x112c49a98] <list> 
#>   ├─[2:0x110c0f7d0] <dbl> 
#>   ├─[3:0x110c0f808] <dbl> 
#>   └─[4:0x110c0f840] <dbl> 
#>   
#>   █ [5:0x112c33ae8] <list> 
#>   ├─[2:0x110c0f7d0] 
#>   ├─[3:0x110c0f808] 
#>   └─[6:0x10f3385d8] <dbl>

# 2.3.4 Data frames

# Data frames are lsits of vectors, so copy-on-modify has important consequences when you modify a data frame.
# Take this data frame as an example:
d1 <- data.frame(x = c(1, 5, 6), y = c(2, 4, 3))

# If you modify a column, only that column needs to be modified; the others will still point to their orginal references:
d2 <- d1
d2[, 2] <- d2[, 2] * 2

# However, if you modify a row, every columns is modified, which means every column must be copied:
d3 <- d1
d3[1, ] <- d3[1, ] * 3

ref(d1, d2, d3)
#> █ [1:0x10bf1b888] <df[,2]> 
#>   ├─x = [2:0x112bba288] <dbl> 
#>   └─y = [3:0x112bba2d8] <dbl> 
#>   
#>   █ [4:0x1121d62c8] <df[,2]> 
#>   ├─x = [2:0x112bba288] 
#>   └─y = [5:0x112bb17c8] <dbl> 
#>   
#>   █ [6:0x1121c9708] <df[,2]> 
#>   ├─x = [7:0x112baa0a8] <dbl> 
#>   └─y = [8:0x112baa0f8] <dbl> 

# 2.3.5 Character vectors

# The final place that R users references is with character vectors.
# I usually draw character vetors like this:
x <- c("a", "a", "abc", "d")

# But this is a polite fiction. R actually uses a __global string pool__ where each elememt of a character vector is a pointer to a unique string in the pool:

# You can request that `ref()` show these refenerces by setting the `character` argument to `TRUE`:
ref(x, character = TRUE)
#> █ [1:0x112bb8fa8] <chr> 
#>   ├─[2:0x103066320] <string: "a"> 
#>   ├─[2:0x103066320] 
#>   ├─[3:0x114e0e140] <string: "abc"> 
#>   └─[4:0x10240bc08] <string: "d"> 

# This has a profound impact on the amount of memory a character vector uses but is otherwise generally unimportant, so elsewhere in the book I'll draw character vectors as if the strings lived inside a vector.

# 2.3.6 Exercises

# 1. Why is `tracemem(1:10) not useful`?

# When `1:10` is called an object with an address in memory is created, but it is not bound to a name.
# Therefore the object cannot be called or manipulated from R. As no copies will be made, it is not useful to track the object for copying.

obj_addr(1:10)    # The object exists, but has no name
#> [1] "0x10b4ad800"

# 2. Explain why `tracemem()` shows two copies when you run this code.
#    Hint: carefully look at the difference between this code and the code shown earlier in the section.
x <- c(1L, 2L, 3L)
tracemem(x)
#> [1] "<0x112197a08>"
x[[3]] <- 4
#> tracemem[0x112197a08 -> 0x112d0f548]: 
#> tracemem[0x112d0f548 -> 0x1122e5368]: 

# Initially the vector `x` has integer type. The replacement call assigns a double to the third element of `x`, which triggers copy-on-modify:

# two copies
x <- 1:3
tracemem(x)
#> [1] "<0x10c44f6c8>"
x[[3]] <- 4L
#> tracemem[0x10c44f6c8 -> 0x10fe00a88]: 
#> tracemem[0x10fe00a88 -> 0x112bb2008]: 

# We can avoid the copy by sub-assigning an integer instead of a double:

# the same as 
x <- 1:3
tracemem(x)
#> [1] "<0x118b78c10>"
x[[3]] <- 4L
#> tracemem[0x118b78c10 -> 0x11233c948]: 

untracemem(x)

# 3. Sketch out the relatoinship between the followign objects:
a <- 1:10
b <- list(a, a)
c <- list(b, a, 1:10)

ref(c)
#> █ [1:0x1123080a8] <list>         # c
#>   ├─█ [2:0x112322e88] <list>     # - b
#>   │ ├─[3:0x10d295690] <int>      # -- a
#>   │ └─[3:0x10d295690]            # -- a
#>   ├─[3:0x10d295690]              # - a 
#>   └─[4:0x110fc70a0] <int>        # - 1:10

# `a` contins a reference to an address with the value `1:10`. 
# `b` contains a list of two references to the same address as `a`.
# `c` contains a list of `b` (containing two references to `a`), 
#    `a` (containing the same reference again) and a reference pointing to a different address containg the same value 1:10

# 4. What happens when you run this code?
x <- list(1:10)
x[[2]] <- x

# The initial reference tree of `x` shows, that the name `x` binds to a list object.
# This object contains a reference to the integer vector `1:10`.
x <- list(1:10)
ref(x)
#> █ [1:0x10d647390] <list> 
#>   └─[2:0x10daeae78] <int>  

#           0x10d64
# |---|    |---|
# | x |--->| O |
# |---|    |-|-|
#            |
#            v  0x10dae
#  |---|---|---|---|
#  | 1 | 2 |...| 10|
#  |---|---|---|---|

# When `x` is assigned to an element of itself copy-on-modify takes place and the list is coped to a new address in memory.
tracemem(x)
#> [1] "<0x10d647390>"
x[[2]] <- x
#> tracemem[0x10d647390 -> 0x11238b5f0]: 

# The list object previously bound to `x` is now referenced in the newly created list object.
# It is no longer bound to a name. The integer vector is referenced twice.
ref(x)
#> █ [1:0x112c6de88] <list> 
#>   ├─[2:0x10daeae78] <int> 
#>   └─█ [3:0x10d647390] <list> 
#>   └─[2:0x10daeae78] 

#           0x10d64
#          |---|
#          | O | <--------|
#          |-|-|          |
#            |            |
#            v  0x10dae   |
#  |---|---|---|---|      |
#  | 1 | 2 |...| 10|      |
#  |---|---|---|---|      |
#            ^    0x112c  |
# |---|    |-|-|---|      |
# | x |--->| O | O |------|
# |---|    |---|---|

# 2.4 Object size

# You can find out how much memeory an object takes with `lobstr::obj_size()`:
obj_size(letters)
#> 1,712 B
obj_size(ggplot2::diamonds)
#> 3,456,344 B

# Since the elements of lists are references to values, the size fo a list might be much smaller than you expect:
x <- runif(1e6)
obj_size(x)
#> 8,000,048 B

y <- list(x, x, x) 
obj_size(y)
#> 8,000,128 B

# `y` is only 80 bytes bigger than `x`. That's the size of an empty list with three elements:
obj_size(list(NULL, NULL, NULL))
#> 80 B

# Similarly, because R uses a global string pool character vectors take up less memeory than you might expect: repeating a string 100 times does not make up 100 times as much memory.
banana <- "bananas bananas bananas"
obj_size(banana)
#> 136 B
obj_size(rep(banana, 100))
#> 928 B

# References also make ti challenging to think about the size of individual objects.
# `obj_size(x) + obj_size(y)` will only equal `obj_size(x, y)` if there are no shared values.
# Here, the combined size of `x` and `y` is the same as the size of `y`:
obj_size(x, y)
#> 8,000,128 B

# Finally, R 3.5.0 and later versoins have a feature that might lead to surprises: ALTREP, short for __alternative representation___.
# This allow R to represent certain types of vectors very compactly. The place you are most likely to see this is with `:` because instead of stroing every single numer in the sequence, 
# R just stores the first and last number. This means that every sequence, no matter how large, is the same size:
obj_size(1:3)
#> 680 B
obj_size(1:1e3)
#> 680 B
obj_size(1:1e6)
#> 680 B
obj_size(1:1e8)
#> 680 B

# 2.4.1 Exercises 

# 1. In the following example, why are `object.size(y)` and `obj_size(y)` so redically different?
#    Consult the documentation of `object.size()`.
y <- rep(list(runif(1e4)), 100)

object.size(y)
#> 8005648 bytes
obj_size(y)
#> 80,896 B

# `object.size()` doesn't account for shared elements within lists.
# Therefore, the results differ by a factor of ~100.

# 2. Take the following list. Why is its size somewhat misleading?
funs <- list(mean, sd, var)
obj_size(funs)
#> 17,608 B

# It is some what misleading, because all three functoins are built-in to R as part of the base and stats packages and hence always available.
# From the following calculations we can see that this applies to about 2400 objects usually loaded by default.
base_pkgs <- c(
  "package:stats", "package:graphics", "package:grDevices",
  "package:utils", "package:datasets", "package:methods",
  "package:base"
)
base_envs <- lapply(base_pkgs, as.environment)
names(base_envs) <- base_pkgs
base_objs <- lapply(base_envs, function(x) mget(ls(x), x))

sum(lengths(base_objs))
#> [1] 2398

# Show sizes in MB
base_sizes <- vapply(base_objs, obj_size, double(1)) / 1024^2
base_sizes
#> package:stats  package:graphics package:grDevices 
#> 10.7768707         3.0472107         1.7396393 
#> package:utils  package:datasets   package:methods 
#> 56.6843262         0.5561066         6.4644699 
#> package:base 
#> 10.8987808

sum(base_sizes)
#> [1] 90.1674

# Check if we've over-counted
as.numeric(obj_size(!!!base_objs)) / 1024^2
#> [1] 67.31561

# 3. Predict the output of the following code:
a <- runif(1e6)
obj_size(a)

b <- list(a, a)
obj_size(b)
obj_size(a, b)

b[[1]][[1]] <- 10
obj_size(b)
obj_size(a, b)

b[[2]][[1]] <- 10
obj_size(b)
obj_size(a, b)

# In R (on most platforms) a length-0 vactor has 48 bytes of overhead:
obj_size(list())
#> 48 B
obj_size(double())
#> 48 B
obj_size(character())
#> 48 B

# A single double takes up an additional 8 bytes of memory:
obj_size(double(1))
#> 56 B
obj_size(double(2))
#> 64 B

# So 1 million double should take up 8,000,048 bytes:
obj_size(double(1e6))
#> 8,000,048 B

# (If you look carefully at the amount of memory occupied by short vectors, you’ll notice that the pattern is actually more complicated. 
# This is to do with how R allocates memory, and is not that important. If you want to know the full details, they’re discussed in the 1st edition of Advanced R: http://adv-r.had.co.nz/memory.html#object-size)

# In `b <- list(a, a)` both list elements of `b` contain references to the same memory address, so no additional memory is required for the second list element.
# The list itself requires 64 bytes, 48 bytes for an empty list and 8 bytes for each element (`obj_size(vector("list', 2))`).
# This let's us predict 8000048 B + 64 B = 8000112 B:
b <- list(a, a)
obj_size(b)
#> 8,000,112 B

obj_size(a, a)
#> ,000,048 B
ref(a, b)
#> [1:0x11e7a2000] <dbl> 
#>   
#>   █ [2:0x11225a8c8] <list> 
#>   ├─[1:0x11e7a2000] 
#>   └─[1:0x11e7a2000] 

# When we modify the first element of `b[[1]]` copy-on-modify occurs and the object will have the same size (8000040 bytes) and a new address in memory.
# So `b`'s elements don't share references anymore. Because of this their object sizes add up to the sum of the two different vectors and the length-2 list: 8000048 B + 8000048 B + 64 B = 16000160 B (16 MB).
b[[1]][[1]] <- 10
obj_size(b)
#> 16,000,160 B

# The second element of `b` still references to the same address as `a`, so the combined size fo `a` and `b` is the same as `b`:
obj_size(a, b)
#> 16,000,160 B
ref(a, b)
#> [1:0x11e7a2000] <dbl> 
#>   
#>   █ [2:0x10bf61748] <list> 
#>   ├─[3:0x11ef44000] <dbl> 
#>   └─[1:0x11e7a2000]

# When we modify the second element fo `b`, this element will also point to a new memory address.
# This doesn't affect the size of the list:
b[[2]][[1]] <- 10
obj_size(b)
#> 16,000,160 B

# However, as `b` doesn't share references with `a` anymore, the memory usage of the combined onjects increases:
obj_size(a, b)
#> 24,000,208 B
ref(a, b)
#> [1:0x11e7a2000] <dbl> 
#>   
#>   █ [2:0x11226dec8] <list> 
#>   ├─[3:0x11ef44000] <dbl> 
#>   └─[4:0x11e000000] <dbl> 

# 2.5 Modify-in-place

# As we've seen above, modifying an R object usually creates a copy.
# There are two exceptions:

# - Objects with a single binding get a special performance optimisation.
# - Environments, a special type of object, are always modified in place.

# 2.5.1 Objects with a single binding

# If an object has a single name bound to it, R will modify it in place:
v <- c(1, 2, 3)
v[[3]] <- 4

# (Note the object IDs here: `v` continues to bind to the same object, `0x217`.)

# Two complicatoins make predicting exactly when R applies this optimisation challenging:

# - When it comes to bindings, R can currently only count 0, 1, or many.
#   That means that if an object has two bindings, and one goes away, the reference count does not go back to 1: one less than many is still many.
#   In turn, this means that R will make copies when it sometimes doesn't need to.

# - Whenever you call the vast majority of functions, it makes a reference to the object.
#   The only exception are specially written "primitive" C functions.
#   These can only be written by R-core and occur mostly in the base package.

# Togethre, these two complications make it hard to predict whether or not a copy will occur.
# Instead, it's etter to determine it empirically with `tracemem()`.

# let's explore the subtleties with a case study using for loops. 
# For loops have a reputation fo being slow in R, but often that slowness is caused by every iteration of the loop creating a copy.
# Consider the following code. It subtracts the median from each column of a large data frame:
x <- data.frame(matrix(runif(5 * 1e4), ncol = 5))
medians <- vapply(x, median, numeric(1))

for (i in seq_along(medians)) {
  x[[i]] <- x[[i]] - medians[[i]]
}

# This loop is surprisingly slow because each iteration of the loopo copies the data frame. 
# You can see this by using `tracemem()`:
cat(tracemem(x), "\n")
#> <0x1183642f8>

for (i in 1:5) {
  x[[i]] <- x[[i]] - medians[[i]]
}
#> tracemem[0x1183642f8 -> 0x110b34228]: 
#> tracemem[0x110b34228 -> 0x110b34378]: [[<-.data.frame [[<- 
#> tracemem[0x110b34378 -> 0x110b344c8]: [[<-.data.frame [[<- 
#> tracemem[0x110b344c8 -> 0x110b34618]: 
#> tracemem[0x110b34618 -> 0x110b34768]: [[<-.data.frame [[<- 
#> tracemem[0x110b34768 -> 0x110b34848]: [[<-.data.frame [[<- 
#> tracemem[0x110b34848 -> 0x110b34998]: 
#> tracemem[0x110b34998 -> 0x110b34ae8]: [[<-.data.frame [[<- 
#> tracemem[0x110b34ae8 -> 0x110b34c38]: [[<-.data.frame [[<- 
#> tracemem[0x110b34c38 -> 0x110b34d18]: 
#> tracemem[0x110b34d18 -> 0x110b34e68]: [[<-.data.frame [[<- 
#> tracemem[0x110b34e68 -> 0x110b34ed8]: [[<-.data.frame [[<- 
#> tracemem[0x110b34ed8 -> 0x110b34f48]: 
#> tracemem[0x110b34f48 -> 0x110b34fb8]: [[<-.data.frame [[<- 
#> tracemem[0x110b34fb8 -> 0x110b35028]: [[<-.data.frame [[<- 

untracemem(x)

# In fact, each iteration copies the data frame not once, not twice, but three times!
# Two copies are made by `[[.data.frame`, and a further copy is made because `[[.data.frame` is a regular function that increments the reference count of `x`.

# We can reduce the number of copies by using a list instead of a data frame.\
# Modifying a list uses internal C code, so the references are not incremented and only a single copy is  made:
y <- as.list(x)
cat(tracemem(y), "\n")
#> <0x112db1eb8> 

for (i in 1:5) {
  y[[i]] <- y[[i]] - medians[[i]]
}
#> tracemem[0x112db1eb8 -> 0x112df1518]: 

# While it's not hard to determine when a copy is made, it is hard to prevernt it.
# If you find yourself resorting to exotic tricks to avoid copies, it may be time to rewrite your funciton in C++, as described in Chapter 25.

# 2.5.2 Environments

# You'll learn more about environments in Chatper 7, but it's important to mention them here because their behaviour is different from that of other objects: environments are always modefied in place.
# This property is somtimes described as __reference semantics__ because when you modify an environment all existing bindings to that environment continue to have the same reference.

# Take this envionment, which we bind to `e1` and `e2`:
e1 <- rlang::env(a = 1, b = 2, c = 3)
e2 <- e1

# If we change a binding, the envionments is modified in place:
e1$c <- 4
e2$c
#> [1] 4

# This  basic idea can be used to create functions that "remember" their previous state. See Section 10.2.4 for more details. 
# This property is also used to implement the R6 object-oriented programming system, the topic of Chapter 14.
e <- rlang::env()
e$self <- e
ref(e)
#> █ [1:0x10ad7c968] <env> 
#> └─self = [1:0x10ad7c968] 

# This is a umique property fo envionments!

# 2.5.3 Exercises

# 1. Explaint why the following code doesn't create a circular list.
x <- list()
x[[1]] <- x

# In this situation Copy-on-modify prevents the creation of a circular list.
# Let's step through the details as follows:
x <- list()               # creates initial object
obj_addr(x)
#> [1] "0x10c332778"

tracemem(x)
#> [1] "<0x10c332778>"
x[[1]] <- x               # Copy-on-modify triggers new copy
#> tracemem[0x10c332778 -> 0x10b024fa0]: 

obj_addr(x)               # copied object ahs new memory address
#> [1] "0x115147e80"
obj_addr(x[[1]])
#> [1] "0x10c332778"      # list element contains old memory address

# 2. Wrap the two methods for subtracting medians into two functions, then use the 'bench' package(Hester 2018) to carefully compare their speeds.
#    How does performance change as the number of columns increase?

# First, let's define a function to create some random data and a fucntion to subtract the median from each column.
create_random_df <- function(nrow, ncol) {
  random_matrix <- matrix(runif(nrow * ncol), nrow = nrow)
  as.data.frame(random_matrix)
}

subtract_medians <- function(x, medians){
  for (i in seq_along(medians)) {
    x[[i]] <- x[[i]] - medians[[i]]
  }
  x
}

subtract_medians_l <- function(x, medians){
  x <- as.list(x)
  x <- subtract_medians(x, medians)
  as.data.frame(x)
}


# We can then profile the performance, by benchmarking `subtract_medians()` on data frame- and list-input for a specified number of columns.
# The functions should both input and output a data frame, so one is going to do a bit more work.
compare_speed <- function(ncol){
  df_input   <- create_random_df(nrow = 1e4, ncol = ncol)
  medians <- vapply(df_input, median, numeric(1))
  
  bench::mark(`Data Frame` = subtract_medians(df_input,   medians),
              List = as.data.frame(subtract_medians(as.list(df_input), medians)))
}
# Then bench package allow us to run our benchmark across a grid of parameters easily.
# We will use it to slowly increase the number of columns containing random data.
results <- bench::press(
  ncol = c(1, 5, 10, 50, 100, 200, 400, 600, 800, 1000, 1500),
  compare_speed(ncol)
)

library(ggplot2)
ggplot(results, aes(ncol, median, col = expression)) +
  geom_point(size = 2) + 
  geom_smooth() +
  labs(x = "Number of Columns of Input Data", y = "Computation Time",
       color = "Input Data Structure",
       title = "Benchmark: Median Subtraction")

# When working directly with the data frame, the execution time grows quadratically with the number of columns in the input data.
# This is because (e.g.) the first column must be copied `n` times, the second cloumn `n-1` times, and so on.
# When working with a list, the execution time increases only linearly.

# Obvously in the long run, linear growth creates shorter run-times, but there is some cost to this strategy - we have to convert between data structures with `as.list()` and `as.data.frame()`.
# This means that the improved approach doesn't pay off until we get to a data frame that's ~800 columns wide.

# 3. What happens if you attempt to use `tracemem()` on an environment?

# `tracemem()` cannot be used to mark and trace environments.
x <- new.env()
tracemem(x)
#> Error in tracemem(x) : 
#>'tracemem' is not useful for promise and environment objects

# The error occurs because "it is not useful to trace NULL, environments, promises, weak references, or external pointer objects, as these are not duplicated" (see `?tracemem`).
# Environments are always modified in place.

# 2.6 Unbinding and the garbage collector

# Consider this code:
x <- 1:3
x <- 2:4
rm(x)

# We created two objects, bu tby the time the code finishes, neither object is bound to a name.
# How do these objects get deleted? That's the job of the __garbage collector__, or GC for short.
# The GC frees up memory by deleting R objects that are no longer used, and by requesting more memory from the operating system if needed.

# R uses a __tracing__ GC. This means it traces every object that's reachable from the gloabal environment, and all objects that are, in turn, reachalge from those bojects (i.e. the references in lists and environments are searched resursively).
# The garbage collector does not use the modify-in-place reference count described above.
# While these two ideas are closely related, th internal data structure are optimised for different use cases.

# The garbage collector(GC) runs automatically whenever R needs more memory to create a new object.
# Looking from the outside, it's basically impossible to predict when the GC will run.
# In fact, you shouldn't even try. If you want to find out when the GC runs, call `gcinfo(TRUE)` and GC eill print a message to the console every time it runs.

# You can force garbage collection by calling gc(). But despite what you might have read elsewhere, there’s never any need to call gc() yourself. 
# The only reasons you might want to call gc() is to ask R to return memory to your operating system so other programs can use it, or for the side-effect that tells you how much memory is currently being used:
gc()
#>             used  (Mb) gc trigger   (Mb) limit (Mb)  max used   (Mb)
#> Ncells   2269202 121.2    3910611  208.9         NA   3910611  208.9
#> Vcells 102158698 779.5  284266572 2168.8      16384 284260376 2168.8

# lobstr::mem_used() is a wrapper around gc() that prints the total number of bytes used:
mem_used()
#> 944,348,872 B

# This number won’t agree with the amount of memory reported by your operating system. There are three reasons:
  
# 1. It includes objects created by R but not by the R interpreter.
# 2. Both R and the operating system are lazy: they won’t reclaim memory until it’s actually needed. R might be holding on to memory because the OS hasn’t yet asked for it back.
# 3. R counts the memory occupied by objects but there may be empty gaps due to deleted objects. This problem is known as memory fragmentation.
