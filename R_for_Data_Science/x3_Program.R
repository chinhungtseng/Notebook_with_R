# Program

# 17 Introduction
# In this part of the book, you'll improve your programming skills. 
# Programming is a cross-cutting skill needed for all data science work:
# you must use a computer to do data science; you cannot do it in your head, or with pencil and paper.

# Prgrammint produces code, and code is a tool of communication. Obviously code tells the computer what you want it to do.
# But it also communicates meaning to other humans.
# Thinking about code as a vehical for communication is important because every project you do is fundamentally collaborative.
# Even if you're working with other people, you'll definitely be working with future-you!
# Writing clear code is important so that others(lik future-you) can understand why you tackled an analysis in the way you did.
# That means getting better at programming also involves getting better at communicating. 
# Over time, you want your code to become not just easier to write, but easier for others to read.

# Writing code is similar in many ways to writing prose. One parallel which I find particularly usefrl is that in both cases rewriting is the key to clarity.
# The first expression of your ideas is unlikely to be particularly clear, and you need to rewrite multiple times.
# After solving a data analysis challenge, it's often worth looking at your code and while the ideas are fresh, you can save a lot of time later trying to recreate what your code did.
# But this doesn't mean you should rewrite every function: you need to balance what you need to achieve now with saving time in the long run.
# (But the more you rewrite your funcitons the more likely your first attempt will be clear.)

# In the following four chapters, you'll learn skills that will allow you to both tackle new programs and to solve existing problems with greater clarity and ease:
# 1. IN pipes, you will dive deep into the pipe, %>%, and learn about how it works, what the alternatives are, and when not to use it.
# 2. Copy-and-paste is a powerful tool, but you should avoid doing it more than twice.
#    Repeating yourself in code is dangerous because it can easily lead to errors and inconsistencies. Instead, in functions, 
#    you'll learn how to write functions which let you extract out repeated code so that it can be easily reused.
# 3. As yuo start to write more powerful functions, you'll need a solid grounding in R's data structures, provided by vectors.
#    You must master the four common atomic vectors, the three important S3 classes built on top of them, and understand the mysteries of the list and data frame.
# 4. Functions extract out repeated code, but you often need to repeat the same actions on different inputs.
#    You need tools for iteration that let you do similar things again and again. 
#    These tools include for loops and functional programming, which you'll learn about in iteration.

# 17.1 Learning more
# The goal of these chapters is to teach you the minimum about programming that you need to practice data science, 
# which turns out to be a reasonable amount. Once you have mastered the material in this book, 
# I strongly believe you should invest further in your programming skills.
# Learning more about programming is a believe you should investment: it won't pay off immediately,
# but in the long term it will allow you to solve new problems more quickly, and let you reuse your insights from previous problems in new scenarios.

# To learn more you need to study R as a programming language, not just an interactive environment for data science. We have written two books that will help you do so:
# 1. Hands on Programming with R, by Garrett Grolemund. This is an introduction to R as a programming language and is a great place to start if R is your first programming language.
#    It covers similar material to these chapters, but with a different style and different motivation examples (based in the casino). 
#    It’s a useful complement if you find that these four chapters go by too quickly.

# 2. Advanced R by Hadley Wickham. This dives into the details of R the programming language. 
#    This is a great place to start if you have existing programming experience.
#    It’s also a great next step once you’ve internalised the ideas in these chapters. 
#    You can read it online at http://adv-r.had.co.nz.

# ----------------------------------------------------------------------------------------------------------------------------
# 18 Pipes

# 18.1 Introduction
# Pipes are a powerful tool for clearly expressing a sequence of multiple operations.
# So far, you've been using them without knowing how they work, or what the alternatives are.
# Now, in this chapter, it's time to explore the pipe in more detail. 
# You'll learn the alternatives to the pipe, then you shouldn't use the pipe, and some useful related tools.

# 18.1.1 Prerequisites
# The pipe, %>%, comes from the magrittr package by Stefan Milton Bache. Packages in the tidyverse load %>%  for you automatically, 
# so you don't usually load magrittr explicitly.
library(magrittr)

# 18.2 Piping alternatives
# The point fo the pipe is to help you write code in a way that is easier to read and understand.
# To see why the pipe is so useful, we're going to explore a number of ways of writing the same code.
# Let's use code to tell a story about a little bunny named Foo Foo:

# Little bunny Foo Foo
# Went hopping through the forest
# Scooping up field mice
# And bopping them on the head

# This a popular Children's poem that is accompanied by hand actions.
# We'll start by defining an object to represent little bunny Foo Foo:
foo_foo <- little_bunny()

# And we'll use a function for each key verb: hop(), scoop(), and bop(). 
# Using this object and these verbs, there are (at least) four ways we could retell the story in code:
# 1. Save each intermediate step as a new object.
# 2. Overwrite the original object many times.
# 3. Compose functions.
# 4. Use the pipe.
# We'll work through each approach, showing you the code and talking about the advantages and disadvantages.

# 18.2.1 Intermediate steps
# The simplest approach is to save each step as a new object:
foo_foo_1 <- hop(foo_foo, through = forest)
foo_foo_2 <- scoop(foo_foo_1, up = field_mice)
foo_foo_3 <- bop(foo_foo_2, on = head)

# The main downside of this form is that it forces you to name each intermediate element.
# If there are natural names, this is a good idea, and you should do it. 
# But many times, like this in this example, there aren't natural anmes, and you add numeric suffixes to make the names unique.
# That leads to two problems:
# 1. The code is cluttered with unimportant names
# 2. You have to carefully increment the suffix on each line.

# Whenever I write code like this, I invariably use the wrong number on one line and then spend 10 minutes
# scratching my head and trying to figure out what went wrong with my code.

# You may also worry that this form creates many copies of your data and takes up a lot of memory.
# Surprisingly, that's not the case. First, note that proactively worrying about memory is not a useful way to spend your time:
# worry about it when it becomes a problem (i.e. you run out of memory), not before.
# Second, R isn't stupid, and it will share columns across data frames, where possible.
# Let's take a look at an actual data manipulation pipeline where we add a new column to ggplot2::diamonds:
diamonds <- ggplot2::diamonds
diamonds2 <- diamonds %>% 
  dplyr::mutate(price_per_carat = price / carat)

pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2)

# pryr::object_size() gives the memory occupied by all of its arguments.
# The results seem counterintuitive at first:
# 1. diamonds takes up 3.46 MB,
# 2. diamonds2 takes up 3.89 MB,
# 3. diamonds and diamonds2 together take up 3.89 MB!

# How can that work? Well, diamonds2 has 10 columns in common with diamonds: there's no need to duplicate all that data, 
# so the two data frames have variables in common. These variables will only get copied if you modify one of them. 
# In the following example, we modify a single value in diamonds$carat. That means the carat variable can no longer be shared between the two data frames, 
# and a copy must by made. The size of each data frame is unchanged, but the collective size increases:
diamonds$carat[1] <- NA
pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2)
# (Note that we use pryr:object_size() here, not the built-in object.size(). object.size() only takes a single object 
# so it can't compute how data is shared across multiple objects.)

# 18.2.2 Overwrite the original 

# Instead fo creating intermediate objects at each step, we could overwrite the original object:
foo_foo <- hop(foo_foo, through = forest)
foo_foo <- scoop(foo_foo, up = field_mice)
foo_foo <- bop(foo_foo, on = head)

# This is less typing (and less thinking), so you're less likely to make mistakes. However, there are two problems:
# 1. Debugging is painful: if you make a mistake you'll need to re-run the complete pipeline from the begining.
# 2. The repetition of the object being transformed(we've written foo_foo six times!) obsures what's changing on each line.

# 18.2.3 Function composition

# Another approach is to abandon assignment and just string the function calls together:
bop(
  scoop(
    hop(foo_foo, through = forest),
    up = field_mice
  ),
  on = head
)

# Here the disadvantage is that you have to read from inside-out, from right-to-left, and that the arguments end up spread far apart
# (evocatively called the dagwood sandwhich problem(https://en.wikipedia.org/wiki/Dagwood_sandwich)). In short, this code is hard for a human to consume.

# 18.2.4 Use the pipe

# Finally, we can use the pipe:
foo_foo %>% 
  hop(through = forest) %>% 
  scoop(up = field_mice) %>% 
  bop(on = head)

# This is my favourite form, because it focusses on verbs, not nouns. You can read this series of function compositions like it's a set of imperative actions.
# Foo Foo hops, then scoops, then bops. The downside, of course, is that you need to be familiar with the pipe. 
# If you've never seen %>% before, you'll have no idea what this code does. Fortunately, most people pick up the idea very quickly, 
# so when you share your code with others who aren't familiar with th pipe, you can easily teach them.

# The pipe works by performing a "lexial transformation": behind the scenes, magrittr reassembles the code in the pipe to a from that works by overwriting an intermediate object.
# When you run a pipe like the one above, magrittr does somethin like this:
my_pipe <- function(.) {
  . <- hop(., through = forest)
  . <- scoop(., up = field_mice)
  bop(., on = head)
}
my_pipe(foo_foo)

# This means that the pipe won't work for two classes of functions:
# 1. Functions that use the current environment. For example, assign() will create a new variabel with the given name in the current environment:
assign("x", 10)
x

"x" %>% assign(100)
x

#    The use of assign with the pipe does not work because it assigns it to a temporary environment used by %>% .
#    If you do want to use assign with the pipe, you must be explicit about the environment:
env <- environment()
"x" %>% assign(100, envir = env)

#    Other functions with this problem include get() and load().

# 2. Functions that use lazy evaluation. In R, function arguments are only computed when the function uses them, not prior to calling the function.
#    The pipe computes each element in turn, so you can't rely on this behaviour.

#    One place that this is a problem is tryCatch(), which lets you capture and handle errors:
tryCatch(stop("!"), error = function(e) "An error")

stop("!") %>% 
  tryCatch(error = function(e) "An error")

#    There are a relatively wide class of functions with this behaviour, including try(), suppressMessages(), and suppressWarnings() in base R.

# 18.3 When not to use the pipe

# The pipe is a powerful tool, but it's not the only tool at your disposal, and it doesn't solve every problem!
# Pipe are most useful for rewriting a fairly short linear sequence of operations.
# I think you should reach for another tool when:
# 1. Your pipes are longer than (say) ten steps. In the case, create intermediate objects with meaningful names.
#    That will make debuggin easier, because you can more easily check the intermediate results, and it makes it easier to understand your code, 
#    because the variable names can help communicate intent.
# 2. You have multiple inputs or outputs. If there isn't one primary object being transformed, 
#    but two or more objects being combined together, don't use the pipe.
# 3. You are strating to think about a directed graph with a complex dependency structure. 
#    Pipes are fundamentally linear and expressing complex relationships with them will typically yield confusion code.

# 18.4 Other tools from magrittr

# All packages in the tidyverse automatically make %>% available for you, so you don't normally load magrittr explicitly.
# However, there are some other useful tools inside magrittr that you might want to try out:
# 1. (Tee operator) When working with more complex pipes, it's cometimes useful to call a function for its side-effects.
#    Maybe you want to print out the current object, or plot it, or save it to disk.
#    Many times, such functions don't rerurn anything, effectively terminating the pipe.

#    To work around this problem, you can use the "tee" pipe. %T>% works like %>% except that it returns the left-hand side instead of the right-hand side.
#    It's called "tee" because it's like a literal T-shaped pipe.
rnorm(100) %>% 
  matrix(ncol = 2) %>% 
  plot() %>% 
  str()

rnorm(100) %>% 
  matrix(ncol = 2) %T>% 
  plot() %>% 
  str()

# 2. (Exposition operator) If you're working with functions that don't have a data frame based API
#    (i.e. you pass them individual vectors, not a data frame and expressions to be evaluated in the context of that data frame),
#    you might find %$% useful. It "explodes" out the varuables in a data frame so that you can refer to them explicitly.
#    This is useful when working with many functions in base R:
mtcars %$% 
  cor(disp, mpg)

cor(mtcars$disp, mtcars$mpg)

# 3. (Compound assignment operator) For assignment magrittr provides the %<>% operatr which allows you to replace code like:
mtcars <- mtcars %>% 
  transform(cyl = cyl * 2)
# with
mtcars %<>% transfrom(cyl = cyl * 2) 

# I'm not a fan of this operator because I think assignment is such a special operation that it should always be clear when it's occurring.
# In my opinion, a little bit of duplication(i.e. repeating the name of the object twice) is fine in return for making assignment more explicit.

# ----------------------------------------------------------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------------------------------------------------------
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
# (as opposed to NA wh ich is used to represent the absence of a value in a vector).
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

# 20.3.4 Exercises

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
.Machine$integer.max










# 4. Brainstorm at least four functions that allow you to convert a double to an integer.
#    How do they differ? Be precise.



# 5. What functions from the readr package allow you to turn a string into logical, integer, and double vector?






# ----------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------