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
# The technical term for delaying code in this way is __quoing__.
# Quoted code is like a bluepring for R computations.
# One important quoting funcitons in dplyr is vars().
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









# 4. Getting up to speed 



# 5. Dealing with multiple arguments



# 6. Modyfying inputs



# 7. Glossary


# Cookbooks -------------------------------------------------------------

# 8. dplyr



# 9. ggplot2





# Going further --------------------------------------------------------

# 10. A rich toolbox



# 11. Creating grammars

