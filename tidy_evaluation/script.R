# https://tidyeval.tidyverse.org


# Principles -------------------------------------------------------------

# 1. Introduciton

# Tidy evaluation is a set of concepts and tools that make it possible to use tidyverse grammars when columns are specified indirectly.
# In particular, you will need to learn some tidy eval to extract a tidyverse pipeline in a reusable function.

# 2. Why and how 

# Changin the context of evaluation is useful for four main purposes:
# - To Promote data grames to __full blown scopes__, where columns are exposed as named objects.
# - To execute your R code in a __foreign envionment__. For instance, dbplyr translates ordinary dplyr pipelines to SQL queries.
# - To execute your R code with a more performant __compiled language__. 
#   For instance, the dplyr package uses C++ implementations for a certain set of mathematical expressions to avoid executing slower R code when possible.
# - To implement __special rules__ for ordinary R operators.
#   For instance, selection functions such as `dplyr::select()` or `tidyr::gather()` implement specific behaviours for c(), `:` and `-`

# 2.1 Data masking 

# When the contents of the data frame are temporarily promoted as first class objects,
# we say the data __masks__ the workspace:
library("dplyr")
starwars %>% filter(
  height < 200,
  gender == "male"
)

# Compare to the wquivalent subsetting code where it is necessary to be explicit about where the columns come from:
starwars[starwars$height < 200 & starwars$gender == "male", ]

# Data makding is only possible because R allows suspending the normal flow of evaluation.
list(
  height < 200,
  gender == "male"
)
# > Error: object 'height' not found

# 2.2 Quoing code

# In order to change the context, evaluation must first be suspended before being resumed in a different envionment.
# The technical term for delaying code in this way is __quoting__.
# Quoted code is like a blueprints for R computations.
# One important quoting functions in dplyr is vars().
# This function does nothing but return its arguments as blueprints to be interpreted later on by verbs like `summarise_at()`
starwars %>% summarise_at(vars(ends_with("color")), n_distinct)

# If you call `vars()` alone, yuo get to see the blueprints!
vars(
  ends_with("color"),
  height:mass
)

exprs <- vars(height / 100, mass + 50)

rlang::eval_tidy(exprs[[1]])
# > Error in rlang::eval_tidy(exprs[[1]]) : object 'height' not found

rlang::eval_tidy(exprs[[1]], data = starwars)

# To sum up, the distinctive look and feel of data masking UIs requires suspending the mormal evaluations of R code.
# Once captured as quoted code, it can be resumed in a different context.

# 2.3 Unquoting code 

# Data masking functions prevent the normal evaluation of their arguments by quoting them.
# Once in possession of the blueprints of their arguments, a data mask is created and the evaluation is resumed in this new context.
# To make indirect references to columns, it is necessary to modify the quoted code before it gets evaluated.
# This is exactly what the `!!` operator is all about. It is a surgery operator for blueprints of R code.

# Expressoin that yield the same values can be freely interchanged, a property that is someties called `referential transparency`.
# The following calls to my_function() all yield the same results because they were givent the same values as inputs:
my_function <- function(x) x * 100

my_function(6)
my_function(2 * 3)

a <- 2
b <- 3
my_function(a * b)

# Because data masking functions evaluate their quoted arguments in a different cotext, they do not have this property:
starwars %>% summarise(avg = mean(height, na.rm = TRUE))

value <- mean(height, na.rm = TRUE)
# > Error in mean(height, na.rm = TRUE) : object 'height' not found
starwars %>% summarise(avg = value)
# > Error: object 'value' not found

# Storing a column name in a variable or passing one as function argument requires the tidy eval operator `!!`.
# The special operator, only avaliable in quoting functions, acts like a surgical operator for modifying blueprints.

# The `qq_show()` helper from rlang processes `!!` and prints the resulting blueprint of the computation.
x <- 1

rlang::qq_show(
  starwars %>% summarise(out = x)
)
# > starwars %>% summarise(out = x)

rlang::qq_show(
  starwar %>% summarise(out = !!x)
)
# > starwar %>% summarise(out = 1)

# What would it take to create an indirect reference to a column name? 
# Inlining the name as a string in blueprint will not produce what you expect:
col <- "height"

rlang::qq_show(
  starwars %>% summarise(out = sum(!!col, na.rm = TRUE))
)
# > starwars %>% summarise(out = sum("height", na.rm = TRUE))

tarwars %>% summarise(out = sum("height", na.rm = TRUE))
# > Error in eval(lhs, parent, parent) : object 'tarwars' not found

# To refer to column names inside a blueprint, we need to inline blueprint material.
# We need __symbols__:
sym(col)

# Symbols are a special type of string that represent other objects.
# When a piece of R code is evaluated, every bare variable name is actually a symbol that represents some values, 
# as defined in the surrent context.
rlang::qq_show(
  starwars %>% summarise(out = sum(!!sym(col), na.rm = TRUE))
)
# > starwars %>% summarise(out = sum(height, na.rm = TRUE))

# We're now ready to actually run the dplyr pipeline with an indirect reference:
starwars %>% summarise(out = sum(!!sym(col), na.rm = TRUE))

# There were two necessary steps to create an indirect reference and properly modigy the sammarising code:
# - We first created a piece of blueprint (a symbol) with sym().
# - We used `!!` to insert it in the blueprint captured by summarise().

# We call the combination of these two steps the __quote and unquote__ pattern.
# This pattern is the heart of programming with tidy eval functions.
# We quote an expression and unquote it in another quoted expression.
# This process is also called __interpolation__.

# 3. Do yuo need tidy eval?

# In computer science, frameworks like tidy evaluation are known as meataprogramming.
# Modifying the blueprints of computations amounts to programming the program., i.e. metaprogramming.

# Before dibing into tidy eval, make sure to know about the fundamentals of programming with the tidyverse.
# There are likely to have a better return on investment of time and will alse be useful to solve problems outside the tidyverse.

# - Fixed column names. A solid function taking data frames with fixed column names is better than a brittle function that uses tidy eval.
# - Automating loops. dplyr excels at automating loops. Acquiring a good command of rowwise vectorisation and columnwise mapping may prove very useful.

# Tidy evaluation is not all-or-nothing, it encompasses a wide range of features and techniquies.
# Here are a few techniques that are easy to pick up in your workflow:

# - Passing expressions through `{{` and `...`.
# - Passing couumn names to `.data[[` and `one_of()`.

# All these techniques make ti possible to reuse existing components of tidyverse grammars and compose them into new functions.

# 3.1 Fixed column names

# A simple solution is to write functions that expect data frames containing specific column names.
# In general, fixed column names are task specfic.

# Say we have a simple pipeline that computes the body mass index for each observation in a tibble:
starwars %>% transmute(bmi = mass / (height / 100) ^ 2)

# We could extract this code in a function that takes data frames with columns `mass` and `height`:
compute_bmi <- function(data) {
  data %>% transmute(bmi = mass / height^ 2)
}

# It's always a good idea to check the inputs of your functions and fail early with an informative error message when their assumptions are not met.
# In this case, we should validate the data frame and throw an error when it does not contain the expected cloumns:
compute_bmi <- function(data) {
  if (!all(c("mass", "height") %in% names(data))) {
    stop("`data` must contain `mass` and `height` columns")
  }
  data %>% transmute(bmi = mass / height^2)
}

iris %>% compute_bmi()
# >  Error in compute_bmi(.) : `data` must contain `mass` and `height` columns

# In fact, we could go even further and validate the contents of the columns in addition to their names:
compute_bmi <- function(data) {
  if (!all(c("mass", "height") %in% names(data))) {
    stop("`data` must contain `mass` and `height` columns")
  }
  
  mean_height <- round(mean(data$height, na.rm = TRUE), 1)
  if (mean_height > 3) {
    warning(glue::glue(
      "Average height is { mean_height }, is it scaled in meters?"
    ))
  }
  data %>% transmute(bmi = mass / height^2)
}
starwars %>% compute_bmi()
# > Warning message:
# > n compute_bmi(.) : Average height is 174.4, is it scaled in meters?

starwars %>% mutate(height = height / 100) %>% compute_bmi()

# Spending your programming time on the domain logic of your funciton, such as input and scale validation, 
# may have a greater payoff than learning tidy eval just to improve its syntax.
# It makes your function more robust to faulty data and reduces the risks of erroneous analyses.

# 3.2 Automating loops

# Most programming problems involve __iteration__ because data transformations are typically archieved element by elemnet, by applying the same recipe over and over again.
# There are two main ways of automating iteration in R, __vectorisation__ and __mapping__.

# 3.2.1 Vectorisation in dplyr
# dplyr is designed to optimise iteration by taking advantage of the vectorisation of many R functions.
# rowwise vectorisation is achieved through normal R rules, which dplyr augments with groupwise vectorisation.

# 2.2.1.1 Rowwise vectorisation

# A vectorised function is a function that works the same way with vectors of 1 element than with vectors of n elements. The operation is applied elementwise.
# One important class of vectorised functions are the arithmetic operators:

# Dividing 1 element
1 / 10

# Dividing 5 elenents
1:5 / 10

# Technically, a function is vectorised when:

# - It returns a vector as long as the input.
# - Applying the function on a single element yields the smae result than applying it on the whole vector and then subsetting the element.

# In other words, a vectorised function `fn` fulfills the following identity:
fn(x[[i]]) == fn(x)[[i]]

# When you mix vectorised and non-vectorised operations, the combined operation is itself vectorised when the last operation to run is vectorised.
x <- 1:5
x / mean(x)
# > [1] 0.3333333 0.6666667 1.0000000 1.3333333 1.6666667

# Note that the other combination of operations is not vectorised because in that case the summary operation has teh last word:
mean(x / 10)
# > [1] 0.3

# The dplyr verb `mutate()` expects vector semantics.
# The operations defining new columns typically return vecotrs as long as their inputs:
data <- tibble(x = rnorm(5, sd = 10))

data %>% 
  mutate(rescales = x / sd(x))

# In fact, `mutate()` enforces vectorisation. Returning smaller vectors is an error unless if they hae size 1.
# If the result of a mutate expression is a constant, it is automatically recycled to the tibble or group size.
data %>% 
  mutate(constant = sd(x))

# In contrast to `mutate()`, the dplyr verb `summarise()` expects summary operations that return single constants:
data %>% 
  summarise(sd(x))

# 3.2.1.2 Groupwise vectorisation
# Things get interesting with grouped tibbles.
# dplyr augments the vectorisation of normal R functions with groupwise vectorisation.
# If your tibble has `ngroup`, the operations are repeated `ngroup` times.
my_division <- function(x, y) {
  message("I was just called")
  x / y
}

# Called 1 time 
data %>% 
  mutate(new = my_division(x, 10))

gdata <- data %>% group_by(g = c("a", "a", "b", "b", "c"))

# Called 3 times
gdata %>% 
  mutate(new = my_division(x, 10))

# If the operation is entirely vectotised, the result will be the same whether the tibble is groupted or not, 
# since elementwise computatations are not affected by the values of other elements.
# But as soon as summary operations are involved, the result depends on the grouping structrue because the summaries are computed from group sections instead of thole columns.

# Marginal rescaling 
data %>% 
  mutate(new = x / sd(x))

# Conditional rescaling 
gdata %>% 
  mutate(new =  x / sd(x))
# Whereas rowwise vectorisation automates loops over the elements of a column,
# groupwise vectorisation automates loops over the levels of a gorupign speficitation.

# 3.2.2 Looping over columns 

# Rowwise and groupwise vextorisations are means of looping in the direction of rows, applying the same operation to each group and each element.
# Waht if you'd like to apply an operation in the direction of columns?
# This is possible in dplyr by __mapping__ funcions over columns.

# Mapping functions is part of the `functional programming` approach.
# If you're going to spend some time learnign new programming concepts, 
# acquiriing functional programming skills is likeliy to have a higher payoff than learning about the metaprogramming concepts of tidy evaluation.
# Functional ptogramming is inherent to R as it underlies the `apply()` family of functions in base R and the `map()` family from the `purrr package`.
# It is a powerful tool to add to your quiver.

# 3.2.2.1 Mapping functions

# Everything that exists in R is an object, including functions.
# If you type the name of a function without parentheses, 
# you get the funciton object instead of the result of calling the function:

toupper

# In its simplest form, functional programming is about passing a function object as argument to another function called a __mapper__ function, 
# that iterates over a vector to apply the function on each element, and returns all results in a new vector.
# In other words, a mapper functions writes loops so you don't have to.
# Here is a manual loop that applies `toupper()` over all elememts of a character vactor and returns a new vector:

new <- character(length(letters))

for (i in seq_along(letters)) {
  new[[i]] <- toupper(letters[[i]])
}

new

# Using a mpper function results in much leaner code.
# Here we apply `toupper()` over all elements of `letters` and return the results as a character vector, 
# as indicated by the suffix `_chr`:

new <- purrr::map_chr(letters, toupper)

# In practice, functional programming is all about hiding `for` loops, which are abstracted away by the mapper functions that automate the iteration.

# Mapping is an elegant way of transforming data elememt by element, but it's not the only one.
# For instance, `toupper()` is actually a vectorised function that already operates on while vectors element by element.
# The fastest and leanest code is just:

toupper(letters)

# mapping functions are more useful with functions that are not vectorised or for computations over lists and data frame columns where the vectorisation occurs within the elements or columns themselves.
# In the following example, we apply a summarising funciton over all columns of a data frame:

purrr::map_int(mtcars, n_distinct)

# 3.2.2.2 Scoped dplyr variants

# dplyr provides variants of the main data manipulation verbs that map functions over a selection of columns.
# These verbs are known as the `scoped variants` and are recognizable from their `_at`, `_if` and `_all` sufffixes.

# Scoped verbs support three sorts of selection:

# 1. `_all` verbs operate on all columns of the data frame.
#     You can summarise all columns of a data frame within groups with `summarise_all()`:
iris %>% group_by(Species) %>% summarise_all(mean)

# 1. `_if` verbs operate conditionally, on all columns for which a predicate returns `TRUE`.
#     If you are familiar with purrr, the idea is similar to the conditional mapper `purrr::map_if()`.
#     Promoting all character columns of a data grame as grouping variables is as simple as:
starwars %>% group_by_if(is.character)

# 3. `_at` verbs operate on a selection of columns.
#     You can supply integer vectors of column opsitions or character vectors of column names.
mtcars %>% summarise_at(1:2, mean)

mtcars %>% summarise_at(c("disp", "drat"), median)

# More interestingly, you can use `vars()` to supply the same sort of expressions you would pass to `select()`!
# The selection helpers make it very convenient to craft a selection of columns to map over.
starwars %>% summarise_at(vars(height:mass), mean, na.rm = TRUE)
# * `vars()` is the function that does the quoting of your expressions, and returns blueprints to its caller.
# * This pattern of letting an external helper quote the arguments is called `external quoting`.

starwars %>% summarise_at(vars(ends_with("_color")), n_distinct)

# The scoped variants of `mutate()` and `summarise()` are the closest analogue to `base::lapply()` and `purrr::map()`.

# map() returns a simple list with the results
mtcars[1:5] %>% purrr::map(mean)

# `mutate_` variants recycle to group size
mtcars[1:5] %>% mutate_all(mean)

# `summarise_` variants enforce a size 1 constraint
mtcars[1:5] %>% summarise_all(mean)

# All scoped verbs know about groups
mtcars[1:5] %>% group_by(cyl) %>% summarise_all(mean)

# The other scoped variants also accept optional functions to map over the selection of columns.
# For instance, you could group by a selection of variables and transform them on the fly:
iris %>% group_by_if(is.factor, as.character)

# or transform the column names of selected variables:
storms %>% select_at(vars(name:hour), toupper)

# The scoped variants lie at the intersection of purrr and dplyr and combine the rowwise looping mechanisms of dplyr with the columnwise mapping of purrr.
# This is a powerful combination.

# 4. Getting up to speed 

# While tidyverse grammars are easy to write in scripts and at the console, they make it a bit harder to reduce code duplication.
# Writing functions around dplyr pipelines and other tidyeval APIs requires a bit of special knowledge because these APIs use a special type of functions called __quoting functions__ in orer to make data first class.

# If one-off code is often reasonable for common data analysis tasks, it is good practice to write reusable functions to reduce code duplication.
# In this introduction, you will learn about quoting functions, what challenges they pose for programming, and the solutions that __tidy evaluation__ provides to solve those problems.

# 4.1 Writing functions

# 4.1.1 Reducing duplication

# Writing functions is essential for the clarity and robustness of your code. Functions have several advantages:

# 1. They prevent inconsistencies because they force multiple computations to follow a single recipe.
# 2. They emphasise that varies (the arguments) and tha tis constant (every other component of the computation).
# 3. They make change easier because you only need to modify one place.
# 4. They make your code clearer if you give the function and its arguments informative names.

# The precess for creating a function is straightforward.
# First, recognise dulplication in your code. A good rule of thumb is to create a function when you have copy-pasted a piece of code three times.
# Can you spot the copy-paste mistake in this duplicated code?
(df$a - min(df$a)) / (max(df$a) - min(df$a))
(df$b - min(df$b)) / (max(df$b) - min(df$b))
(df$c - min(df$c)) / (max(df$c) - min(df$c))
(df$d - min(df$d)) / (max(df$d) - min(df$c))

# Now identify the varying parts of the expression and give each a name.
# `x` is an easy choice, but it is often a good idea to reflect the type of argument expected in the name.
# In our case we expect a numeric vector:
(num - min(num)) / (max(num) - min(num))
(num - min(num)) / (max(num) - min(num))
(num - min(num)) / (max(num) - min(num))
(num - min(num)) / (max(num) - min(num))

# We can now create a function with a relevant name:
rescale01 <- function(num) {
  
}

# Fill it with our deduplicated code:
rescale01 <- function(num) {
  (num - min(num)) / (max(num) = min(num))
}

# And refactor a little to reduce duplication further and handle more cases:
rescale01 <- function(num) {
  rng <- range(num, na.rm = TRUE, finite = TRUE)
  (num - rng[[1]]) / (rng[[2]] - rng[[1]])
}

# Now you can reuse your function any place you need it:
rescale01(df$a)
rescale01(df$b)
rescale01(df$c)
rescale01(df$d)

# Reducing code fuplication is as much needed with tidyverse grammars as with ordinary computations.
# Unfortunately, the straightforward process to create functions breaks down with grammars like dplyr, which we attach now.
library("dplyr")

# To see the problem, let's use the same function-writing process with a duplicated dplyr pipeline:
df1 %>% group_by(x1) %>% summarise(mean = mean(y1))
df2 %>% group_by(x2) %>% summarise(mean = mean(y2))
df3 %>% group_by(x3) %>% summarise(mean = mean(y3))
df4 %>% group_by(x4) %>% summarise(mean = mean(y4))

# We first abstract out the varying parts by giving them informative names:
data %>% group_by(group_var) %>% summarise(mean = mean(summary_var))

# And wrap the pipeline with a funciton taking these argument names:
grouped_mean <- function(data, group_var, summary_var) {
  data %>% 
    group_by(group_var) %>% 
    summarise(mean = mean(summary_var))
}

# Unfortunately this function doesn't actually work.
# When you call it dplyr complains that the variable `group_var` is unknown:
grouped_mean(mtcars, cyl, mpg)
# >  Error: Column `group_var` is unknown 

# Here is the proper way of defining this function:
grouped_mean <- function(data, group_var, summary_var) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  
  data %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}

grouped_mean(mtcars, cyl, mpg)

# To understand how that works, we need to learn about quoting functions and what special steps are needed to be effective at programming with them.
# really we only need two new concepts forming together a single pattern: quoting and unquoting.
# Thsi introduction will get you up to speed with this pattern.

# 4.1.2 What's special about quoting functions?

# R functions can be categorised in two broad categories: `evaluating funcitons` and `quoting functions`.
# These functions differ in the way they get their arguments.
# Evaluating functinos take arguments as __values__.
# It does not matter what the expression supplied as argument is or which objects it contains.
# R computes the arugment value following the standard rules of evaluation which the function receives passively.

# The simplest regular functions is `idnetity()`. It evalutes its single argument and returns the value.
# Because only the final value of the argument matters, all of these statement are completely equivalent:
identity(6)
# > [1] 6
identity(2 * 3)
# > [1] 6
identity(a * b)
# > [1] 6

# On the other hand, a quoting function is not passed the value of an expression, it is passed the expression itself.
# We say the arguments has been automatically quoted.
# The simplest quoting function is `quote()`. 
# It automatically quotes its argument and returns the quoted expresssion without any evaluation.
# Because only the expression passed as argument matters, none of these statements are equivalent:
quote(6)
# > [1] 6
quote(2 * 3)
# > 2 * 3
quote(a * b)
# > a * b

# Other familiar quoting operators are `""` and `~`. The `""` operator quotes a peice of text at parsing time and returns a string.
# This prevents the textx from being interpreted as some R code to evaluate.
# The tilde operator is similar to the `quote()` function in that it prevents R code from being automatically evaluated and returns a quoted expression in the form of a formula.
# The expression is then used to define a statistical model in modeling functions.
# The three following expressions are doing somethign similar, they are quoting their input:
"a * b"
# > [1] "a * b"
~ a * b
# > ~a * b
quote(a * b)
# > a * b
# The first statement returns a quoted strign and the other two return quoted code in a formula or as a bare expressotin.

# 4.1.2.1 Quoting and evaluating in mundane R code
# As an R programmer, you are probably already familiar with the distinction between quoting and evaluating functions.
# Take the case of subsetting a data frame cloumn by name.
# The `[[` and `$` operators are buth standard for this task but they are used in very different situations.
# The former supports indirect references like varialbes or expressions that represent a column name while the latter takes a column name directly:
df <- data.frame(
  y = 1, 
  var = 2
)

df$y
# > [1] 1

var <- "y"
df[[var]]
# > [1] 1

# Technically, `[[` is an evaluating function while `$` is a quoting funciton.
# You can indirectly refer to columns with `[[` because the subsetting index is evaluated, allowing indirect references.
# The following expressions are completely equivalent:
df[[var]] # Indirect
# > [1] 1

df[["y"]] # Direct
# > [1] 1

# But these are not: 
df$var # Direct
# > [1] 2
df$y # Direct
# > [1] 1

# The following table summarises the fundamental asymmetry between the two subsetting methods:
# |----------|--------|-----------|
# |          | Qouted | Evaluated | 
# |----------|--------|-----------|
# | Direct   | df$y   | df[["y"]] |
# |          |        |           |
# | Indirect | ???    | df[[var]] | 
# |----------|--------|-----------|

# 4.1.2.2 Detecting quoting quoting functions

# Because they work so differently to standard R code, it is important to recognise auto-quoted qrguments.
# The doucmentation of the quoting function should normally tell you if an argumnet is quoted and evaluated in a special way.
# You can also detect quoted arguments by yourself with some experimentation.
# Let's take the following expressions involving a  mix of quoging and evaluating functions:
library(MASS)

mtcars2 <- subset(mtcars, cyl == 4)
sum(mtcars2$am)
rm(mtcars2)

# A good indication that an argument is auto-quoted and evaluated in a special way is that the argument will not work correctly outside of its original context.
# Let's try to break down each of these expressions in two steps by storing the arguments in an intermediary variable: 

# 1. `library(MASS)`
temp <- MASS
# > Error in eval(expr, envir, enclos): object 'MASS' not found

temp <- "MASS"
library(!!temp)
# > Error in library(temp) : there is no package called ‘temp’

# We get these errors because there is no `MASS` object for R to find, and `temp` is interpreted by `library()` directly as a package anme rather than as an indirect reference.
# Let's try to break down the subset() expression:

# 2. `mtcars2 <- subset(mtcars, cyl == 4)`
temp <- cyl == 4
# > Error in eval(expr, envir, enclos): object 'cyl' not found
# R cannot find `cyl` because we haven't specified where to find it.
# This object exists only inside the `mtcars` data frame.

# 3. `sum(mtcars$an)`
temp <- mtcars$am
sum(temp)
# > [1] 13
# It worked! `sum()` is an evaluating function and the indirect reference was resolved in the ordinary way.

# 4. `rm(mtcars2)`
mtcars2 <- mtcars
temp <- "mtcars2"
rm(temp)

exists("mtcars2")
# > [1] TRUE
exists("temp")
# > [1] TRUE
# This time there was no error, but we have accidentally removed the variable `temp` instead of the variable it was referring to.
# This is because `rm()` auto-quotes its arguments.

# 4.1.3 Unquotation

# In practice, functions that evaluate their arguments are easier to program with because they support both direct and indirect references.
# For quotign functions, a piece of syntax is missing. We need the ability to __unquote__ arguments.

# 4.1.3.1 Unquoting in base R

# Base R provides three different ways of allowing direct referneces:

# 1. An extra function that evaluates its arguments. For instance the evaluating variant of the `$` operator is `[[`.
# 2. An extra parameter that switches off auto-quotign. For instance `library()` evaluates its first argument if you set `character.only` to `TRUE`.
temp <- "MASS"
library(temp, character.only = TRUE)

# 3. An extra parameter that evaluates its argument. If you have a list of object names to pass to `rm()`, use the `list` argument:
temp <- "mtcars2"
rm(list = temp)
exists("mucars2")
# > [1] FALSE

# There is no general unquoting convention in base R so you have to read the documenttation to figure ou how to unquote an argument.
# Many functions like `subset()` or `transform()` do not provide any unquoting option at all.

# 4.1.3.2 Unquoting in the tidyverse!!

# All quoting functions in the tidyverse support a single unquotation mechanism, the `!!` operator.
# You can use `!!` to cancel the automatic quotation and supply indirct references everywhere an argument is automatically quoted.
# In other words, unquoting lets you opena variable and use what's inside instead.

# First let's create a couple of variables that hold references to columns from the `mtcars` data frame.
# A simple way of creating these references is to use the fundamental qouting function `quote()`:

# Variables referring to columns `cyl` and `mpg`
x_var <- quote(cyl)
y_var <- quote(mpg)
x_var
# > cyl
y_var
# > mpg

# Here are a few exmaples of how `!!` can be used in tidyverse functions to unquote these variables, i.e. open them and use their contents.

# 1. In dplyr most verbs quote their arguments:
library("dplyr")

by_cyl <- mtcars %>% 
  group_by(!!x_var) %>%            # Open x_var
  summarise(mean = mean(!!y_var))  # Open y_var

# 2. In ggplot2 `aes()` is the main quoting function:
library("ggplot2")

ggplot(mtcars, aes(!!x_var, !!y_var)) + # Open x_var and y_var
  geom_point()

# ggplot2 also features `vars()` which is useful for facetting:
ggplot(mtcars, aes(disp, drat)) + 
  geom_point() + 
  facet_grid(vars(!!x_var)) # Open x_var

# Being able to make indirect references by opening variables with `!!` is rarely useful in scripts but is invaluable for writing functions.
# With `!!` we can now easily fix our wrapper function, as we'll see in the following seciton.

# 4.1.4 Understanding `!!` with `qq_show()`

# At this point it is normal if the concept of unquotign still feels nebulous.
# A good way of practicing this operation is to see for yourself what it is really doing.
# To that end the `qq_show()` function from the rlang package performs unquoting and prints the result to the screen.
# Here is what `!!` is really doing in the dplyr example(I've broken the pipeline into two steps for readability):
rlang::qq_show(mtcars %>% group_by(!!x_var))
# > mtcars %>% group_by(cyl)

rlang::qq_show(data %>% summarise(mean = mean(!!y_var)))
# > data %>% summarise(mean = mean(mpg))

# Similarly for the ggplot2 pipeline:
rlang::qq_show(ggplot(mtcars, aes(!!x_var, !!y_var)))
# > ggplot(mtcars, aes(cyl, mpg))
rlang::qq_show(facet_grid(vars(!!x_var)))
# > facet_grid(vars(cyl))

# As you can see, unquoting a variable that contains a refernece to the column `cyl` is equivalent to directly supplying `cyl` to the dplyr function.

# 4.2 Quote and unquote

# The basic process for creating tidyeval functions requires thinking a bit differently but is gtraightforward: quote and unquote.
# 1. Use `enquo()` to make a function automatically quote its argument.
# 2. Use `!!` to unquote the argument.

# Apart from these additional two steps, the process is the same.

# 4.2.1 Teh abstraction step 

# We start as usual by idnetifying the varing parts of a computation and giving them informative names.
# These names become the arguments to the function.
grouped_mean <- function(data, group_var, summary_var) {
  data %>%
    group_by(group_var) %>% 
    summarise(mean = mean(summary_var))
}

# As we have seen earlier this function does not quite work yet so let's fix it by applying the two new steps.

# 4.2.2 The quoting step 
# The qutoing step is about making our ordinary function a quoting function. Not all parameters should be automatically quoted though.
# For instantce the `data` argument refers to a real data frame that is passed around in the ordinary way.
# It is cruicial to identify which parameters of your function should be automatically quoted: the parameters for which it is allowed to refer to columns in the data frames.
# In the exmaple, `group_var` and `summary_var` are the parameters that refer to the data.

# We know that the fundamental quoting function is `quote()` but how do we go about creating other quoting functions?
# This is the job of `enquo()`. While `quote()` quotes what you typed, `enquo()` quotes what your user typed.
# In other words it makes an argument automatically quote its input.
# This is exactly how dplyr verbs are created!
# Here is how to apply `enquo()` to the `group_var` and `summary_var` arguments:
group_var <- enquo(group_var)
summary_var <- enquo(summary_var)

# 4.2.3 The unquoting step
# Finally we identity any place where these variables are passed to other quoting functions.
# That's where we need to unquote with `!!`.
# In this case we pass `group_var` to `group()` and `summary_var` to `summarise()`:
data %>% 
  group_by(!!group_var) %>% 
  summarise(mean = mean(!!summary_var))

# 4.2.4 Result 
# The finished function looks like this:
grouped_mean <- function(data, group_var, summary_var) {
  group_var <- enquo(group_var)
  summary_var <- enquo(summary_var)
  
  data %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}

# And voilà!
grouped_mean(mtcars, cyl, mpg)
# > # A tibble: 3 x 2
# > cyl  mean
# > <dbl> <dbl>
# > 1     4  26.7
# > 2     6  19.7
# > 3     8  15.1

grouped_mean(mtcars, cyl, disp)
#> # A tibble: 3 x 2
#>     cyl  mean
#>   <dbl> <dbl>
#> 1     4  105.
#> 2     6  183.
#> 3     8  353.

grouped_mean(mtcars, am, disp)
#> # A tibble: 2 x 2
#>      am  mean
#>   <dbl> <dbl>
#> 1     0  290.
#> 2     1  144.

# This simple quote-and-unquote pattern willl get you a long way.
# It makes it possible to abstract complex combinations of quoting functions into a new quoting fucntion.
# However this gets us in a sort of loop:quoting functions unquote inside other quoting functions and so on.
# At the strat of the loop is the user typing expressions that are automatically quoted.
# But what if we can't or don't awnt ot start with expressions typed by the user?
# What if we'd like to start with a character vector of column names?

# 4.3 Strings instead of quotes

# So far we have created a quoting function that wraps around other quoting functions.
# How can we break this chain of quoting? How can we go from the evaluating world to the quoting universe?
# The most common way this transition occurs is when you stsart with a character vector of column names and somehow
# need to pass the corresponding columns to quoting funtions like `dplyr::mutate()`, `dplyr::select()`, or `ggplot2::aes()`.
# We need a way of bridging evaluating and quoting functions.

# First let's see why simply unquoting strings does not work:
var <- "height"
mutate(starwars, rescaled = !!var * 100)
# > Error in "height" * 100 : non-numeric argument to binary operator

# We get a type error. Observing the result of unquoting with qq_show() will shed some light on this:
rlang::qq_show(mutate(starwars, rescaled = !!var * 100))
# > mutate(starwars, rescaled = "height" * 100)

# We have unquoted a string, and now dplyr tried to mutiply htat string by 100!

# 4.3.1 Strings

# There is a fundamental difference between these two objects:
"height"
# > [1] "height"

quote(height)
# > height

# `"height"` is a string and `quote(height)` is a __symbol__, or variable name.
# A symbol is much more than a string, it is a reference to an R object.
# That's why you have to use symbols to refer to data frame columns.
# Forunately transforming strings to symbols if straightorward with the tidy eval `sym()` function:
sym("height")
# > height

# If you use `sym()` instead of `enquo()`, you end up with an evaluating function that transforms its inpurs into symbols that can suitably be unquotedd:
grouped_mean2 <- function(data, group_var, summary_var) {
  group_var <- sym(group_var)
  summary_var <- sym(summary_var)
  
  data %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}
# With this simple change we now have an evaluating wrapper which can be used in the same way as `[[`.
# You can call `grouped_mean2()` with direct references:
grouped_mean2(starwars, "gender", "mass")
#> # A tibble: 5 x 2
#>   gender          mean
#>   <chr>          <dbl>
#> 1 <NA>            46.3
#> 2 female          NA  
#> 3 hermaphrodite 1358  
#> 4 male            NA  
#> 5 none            NA

# Or indirect referencts:
grp_var <- "gender"
sum_var <- "mass"
grouped_mean2(starwars, grp_var, sum_var)
#> # A tibble: 5 x 2
#>   gender          mean
#>   <chr>          <dbl>
#> 1 <NA>            46.3
#> 2 female          NA  
#> 3 hermaphrodite 1358  
#> 4 male            NA  
#> 5 none            NA

# 4.3.2 Character vectors of column names

# What if you have a whole character vector of column names?
# You can transform vectors to list of symbols with the plural variant `syms()`:
cols <- syms(c("species", "gender"))
cols
#> [[1]]
#> species
#> 
#> [[2]]
#> gender

# But now we have a list. Can we just unquote a list of symbols with `!!`?
group_by(starwars, !!cols)
# > Error: Column `<list>` must be length 87 (the number of rows) or one, not 2

# Something's wrong. Using qq_show(), we see that `group_by()` gets a list instead fo the individual symbols:
rlang::qq_show(group_by(starwars, !!cols))
# > group_by(starwars, <list: species, gender>)

# We should unquote each symbol in the list as a separate argument. The big bang operator `!!!` makes this easy:
rlang::qq_show(group_by(starwars, !!cols[[1]], !!cols[[2]]))
# > group_by(starwars, species, gender)

rlang::qq_show(group_by(starwars, !!!cols))
# > group_by(starwars, species, gender)

# Working with multiple arguments and list of expressions requires specific techniques such as using `!!!`.
# these techniques are covered in the next chapter.

# 5. Dealing with multiple arguments

# In the first chapter we hae created `grouped_mean()`, a fucntion that takes one grouping variable and one summary variable and computes teh grouped average.
# It would make sense to take multiple grouping variables instead of just one.
# Quoting and unquoting multiple varaibles is pretty much the same process as for single arguments:

# - Unquoting multiple arguments requires a variant of `!!`, the big bang operator `!!!`.
# - Quoting multiple arguments can be done in two ways: interanl quoting with the plural variant `enquos()` and external quoting with `vars()`.

# 5.1 The `...` argument
# The dot-dot-dot argument is one of the nicest aspects of the R language.
# A function that takes `...` accepts any number of arguments, named or unnamed.
# As a programmer you can do three things with `...`.

# 1. __Evaluate__ the arguments contained in the dots and materialise them in a list by forwarding the dots to `list()`:
materialise <- function(data, ...) {
  dots <- list(...)
  dots
}

# The dots names conveniently become the names of the list:
materialise(mtcars, 1 + 2, important_name = letters)
#> [[1]]
#> [1] 3
#> 
#> $important_name
#>  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q"
#> [18] "r" "s" "t" "u" "v" "w" "x" "y" "z"

# 2. __Quote__ the arguments in the dots with `enquos()`:
capture <- function(data, ...) {
  dots <- enquos(...)
  dots
}

# All arguments passed to `...` are automatically quoted and returned as a list.
# The names of the arguments become the names of that list:
capture(mtcars, 1 + 2, important_name = letters)

# 3. __Forward__ the dots to another function:
forward <- function(data, ...) {
  forwardee(...)
}

# When dots are forwarded the names of arguments in `...` are matched to the arguments of the forwardee:
forwardee <- function(foo, bar, ...) {
  list(foo = foo, bar = bar, ...)
}

# Let's call the forwarding function with a bunch of named and unnamed arguments:
forward(mtcars, bar = 100, 1, 2, 3)
#> $foo
#> [1] 1
#> 
#> $bar
#> [1] 100
#> 
#> [[3]]
#> [1] 2
#> 
#> [[4]]
#> [1] 3

# The unnamed argument `1` was matched to `foo` positionally.
# The named argument `bar` was matched to `bar`.
# The remaining arguments were passed in order.

# For the purpose of writing tidy eval functions the last two techniques are important. There are two distinct situations:

# 1. You don't need to modify the arguments in any way, just passing them through.
#    Then simply forward `...` to other quoting functions in the ordinary way.
# 2. You'd like to change the argument names(which become column names in `dplyr::mutate()` calls) or modify the arguments themselves (for instance negate a `dplyr::select()` ion).
#    In that case you'll need to use `enquos()` to quote the arguments in the dots.
#    You'll then pass the quoted arguments to other quoting functions by forwarding them with the help of `!!!`.

# 5.2 Simple forwarding of `...`
# If you are not modigying the arguments in `...` in any way and just want to pass them to another quoting funciton, just forward `...` like usual!
# There is no need for quoting and unquoting because of the magic of forwarding.
# The arguments in `...` are transported to their final destination where they will be quoted.

# The function `group_mena()` is still going to need some remodelling because it is good practice to take all important named arguments before the dots.
# Let's start by swappign `grouped_var` and `summary_var`:
grouped_mean <- function(data, summary_var, group_var) {
  summary_var <- enquo(summary_var)
  group_var <- enquo(group_var)
  
  data %>% 
    group_by(!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}

# Then we replace `group_var` with `...` and pass it to `group_by()`:
grouped_mean <- function(data, summary_var, ...) {
  summary_var <- enquo(summary_var)
  
  data %>% 
    group_by(...) %>% 
    summarise(mean = mean(!!summary_var))
}

# It is good practice to make one final adjustment.
# Because arguments in `...` can have arbitrary names, we don't want to "use up" valid names.
# In tidyverse packages we use the convention of prefixing named arguments with a dot so that conflicts are less likely:
grouped_mean <- function(.data, .summary_var, ...) {
  .summary_var <- enquo(.summary_var)
  
  .data %>% 
    group_by(...) %>% 
    summarise(mean = mean(!!.summary_var))
}

# Let's check this function now works with any number of grouping variables:
grouped_mean(mtcars, disp, cyl, am)
#> # A tibble: 6 x 3
#> # Groups:   cyl [3]
#>     cyl    am  mean
#>   <dbl> <dbl> <dbl>
#> 1     4     0 136. 
#> 2     4     1  93.6
#> 3     6     0 205. 
#> 4     6     1 155  
#> 5     8     0 358. 
#> # … with 1 more row

grouped_mean(mtcars, disp, cyl, am, vs)
#> # A tibble: 7 x 4
#> # Groups:   cyl, am [6]
#>     cyl    am    vs  mean
#>   <dbl> <dbl> <dbl> <dbl>
#> 1     4     0     1 136. 
#> 2     4     1     0 120. 
#> 3     4     1     1  89.8
#> 4     6     0     1 205. 
#> 5     6     1     0 155  
#> # … with 2 more rows

# 5.3 Quote multiple arguments

# When we need to modigy the arguments or their names, we can't simply forward the dots.
# We'll have to quote and unquote with the plural variants of `enquo()` and `!!`.

# - We'll quote the dots with `enquos()`.
# - We'll unquote-splice the quoted dots with `!!!`.

# While the sinfular `enquo()` returns a single quoted argument, the plural variant `enquots()` returns a list of quoted argumetns.
# Let's use it to quote the dots:
grouped_mean2 <- function(data, summary_var, ...) {
  summary_var <- enquo(summary_var)
  group_vars <- enquos(...)
  
  data %>% 
    group_by(!!group_vars) %>% 
    summarise(mean = mean(!!summary_var))
}

# `group_mena2()` now accrpts and automatically quotes any number of grouping variables.
# However it doesn't work quite yet:

# __FIXME__: Depend on dev rlarn to get a better error message.
grouped_mean2(mtcars, disp, cyl, am)
# > Error: Column `<S3: quosures>` must be length 32 (the number of rows) or one, not 2 

# Instead of forwarding the individual arguments to `group_by()` we have passed the list of arguments itself!
# Unquoting is not the right operation here.
# Forrunately tidy eval provides a special operator that makes it easy to forward a list of arguments.

# 5.4 Unquote multiple arguments

# The __unquote-splice__ operator `!!!` takes each element of a list and unquotes them as independent arguments to the surrounding function call.
# This is just what we need for forwarding multiple quoted arguments.

# Let's use `qq_show()` to observe the difference between `!!` and `!!!` in a `group_by()` expression.
# We can only use `enquos()` within a function so let's create a list of quoted names for the purpose of experimenting:
vars <- list(
  quote(cyl),
  quote(am)
)

rlang::qq_show(group_by(!!vars))
# > group_by(<list: cyl, am>)

rlang::qq_show(group_by(!!!vars))
# > group_by(cyl, am)

# When we use the unquote operator `!!`, `group_by()` gets a list of expressions.
# When we unquote-splice with `!!!`, the expressions are forwarded as individual arguments to `group_by()`.
# Let's use the latter to fix `grouped_mean2()`:
group_mean2 <- function(.data, .summary_var, ...) {
  summary_var <- enquo(.summary)
  group_var <- enquos(...)
  
  data %>% 
    group_by(!!!group_var) %>% 
    summarise(mean = mean(!!summary_var))
}

# The quote and unquote version of `grouped_mean()` does a bit more work but is funcitonally identical to the forwarding version:
grouped_mean(mtcars, disp, cyl, am)
#> # A tibble: 6 x 3
#> # Groups:   cyl [3]
#>     cyl    am  mean
#>   <dbl> <dbl> <dbl>
#> 1     4     0 136. 
#> 2     4     1  93.6
#> 3     6     0 205. 
#> 4     6     1 155  
#> 5     8     0 358. 
#> # … with 1 more row

grouped_mean2(mtcars, disp, cyl, am)
#> # A tibble: 6 x 3
#> # Groups:   cyl [3]
#>     cyl    am  mean
#>   <dbl> <dbl> <dbl>
#> 1     4     0 136. 
#> 2     4     1  93.6
#> 3     6     0 205. 
#> 4     6     1 155  
#> 5     8     0 358. 
#> # … with 1 more row

# When does it become useful to do all this extra work?
# Whenever you need to modify the arguments or their names.

# Up to now we have used the quote-and-unquote pattern to pass quoted arguments to other quoting functions "as is".
# With simple and powerful pattern you can extract complex combinations of quoting verbs into reusable functions.

# However tidy eval provides much more flexibility.
# It is a general purpose meta-programming frameword that makes it easy to modify quoted arguments before evaluation.
# In the next section you'll learn about basic metaprogramming patterns that will allow you to modify expressions before passing them on to other functions.

# 6. Modyfying inputs



# 7. Glossary


# Cookbooks -------------------------------------------------------------

# 8. dplyr



# 9. ggplot2





# Going further --------------------------------------------------------

# 10. A rich toolbox



# 11. Creating grammars

