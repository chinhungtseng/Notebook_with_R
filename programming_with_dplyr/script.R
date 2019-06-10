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







