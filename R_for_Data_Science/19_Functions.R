# 19 Functions

# 19.1 Introduction

# One of the best ways to improve your reach as a data scientist is to write functions.
# Functions allow you to automate common tasks in a  more powerful and general way than copy-and-pasting.
# Writing a function has three big advantages over using copy-and-paste:

# 1. You can give a function an evocative name that makes your code easier to understand.
# 2. As requirements change, you only need to update code in one place, instead of many.
# 3. You eliminate the chance of making incidental mistakes when you copy and paste
#    (i.e. updating a variable name in one place, but not in another).

# Writing good functions is a lifetime journey. Even after usint R for many years I still learn new techniques and better ways of approaching old problems.
# The goal of this chapter is not to teach you every esoteric detail of functions but to get you started with some pragmatic adviece that you can apply imediately.

# As well as pracitcal advice for writing functions, this chapter also gives you some suggestions for how to style your code.
# Good code style is like correct punctuation. You can manage without it, but it sure makes things easier to read!
# As with styles of punctuation, there are many possible variations.
# Here we present the style we use in our code, but the most important thing is to be consistent.

# 19.1.1 Prerequisites
# The focus of this chapter is on writing functions in base R, so you won't need any extra packages.

# 19.2 When should you write a function?
# You should consider writing a function whenever you've copied and pasted a block of code more than twice
# (i.e. you now have three copies of the same code). 
# For example, take a look at this code. What does it do?
df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

df$a <- (df$a - min(df$a, na.rm = TRUE)) / 
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b <- (df$b - min(df$b, na.rm = TRUE)) / 
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$c <- (df$c - min(df$c, na.rm = TRUE)) / 
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d <- (df$d - min(df$d, na.rm = TRUE)) / 
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))

# You might be able to puzzle out that this rescales each column to have a range from 0 to 1. But did you spot the mistake? 
# I made an error when copying-and-pasting the code for df$b: I forgot to change an a to a b.
# Extracting repeated code out into a function is a good idea because it prevents you from making this type of mistake.

# To write a function you need to  first analyses the code. How many inputs does it have?
(df$a - min(df$a, na.rm = TRUE)) /
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))

# This code only has one input: df$a. (If you're surprised that TRUE is not an input, you can explore why in the exercise below.)
# To make the inputs more clear, it's a good idea to rewrite the code using temporary variables with general names.
# Here this code only requires a single numeric vector, so I'll call it x:
x <- df$a
(x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))

# There is some duplication in this code. We're computing the range of the data three times, so it makes sense to do it in one step:
rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])

# Pulling out intermediate calculations into named variables is a good practice because it makees it more clear that the code is doing.
# Now that I've simplified the code, and checked that it still works, I can turn it into a function:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

rescale01(c(0, 5, 10))

# There are three key steps to creating a new function:
# 1. You need to pick a name for the function. Here I've used rescale01 because this function rescales a vetor to lie between 0 and 1.
# 2. You list the inputs, or arguments, to the function inside function. Here we have just one argument.
#    If we had more the call would look like function(x, y, z).
# 3. You place the code you have developed in body of the function, a { block that immediately follows function(...).

# Note the overall process: I only made the function after I'd figured out how to make it work with a somple input.
# It's easier to start with working code and turn it into a function; it's hearder to create a function and then try to make it work.

# At this point it's a good idea to check your function with a few different inputs:
rescale01(c(-10, 0, 10))
rescale01(c(1, 2, 3, NA, 5))

# As you write more and more functions you'll eventually want to convert these informal, interactive tests into formal,
# automated tests. That process is called unit testing. 
# Unfortunately, it's beyond the scope of this book, but you can learn about it in http://r-pkgs.had.co.nz/tests.html.

# We can simplify the original example now that we have a function:
df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# Compared to the original, this code is easier to understand and we've eliminated one class of copy-and-paste errors.
# There is still quite a bit of duplication since we're doing the same thing to multiple columns.
# We'll learn how to eliminate that duplication in iteration, once you've learned more about R's data structures in vectors.

# Another advantage of functions is that if our requirements change, we only need to make the change in one place.
# For example, we might discover that some of our variables include infinite values, and rescale01() fails:
x <- c(1:10, Inf)
rescale01(x)

# Because we've extracted the code into a function, we only need to make the fix in one place:
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01(x)

# This is an important part of the "do not repeat yourself" (or DRY) pinciple.
# The more repetition you have in your code, the more places you need to remember to update when things change(and they always do!),
# and the more likely you are to create bugs over time.

# 19.2.1 Practice

# 1. Why is TRUE not a parameter to rescale01()? 
#    What would happen if x contained a single missing value, and na.rm was FALSE?
## (1) Because we don't want any values is NA, so we set na.rm = TRUE as default.

## (2) Because NA is infective, do any arithmetic operations with, will return NA.
rescale01_F <- function(x) {
  rng <- range(x, na.rm = FALSE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01_F(c(1, 2, 3, NA, 5))

# 2. In the second variant of rescale01(), infinite values are left unchanged.
#    Rewrite rescale01() so that -Inf is mapped to 0, and Inf is mapped to 1.
rescale01_F <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  y <- (x - rng[1]) / (rng[2] - rng[1])
  y[y == -Inf] <- 0
  y[y == Inf] <- 1
  y
}
x <- c(1:10, Inf)
rescale01_F(x)

# 3. Practice turning the following code snippets into functions. Think about what each function does.
#    What would you call it? How many arguments does it need? Can you rewrite it to be more expressive or less duplicative?
mean(is.na(x))
x / sum(x, na.rm = TRUE)
sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)

x <- c(NA, 1, 4, 5, NA, NA)
## (1)
prop_NA <- function(x) {
  mean(is.na(x))
}
prop_NA(x)

## (2)
weight <- function(x) {
  x / sum(x, na.rm = TRUE)
}
weight(x)

## (3)
Coefficient_of_Variation <- function(x) {
  sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
}
Coefficient_of_Variation(x)

# 4. Follow http://nicercode.github.io/intro/writing-functions.html to write your own functions 
#    to compute the variance and skew of a numeric vector.
x <- rnorm(1000)

## (1)
variance <- function(x) {
  sum((x - mean(x))^2) / (length(x) - 1)
}
variance(x)

identical(var(x), variance(x))

## (2)
skew <- function(x) {
  n <- length(x)
  v <- var(x, na.rm = TRUE)
  m <- mean(x, na.rm = TRUE)
  sum(x - m^2) / (n-2) / v^(3/2)
}
skew(x)

# 5. Write both_na(), a function that takes two vectors of the same length and returns 
#    the number of positions that have an NA in both vectors.
both_na <- function(x, y) {
  sum(is.na(x) & is.na(y))
}

both_na(
  c(NA, 1, 2, 3, NA, 4, NA),
  c(NA, NA, 1, 2, NA, 4, NA)
)

# 6. What do the following functions do? Why are they useful even though they are so short?
is_directory <- function(x) file.info(x)$isdir
is_readable <- function(x) file.access(x, 4) == 0

x <- getwd()
is_directory(x)
is_readable(x)

# 7. Read the complete lyrics to “Little Bunny Foo Foo”. There’s a lot of duplication in this song.
#    Extend the initial piping example to recreate the complete song, and use functions to reduce the duplication.
lyrics <- function(chance) {
  if(chance > 0) {
    foo_foo %>% 
      hop(through = forest) %>% 
      scoop(up = field_mice) %>% 
      bop(on = head)
    downcame(good_fairy)
    said(str_c("Little Bunny Foo Foo, I don’t want to see you\nScooping up the field mice and bopping ’em on the head.", 
               "I’ll give you ",
               chance, 
               " more chances and if you don’t behaveI’m going to turn you into a goon!”")
    )
    chance <- chance - 1
  }
}
lyrics(3)

# 19.3 Functions are for humans and computers

# It's important to remember that functions are not just for the computer, but are also for humans.
# R doesn't care what your funcion is called, or what comments it contains, but these are important for human readers.
# This section discusses dome things that you should bear in mind when writing functions that humans can understand.

# The name of a function is important. Ideally, the name of your function will be short, but clearly evoke what the function does.
# That's hard! But it's better to be clear than short, as RStudio's autocomplete makes it easy to type long names.

# Generally, function names should be verbs, and arguments should be nouns.
# There are some excptions: nouns are ok if the function computes a very well known noun (i.e. mean() is better than compute_mean()),
# or accessing some property of an object (i.e. coef() is better than get_coefficients()).
# A good sign thta a noun might be a better choice is if you're using a very broad verb like "get", "compute", "calculate", or "determine".
# Use your best judgement and don't be afraid to rename a function if you figure out a better name later.

# Too short
f()

# Not a verb, or descriptive
my_awesome_function()

# Long, but clear
impute_missing()
collapse_years()

# If your function name is composed of multiple words, I recommend using "snake_case", there each lowercase word is separated by an underscore.
# camelCase is a popular alternative. It doesn't really matter which one you pick, the important thing is to be consistent:
# pick one or the other and stick with it. R itself is not very consistent, but there's nothing you can do about that.
# Make sure you don't fall into the same trap by making your code as consistent as possible.

# Never do this!
col_mins <- function(x, y) {}
rowMaxes <- function(x, y) {}

# If you have a family of functions that do similar things, make sure they have consistent names and arguments.
# Use a common prefix to indicate that they are connected.
# That's better than a common suffix because autocomplete allows you to type the prefix and see all the members of the family.

# Good
input_select()
input_checkbox()
input_text()

# Not so good
select_input()
checkbox_input()
text_input()

# A good example of this design is the stringr package: if you don't remeber exactly thich function you need, you can type str_ and jog your memory.

# Where possible, avoid overriding existing functinos and variables.
# It's impossible to do in general because so many good names are already taken by other packages,
# but avoiding the most common names from base R will avoid confusion.

# Dont's do this!
T <- FALSE
c <- 10
mean <- function(x) sum(x)

# Use comments, lines starting with #, to explain the "why" of your code.
# You generally should avoid comments that explain the "what" or the "how". 
# If you can't understand what the code does from reading it, you should think about how to rewrite it to be more clear.
# Do you need to add some intermediate variables with useful names? Do you need to break out a subcomponent of a large function so you can name it?
# However, your code can never capture the reasoning behind your decisions: why did you choose this approach instead of an alternative?
# What else did you try that didn't work? It's a great idea to capture that sort of thinking in a comment.

# Another important use of comments is to break up your file into easily readable chunks. Use long lines of - and = to make it easy to spot the breads.

# Load data --------------------------------------
# Plot data --------------------------------------

# RStudio provides a keyboard shortcut to create these headers (Cmd/Ctrl + Shift + R), 
# and will display them in the code navigation drop-down at the bottom-left of the editor:

# 19.3.1 Exercises

# 1. Read the source code for each of the following three functions, puzzle out what they do, 
#    and then brainstorm better names.
## (1) is_prefix: test whether the inputs starts with the prefix.
f1 <- function(string, prefix) {
  substr(string, 1, nchar(prefix)) == prefix
}

## (2) drop_last: remove the last element of the input vector.
f2 <- function(x) {
  if (length(x) <= 1) return(NULL)
  x[-length(x)]
}

## (3) Rep_length: repeats y for length of x.
f3 <- function(x, y) {
  rep(y, length.out = length(x))
}

# 2. Take a function that you’ve written recently and spend 5 minutes brainstorming a better name for it and its arguments.

# 3. Compare and contrast rnorm() and MASS::mvrnorm(). How could you make them more consistent?
?rnorm()
?MASS::mvrnorm()

# rnorm() |  mvrnorm() 
# --------|------------
#    n    |    n
#  mean   |    mu
#   sd    |   Sigma

# 4. Make a case for why norm_r(), norm_d() etc would be better than rnorm(), dnorm(). Make a case for the opposite.
## norm_r(), and norm_d() etc is start with "norm_", can that can make autocomplete allows you to type the prefix and see all the members of the family.
## so it's better than rnorm(), dnorm()...

# 19.4 Conditional execution

# An if statement allows you to conditionally execute code. It tooks like this:
if(condition) {
  # code executed when condition is TRUE
} else {
  # code executed when condition is FALSE
}

# To get help on if you need to surround it in backticks: ?`if`. The help isn't particularly helpful if you're not already an 
# experiended programmer, but at least you know how to get to it!

# Here's a somple function that uses an if statement. The goal of this function is to return a logical vector describing
# whether or not each element of a vector is named.
has_name <- function(x) {
  nms <- names(x)
  if(is.null(nms)) {
    rep(FALSE, length(x))
  } else {
    !is.na(nms) & nms != ""
  }
}
# This function takes advantage of the standard return rule: a function returns the last value that if computed.
# Here that is either one of the two branches of the if statement.

# 19.4.1 Conditions
# The condition must evaluate to either TRUE or FALSE. If it's a vector, you'll get a warning message;
# if it's an NA, you'll get an error. Watch out for these messages in your own code:
if (c(TRUE, FALSE)) {}

if (NA) {}

# You can use ||(or) &&(and) to combine multiple logical expressions. These operators are "short-circuiting": as soon as || sees the first FALSE it return FALSE.
# As soon as && sees the first FALSE it returns FALSE. You should never use | or & in an if statement: these are vectorised operations that apply to multiple values
# (that's why you use them in filter()). If you do have a logical vector, you can use any() or all() to collapse it to a single value.

# Be careful when testing for equality. == is vectorised, which means that it's easy to get more than one output.
# Either check the length is already 1, collapse with all() or any(), or use the non-vectorised identical().
# identical() is very strict: it always returns either a single TRUE or a single FALSE, and doesn't coerce types.
# This means that you need to be careful when comparing integers and doubles:
identical(0L, 0)

# You also need to be wary of floating point numbers:
x <- sqrt(2) ^ 2
x

x == 2
x - 2

# Instead use dplyr::near() for comparisons, as described in comparisons.
# And remember, x == NA doesn't do anything useful!
dplyr::near(x, 2)

# 19.4.2 Multiple conditions

# You can chain multiple if statements together:
if (this) {
  # do that 
} else if (that) {
  # do something else
} else {
  # 
}

# But if you end up with a very long series of chained if statements, you should consider rewriting.
# One useful technique is the switch() function. It allows you to evaluate selected code based on position or name.
function (x, y, op) {
  switch(op,
         plus = x + y,
         minus = x - y,
         times = x * y,
         divide = x / y,
         stop("Unknown op!")
  )
}
# Another useful function that can often eliminate long chains of if statements is cut(). 
# It's used to discretise continuous variables.

# 19.4.3 Code style

# But if and function should (almost) always be followed by squiggly brackets( {} ), and the contents should be indented by two spaces.
# This makes it easier to see the hierarchy in your code by skimming the left-hand margin.

# An opening curly brace should never go on its own line and should always be followed by a new line.
# A closing curly brace should always go on its own line, unless it's followed by else.
# Always indent the code inside curly braces.

# Good 
if (y < 0 && debug) {
  message("Y is negative")
}

if (y == 0) {
  log(x)
} else {
  y ^ x
}

# Bad
# if (y < 0 && debug) 
#   message("Y is negative")

# if (y == 0) {
#   log(x)
# }
# else {
#   y ^ x
# }

# It's ok to drop the curly braces if you have a very short if statement that can fit on one line:
y <- 10
x <- if (y < 20) "Too low" else "Too high"

# I recommend this only for very brief if statements. Otherwise, the full form is easier to read:
if (y < 20) {
  x <- "Too low"
} else {
  x <- "Too high"
}

# 19.4.1 Exercise 

# 1. What's the difference between if and ifelse() ? 
#    Carefully read the help and construct three examples thtat illustrate the key differences.
?ifelse # ifelse(test, yes, no)
## ifelse -> return a value with the same shape as test which is filled with elements 
#            from either yes or no depending on whether the element of test is TRUE or FALSE

?"if" # if (cond) expr

# 2. Write a greeting function that says “good morning”, “good afternoon”, or “good evening”, depending on the time of day. 
#    (Hint: use a time argument that defaults to lubridate::now(). That will make it easier to test your function.)

## (1)
greeting <- function(time = lubridate::now()) {
  time <- lubridate::hour(x)
  morning <- c(6:12)
  afternoon <- c(13:17)
  evening <- c(18:20)
  
  if (time %in% morning) {
    print("Good morning!")
  } else if (time %in% afternoon) {
    print("Good afternoon!")
  } else if (time %in% evening) {
    print("Good evening")
  } else {
    print("Good night!")
  }
}

## (2)
greeting <- function(time = lubridate::now()) {
  time <- lubridate::hour(time)
  
  if (dplyr::between(time, 6, 12)) {
    print("Good morning!")
  } else if (dplyr::between(time, 13, 17)) {
    print("Good afternoon!")
  } else if (dplyr::between(time, 18, 20)) {
    print("Good evening")
  } else {
    print("Good night!")
  }
}

# 3. Implement a fizzbuzz function. It takes a single number as input. If the number is divisible by three, it returns “fizz”.
#    If it’s divisible by five it returns “buzz”. If it’s divisible by three and five, it returns “fizzbuzz”. 
#    Otherwise, it returns the number. Make sure you first write working code before you create the function.
fizzbuzz <- function(num) {
  if (num %% 3 == 0 && num %% 5 == 0) {
    print("fizzbuzz")
  } else if ( num %% 5 == 0) {
    print("buzz")
  } else if (num %% 3 == 0) {
    print("fizz")
  } else {
    num
  }
}
fizzbuzz(21)

# 4. How could you use cut() to simplify this set of nested if-else statements?
if (temp <= 0) {
  "freezing"
} else if (temp <= 10) {
  "cold"
} else if (temp <= 20) {
  "cool"
} else if (temp <= 30) {
  "warm"
} else {
  "hot"
}
#    How would you change the call to cut() if I’d used < instead of <=? 
#    What is the other chief advantage of cut() for this problem? 
#    (Hint: what happens if you have many values in temp?)

?cut() ## Convert Numeric to Factor

## (1)
temprature <- function(tmp) {
  cut(tmp, c(-Inf, 0, 10, 20, 30, Inf),
      labels = c("freezing", "cold", "cool", "warm", "hot"))
}
temprature(c(-2:35))

## (2)
temprature <- function(tmp) {
  cut(tmp, c(-Inf, 0, 10, 20, 30, Inf),
      right = FALSE, # ogical, indicating if the intervals should be closed on the right (and open on the left) or vice versa.
      labels = c("freezing", "cold", "cool", "warm", "hot"))
}
temprature(c(-2:35))

# 5. What happens if you use switch() with numeric values?
?switch()
## If the value of EXPR is not a character string it is coerced to integer.
## Note that this also happens for factors, with a warning, as typically the character level is meant. 
## If the integer is between 1 and nargs()-1 then the corresponding element of ... is evaluated and the result returned: 
## thus if the first argument is 3 then the fourth argument is evaluated and returned.


# 6. What does this switch() call do? What happens if x is “e”?
switch(x, 
       a = ,
       b = "ab",
       c = ,
       d = "cd"
)
#    Experiment, then carefully read the documentation.
x <- "e"
switch(x, 
       a = ,
       b = "ab",
       c = ,
       d = "cd"
)

## If EXPR evaluates to a character string then that string is matched (exactly) to the names of the elements in .... 
## If there is a match then that element is evaluated unless it is missing, 
## in which case the next non-missing element is evaluated, 
## so for example switch("cc", a = 1, cc =, cd =, d = 2) evaluates to 2. 
## If there is more than one match, the first matching element is used.
## In the case of no match, if there is a unnamed element of ... its value is returned.
## (If there is more than one such argument an error is signaled.)

# 19.5 Function arguments

# The arguments to a function typically fall into two broad sets: 
# one set supplies the data to compute on, and the other supplies arguments that control the details of the computation.
# For example: 
# 1. In log(), the data is x, and the detail is the base of the logarithm.
# 2. In mean(), the data is x, and the details are how much data to from the ends (trim) and how to handle missing values (na.rm).
# 3. In t.test(), the data are x, and y, and the details of the test are alternative, mu, paired, var.equal, and conf.level.
# 4. In str_c() you can supply any number of strings to ..., and the details of the concatenation are controlled by sep and collapse.

# Generally, data arguments should come first. Detail arguments should go on the end, and ususally should have default values.
# YOu specify a default value in the same way you call a function with a named argument:

# Compute confidence interval around mean useing normal approximation
mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
mean_ci(x, conf = 0.99)

# The default value should almost always be the most common value. The few exceptions to this rule are to do with safety.
# For example, it makes sense for na.rm to default to FALSE because missing values are important.
# Even though na.rm = TRUE is what you usually put in your code, it's a bad idea to silently ignore missing values by default.

# When you call a function, you typically omit the names of the data arguments, because they are used to commonly.
# If you override the default value of a detail argument, you should use the full name:

# Good 
mean(1:10, na.rm = TRUE)

# Bad
mean(x = 1:10, FALSE)
# mean(, TRUE, x = c(1:10, NA))

# You can refer to an argument by its unique prefix (e.g. mean(x, n = TRUE)), but this is generally best avoided given the possibilities for confusion.

# Notice that when you call a funciton, you should place a space around = in function calls, and always put a space agter a comma, 
# not before (just like in regular Englich). Using whitespace makes it easier to skim the function for the important components.

# Good 
average <- mean(feet / 12 + inches, na.rm = TRUE)

# Bad
average<-mean(feet/12+inches,na.rm=TRUE)

# 19.5.1 Choosing names

# The names of arguments are also important. R doesn't care, but the readers of your code (including furture-you!) will.
# Generally you should prefer longer, more descriptive names, but there are a handful of very common, very short names.
# It's worth memorising these:
# 1. x, y, z: vectors.
# 2. w: a vector of weights.
# 3. df: a data frame.
# 4. i, j: numeric indices( typically rows and columns).
# 5. n: length, or number of rows.
# 6. p: number of columns.
# Otherwise, consider matching names of arguments in existin R functions.
# For example, use na.rm to determine if missing values should be removed.

# 19.5.2 Checking values

# As you start write more functions, you'll eventually get to the point where you don't remember exactly how your function works.
# At this point it's easy to call your funtion with invalid inputs.
# To avoid this problem, it's useful to make constraints explicit.
# For exmaple, imagine you've written some functions fo rcomputing weighted summary statistics:
wt_mean <- function(x, w) {
  sum(x * w) / sum(w)
}
wt_var <- function(x, w) {
  mu <- wt_mean(x, w)
  sum(w * (x - mu) ^ 2) / sum(w)
}
wt_sd <- function(x, w) {
  sqrt(wt_var(x, w))
}
# What happens if x and w are not the same length?
wt_mean(1:6, 1:3)

# In this case, because of R's vector recycling rules, we don't get an error.

# It's good practice to check important preconditions, and throw an error (with stop() ), if they are not true:
wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(w)
}

# Be careful not to take this too far. There's a tradeoff between how mucn time you spend making your function robust, 
# versus how long you spend writing it. For example, if you also added a na.rm argument, I probably wouldn't check it carefully:
wt_mean <- function(x, w, na.rm = FALSE) {
  if (!is.logical(na.rm)) {
    stop("`na.rm` must be logical")
  }
  if (length(na.rm) != 1) {
    stop("`na.rm` must be length 1")
  }
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}

# This is a lot of extra work for little additional gain. A useful compromise is the built-in stopifnot():
# it checks that each argument is TRUE, and produces a generic error message if not.
wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(x))
  
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(w)
}
wt_mean(1:6, 6:1, na.rm = "foo")

# Note that when using stopifnot() you assert what should be true rather than checking for what might be wrong.

# 19.5.3 Dot-dot-dot (...)

# Many functions in R take an arbitrary number of inputs:
sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
stringr::str_c("a", "b", "c", "d", "e", "f")

# How do these functions work? They rely on a special argument: ... (pronounced dot-dot-dot).
# This special argument captures any number of arguments that aren't otherwise matched.

# It's useful because you can then send those ... on to another function.
# This is a useful catch-all if your function primarily wraps another function. 
# For example, I commonly create these helper functions that wrap around str_c():

commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Important output")

# Here ... lets me forward on any arguments that I don't want to deal with to str_c().
# It's a very convenient technique. But it does come at a price: any misspelled arguments will not raise an error.
# This makes it easy for typos to go unnoticed:
x <- c(1, 2) 
sum(x, na.mr = TRUE)

# If you just want to capture the values of the ..., use list(...).

# 19.5.4 Lazy evaluation

# Arguments in R are lazily evaluated: they're not computed until they're needed.
# That means if they're never used, they're  never called.
# This is an important property of R as a programming language, 
# but is generally not important when you're writting your own funcitons for data analysis.
# You can read more about lazy evaluation at http://adv-r.had.co.nz/Functions.html#lazy-evaluation.

# 19.5.5 Exercises
# 1. What dose commas(letters, collapse = "-") do? Why?
commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters, collapse = "-")

## Error in stringr::str_c(..., collapse = ", "): formal argument "collapse" matched by multiple actual arguments
## so we need to rewrite the function while we want to change the type of collapse:
commas <- function(..., collapse = ", ") {
  stringr::str_c(..., collapse = collapse)
}
commas(letters, collapse = "-")

# 2. It'd be nice if you could supply multiple characters to the pad argument, e.g. rule("Title", pad = "-+").
#    Why doesn't this currently work? How could you fix it?
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Title", pad = "-+")
## If we change the pad's argument to "-+", the function seems still work.
## But the output seem that not desired width.
rule <- function(..., pad = "-") {
  
  len_char <- stringr::str_length(pad)
  title <- paste0(...)
  
  if (len_char >= 2) {
    width <- (getOption("width") / len_char) - nchar(title) - 5
  } else {
    width <- getOption("width") - nchar(title) - 5
  }
  
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
rule("Title", pad = "-+")

# 3. What does the trim argument to mean() do? When might you use it?
?mean()
## The trim method excludes a fraction of observations from the calculation of the mean. 
## It would be useful if the vector is ordered and contains outliers at either end.

# 4. The default value for the method argument to cor() is c("pearson", "kendall", "spearman"). 
#    What does that mean? What value is used by default?
?cor()
## a character string indicating which correlation coefficient (or covariance) is to be computed. 
## One of "pearson" (default), "kendall", or "spearman": can be abbreviated.

# 19.6 Return values

# Figuring out what your funciton should return is usually straightforward: it's why you created the function in the first place!
# There are two things you should consider when returning a value:
# 1. Does returning early make your function easier to read?
# 2. Can you make your function pipeable?

# 19.6.1 Explicit return statements

# The value returned by the function is usually the last statement it evaluates, but you can shoose to return early by using return().
# I think it's best to save the use of return() to signal that you can return early with a simpler solution. 
# A common reason to do this is because the inputs are empty:
complicated_function <- function(x, y, z) {
  if(length(x) == 0 || length(y) == 0) {
    return(0)
  }
  # Complicated code here
}

# Another reason is because you have a if statement with one complex block and one simple block.
# For example, you might write an if statement like this:
f <- function() {
  if (x) {
    # Do
    # something
    # that
    # takes
    # many
    # lines
    # to 
    # express
  } else {
    # return something short
  }
}

# But if the first block is vary long, by the time you get to the else, you've forgotten the condition.
# One way to rewrite it is to use an early return for the simple case:
f <- function() {
  if (!x) {
    return(something_short)
  }
  
  # Do 
  # something
  # that
  # takes
  # many
  # lines
  # to 
  # express
}

# This tends to make the code easier to understand, because you don't need quite so much context to understand it.

# 19.6.2 Writing pipeable functions

# If you want to write your own pipeable functions, it's important to think about the return value.
# Knowing the return value's object type will mean that your pipeline will "just work".
# For example, with dplyr and tidyr the object type is the date frame.

# There are two basic types of pipeable functions: transformations and side-effects.
# With transformations, an object is passed to the function's first argument and a modified object is returned.
# With side-effects, the passed object is not transformed.
# Instead, the function performs an action on the object, like drawing a plot or saving a file.
# Side-effects functions should "invisibly" return the first argument, so that while they're not printed they can still be used in a pipeline.

# For example, this simple function prints the number of missing values in a data frame:
show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  
  invisible(df)
}

# If we call it interactively, the invisible() means that the input df doesn't printed out:
show_missings(mtcars)

# But it's still there, it's just not printed by default:
x <- show_missings(mtcars)
class(x)
dim(x)

# And we can still use it in a pipe:
mtcars %>% 
  show_missings() %>% 
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>% 
  show_missings()

# 19.7 Environment

# The last component of a function is its environment. This is not something you need to understand deeply when you first start writting functions.
# However, it's important to know a little bit about environments because they are crucial to how functions work.
# The emvironment of a function controls how R finds the value associated with a name.
# For example, take this function:
f <- function(x) {
  x + y
}

# In many programming languages, this would be an error, because y is not defined inside the function.
# In R, this is valid code because R uses rules called lexical scoping to find the value associated with a name.
# Since y is not defined inside the function, R will look in the environment where the function was defined:
y <- 100
f(10)

y <- 1000
f(10)

# This behaviour seems like a recipe for bugs, and indeed you should avoid creating functions like this deliberately,
# but by and large it doesn't cause too many problems(especially if you regularly restart R to get to a clean slate).

# The advantage of this behaviour is that from a language standpoint it allows R to be very consistent.
# Every name is looked up using the same set of rules.
# For f() that includes the behaviour of two things that you might not expect: { and +. This allows you to do devious things like:
`+` <- function(x, y) {
  if (runif(1) < 0.1) {
    sum(x, y)
  } else {
    sum(x, y) * 1.1
  }
}
table(replicate(1000, 1 + 2))
rm(`+`)

# This is a common phenomenon in R. R places few limits on your power. You can do many things that you can't do in othe programming languages.
# You can do many things that 99% of the time are extremely ill-advised(like overriding how addition works!).
# But this power and flexibility is what makes tools like ggplot2 and dplyr possible.
# Learning how to make best use of this flexibility is beyond the scope of this book, but you can read about in Advanced R.
# (http://adv-r.had.co.nz/)
