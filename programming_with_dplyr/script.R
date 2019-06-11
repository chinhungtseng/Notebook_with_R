# Programming with dplyr
# https://dplyr.tidyverse.org/articles/programming.html
library(tibble)
library(dplyr)


# most dplry argument are not referentially transparent.
# That means you can't replace a value with a seemimgly equivalent object that you've defined elsewhere.
# In other words, this code:
df <- tibble(x = 1:3, y = 3:1)

filter(df, x == 1)
df[df$x == 1, ]

# Is not equivalent to this code:
my_var <- x
filter(df, my_var == 1)

# not to this code:
my_var <- "x"
filter(df, my_var == 1)
# This makes it hard to create functions with arguments that change how dplyr verbs are computed.

# dplyr code is ambiguous. Depending on what variables are defined where, filter(df, x == y) could be equivalent to any of:
df[df$x ==df$y, ]
df[df$x == y, ]
df[x ==df$y, ]
df[x == y, ]
# This is useful when working interactively (because it saves typing and you quickly spot problems) but makes funcitons more unpredictable than you might desire.

# This vignette has two goals:
# 1. Show you how to use dplyr's pronouns and quasiquotation to write reliable functions that reduce duplication in your data analysis code.
# 2. To teach you the underlying theory including quosures, the data structure that stores both an expressing and an envionment, and tidyeval, the underlying toolkit.

# Warm up 

# You might not have realised it, but you're already acomplished at solving this type of problem in another domaain: string. It's obvious that this function doesn't do what you want:
greet <- function(name) {
  "How do you do, name"
}
greet("Hadley")
# That's because " "quotes" its input: it doesn't interpret what you've typed, it just stores it in a string.
# One way to make the function do what you want is to use paste() to build up the string peice by piece:
greet <- function(name) {
  paste0("How do you do, ", name, "?")
}
greet("Hadley")

# Another approach is exemplified by the glue package:
greet <- function(name) {
  glue::glue("How do you do, {name}?")
}
greet("Hadley")

# Programming recipes

# Different data sets
# You already know how to write functions that work with the first argument of dplyr verbs: the data.
# That's because dplyr doesn't do anything special with that argument, so it's referentially transparent.
# For exmaple, if you saw repeated code like this:
mutate(df1, y = a + x)
mutate(df2, y = a + x)
mutate(df3, y = a + x)
mutate(df4, y = a + x)

# You could already write a function to capture that duplication:
mutate_y <- function(df) {
  mutate(df, y = a + x)
}

# Unfortunately, there's a drawback to this simple attroach: it can fail silently if one of the variables isn't present in the data frame, but is present in the global environment.
df1 <- tibble(x = 1:3)
a <- 10
mutate_y(df1)

# We can fix that ambiguty by being more explicit and using the .data pronoun.
# This will throw an informative error if the variable doesn't exist:
mutate_y <- function(df) {
  mutate(df, .data$a + .data$x)
}
mutate(df1)

# Different expressions

# Writing a function is hard if you want one of the arguments to be a varialbe name(like x) or an expression (like x + y).
# That's because dplyr automatically "quotes" those inputs, so they are not refernetially transparent.
df <- tibble(
  g1 = c(1, 1, 2, 2, 2),
  g2 = c(1, 2, 1, 2, 1),
  a = sample(5), 
  b = sample(5)
)

df %>% 
  group_by(g1) %>% 
  summarise(a = mean(a))

df %>% 
  group_by(g2) %>% 
  summarise(a = mean(a))

# You might hope that this will work:
my_summarise <- function(df, group_var) {
  df %>% 
    group_by(group_var) %>% 
    summarise(a = mean(a))
}

my_summarise(df, g1)
# But it doesn't.

# Mayby providing the variable names as a string will fix things?
my_summarise(df, "g2")
# Nope.

# If you look carefully at the error message, you'll see that it's the same in both cases.
# group_by() works like ": it doesn't evaluate its input; it quotes it.

# To make this function work, we need to do two things.
# We need to quote the input ourselves(so my_summarise() can take a bare variable name like group_by(), and then we need to tell group_by()) not to quote its input(because we've done the quoting).

# How do we quote the input? We can't use "" to quote the input, because that gives us a stirng.
# Instead we need a function that captures the expression adn its envionment (we'll come back to why this is important later on).
# There are two possible options we could use in base R, the function quote() and the operator ~.
# Neither of these work quite the way we want, so we need a new function:quo().

# quo() works like ": it quotes its input rather than evaluating it.
quo(g1)
quo(a + b + c)
quo("a")

# quo() returns a quosure, which is a special type of formula. You'll learn more about quosures later on.

# Now that we've captured this expression, how do we use it with group_by()? 
# It doesn't work if we just shove it into our naive approach:
my_summarise(df, quo(g1))

# We get the same error as before, because we havent't yet told group_by() that we're taking care of the quoting.
# In other words, we need to tell group_by() not to quote its input, because it has been pre-quoted by my_summarise().
# Yet another way of saying the same thing is that we want to unquote group_var.

# In dplyr(and in tidyeval in general) you use !! to say that you want to unquote an input so that it's evaluated, not quoted.
# This gives us a function that actually does what we wnat.
my_summarise <- function(df, group_var) {
  print(group_var)
  df %>% 
    group_by(!! group_var) %>% 
    summarise(a = mean(a))
}

my_summarise(df, quo(g1))
# Huzzah!

# There's just one step left: we want to call this function like we call group_by():
my_summarise(df, g1)

# This doesn't work because there's no object called g1.
# We need to capture what the user of the functiontyped and quote it for them.
# You might try using quo() to do that:

my_summarise <- function(df, group_var) {
  quo_group_var <- quo(group_var)
  print(quo_group_var)
  
  df %>% 
    group_by(!! quo_group_var) %>% 
    summarise(a = mean(a))
}

my_summarise(df, g1)

# I've added a print() call to make it obvious what's going wrong here: quo(group_var) always returns ~group_var.
# It is being too literal! We want it to subsitute the value that the user supplied, i.e. to return ~g1.

# By analogy to strings, we don't want "", instead we want some funciton that turns an argument into a string.
# That's the job of enquo().
# enquo() uses some dark magic to look at the argrument, see what the user typed, and return that value as a quosure.
# (Technically, this works because function argument are evaluated lazily, using a special data structure called a promise.)
my_summarise <- function(df, group_var) {
  group_var <- enquo(group_var)
  print(group_var)
  
  df %>% 
    group_by(!! group_var) %>% 
    summarise(a = mean(a))
}

my_summarise(df, g1)

# (If you’re familiar with quote() and substitute() in base R, quo() is equivalent to quote() and enquo() is equivalent to substitute().)

# You might wonder how to extend this to handle multiple grouping variables: we’ll come back to that a little later.

# Different input variable 

# Now let's tackle something a bit ore complicated.
# The code below show a duplicate summarise() statement where we compute three summaries, varying the input variable.
summarise(df, mean = mean(a), sum = sum(a), n = n())

summarise(df, mean = mean(a * b), sum = sum(a * b), n = n())

# To turn this into a function, we start by testing the basic apporach interactively: we quote the variable with quo(), 
# then unquoting it in dplyr call with !!.
# Notice that we can unquote anywhere inside a complicated expression.
my_var <- quo(a)
summarise(df, mean =  mean(!! my_var), sum = sum(!! my_var), n = n())

# You can also wrap quo() around the dplyr call to see what happen from dplyrs' perspective.
# This is a very useful tool for debugging.
quo(summarise(df, 
  mean = mean(!! my_var),
  sum = sum(!! my_var),
  n = n()
))

# Now we can turn our cod into a function (remembering to replace quo() with enquo()), and check that it works:
my_summarise2 <- function(df, expr) {
  expr <- enquo(expr)
  print(expr)
  summarise(df, 
    mean = mean(!! expr),
    sum = sum(!! expr),
    n = n()
  )
}

my_summarise2(df, a)
my_summarise2(df, a * b)

# Different input and output varaible 
# The next challenge is to vary the name of the output variales:
mutate(df, mean_a = mean(a), sum_a = sum(a))
mutate(df, mean_b = mean(b), sum_b = sum(b))

# This code is similar to the previous exmaple, but there are two new wrinkles:
# 1. We create th new names by pasting together strings, so we need quo_name() to convert the input expression to a string.
# 2. !! mean_name = name(!! expr) isn't valid R code, so we need to use the := helper provided by rlang.
my_mutate <- function(df, expr) {
  expr <- enquo(expr)
  mean_name <- paste0("mean_", quo_name(expr))
  sum_name <- paste0("sum_", quo_name(expr))
  
  mutate(df, 
    !! mean_name := mean(!! expr),
    !! sum_name := sum(!! expr)
  )
}

my_mutate(df, a)

# Capturing multiple variables
# It would be nice to extend my_summarise() to accrpt any number fo grouping variables.
# We need to make three changes:
# 1. Use ... in the function definition so our funciton cam accept any number of argumnets.
# 2. Use enquos() to capture all the ... as a list of formulas.
my_summarise <- function(df, ...) {
  group_var <- enquos(...)

  df %>% 
    group_by(!!! group_var) %>% 
    summarise(a = mean(a))
}

my_summarise(df, g1, g2)

# !!! takes a list of elements and splices them into to the current call.
# Look at the bottom of the !!! and think ...
args <- list(na.rm = TRUE, trim = 0.25)
quo(mean(x, !!! args))

args <- list(quo(x), na.rm = TRUE, trim = 0.25)
quo(mean(!!! args))
# Now that you've learned the basics of tidyeval through some practical examples, we'll dive into the theory.
# This will help you generalise what you've learned here to new situations.

# Quoting 

# Quoting is the action of capturing an expression instead of evaluating it.
# All expression-based functions quote their arguments and get the R code as an expression rather than the result of evaluating that code.
# If you are an R user, you probably quote expressions on a regular basis.
# One of the most important quoting operators in R is the formula.
# It is famously used for the specification of statistical models:

disp ~ cyl + drat

# The other quoting operator in base R is quote(). It returns a raw expression rather than a formula:

# Computing the value of the expression:
toupper(letters[1:5])

# Capturing the expression:
quote(toupper(letters[1:5]))
# (Note that despite being called the double quote, " is not a quoting operator in this context, because it generates a string, not an expression.)

# In practice, the formula is the better of the two options because it captures th code and its execution envionment.
# This is important because even simple expression can yield different values in different environments. 
# For exmaple, the x in the following two expressions refers to different values:
f <- function(x) {
  quo(x)
}
x1 <- f(10)
x2 <- f(100)

# It might look like the expressions are the same if you print them out.
x1
x2

# But if you inspect the environment using rlang::get_env() - they're different.
library(rlang)
get_env(x1)
get_env(x2)

# Further, when we evaluate those formulas using rlang::eval_tidy(), we see that they yield different values:
eval_tidy(x1)
eval_tidy(x2)

# This is a key property of R: one name can refer to different values in different environments.
# This is also important for dplyr, because it allows you to combine variables and objects in a call:
user_var <- 1000
mtcars %>% summarise(cyl = mean(cyl) * user_var)

# When an object keeps track of an environment, it is said to have an ecclosure.
# This is the reason that functions in R are refered to as closures:
typeof(mean)

# For this reason we use a special name to refer to one-sided formulas: quosures.
# One-sided formulas are quoted(they carry an expression) with an environment.

# Quosures are regular R objects. They can be stored in a variable and inspected:
var <- ~toupper(letter[1:5])
var

# You can extract its expression:
get_expr(var)

# Or inspect its enclosure:
get_env(var)

# Quasiquotation
# Put simply, quasi-quotation enables one to introduce symbols that stand for a linguistic expression in a given instance and are used as that linguistic expression in a different instance. - Willard van Orman Quine

# Auto matic quoting makes dplyr very convenient for interactive use.
# But if you want to program with dplyr, you need some wayt o refer to variables indirectly.
# The solution to this problem is quasiquotation, which allows you to evaluate directly inside an expression that is otherwise quoted.

# Quasiquotation was coined by willard van Orman Quine in the 1940s, and was adopted for programming by the LISP community in the 1970s.
# All expression-based functions in the tidyeval framework support quasiquotation.
# Unquoting cancels quotation of parts of an expression.
# There are three types of unquoting:
# 1. basic
# 2. unquote splicing 
# 3. unquoting names

# Unquoting 
# The first important operation is the basic unquote, which comes in a functional form, UQ(), and as syntactic-sugar, !!.

# Here we capture `letter[1:5]` as an expression:
quo(toupper(letters[1:5]))

# Here we capture the value of `letters[1:5]`
quo(toupper(!! letters[1:5]))
quo(toupper(UQ(letters[1:5])))

# It is also possible to unquote other quoted expressions.
# Unquoting such symbolic objects provides a powerful way of manipulating expressions.
var1 <- quo(letters[1:5])
quo(toupper(!! var1))

# You can safely unquote quosures because they track their environments, and tidyeval functions know how to evaluate them.
# This allows any depth of quoting and unquoting.
my_mutate <- function(x) {
  mtcars %>% 
    select(cyl) %>% 
    slice(1:4) %>% 
    mutate(cyl2 = cyl + (!!x))
}

f <- function(x) quo(x)
expr1 <- f(100)
expr2 <- f(10)

my_mutate(expr1)
my_mutate(expr2)

# The functional form is useful in cases there the precedence of ! causes problems:
my_fun <- quo(fun)
quo(!! my_fun(x, y, z))
quo(UQ(my_fun)(x, y, z))

my_var <- quo(x)
quo(filter(df, !! my_var == 1))
quo(filter(df, UQ(my_var) == 1))

# Unquote-splicing 
# The second unquote operation is unquote-splicing.
# Its funcitonal form is UQS() and the syntactic shortcut is !!!.
# It takes a vector and inserts each elemnet of the vector in the surrounding funciton call:
quo(list(!!! letters[1:5]))

# A very useful feature of unquote-splicing is that the vector names become argument names:
x <- list(foo = 1L, bar = quo(baz))
quo(list(!!! x))

# This makes it easy to grogram with dplyr verbs that take named dots:
args <- list(mean = quo(mean(cyl)), count = quo(n()))
mtcars %>% 
  group_by(am) %>% 
  summarise(!!! args)

# Setting variable names 
# The final unquote operation is setting argument names.
# You've seen one way to do that above, but you cna also use the definition operator := instead of =.
# := supports unquoting on both the LHS and the RHS.

# The rules on the LHS are slightly different: the unquoted operand should evaluate to a string or a symbol.
mean_nm <- "mean"
count_nm <- "count"
mtcars %>% 
  group_by(am) %>% 
  summarise(
    !! paste0(mean_nm) := mean(cyl),
    !! count_nm := n()
  )
