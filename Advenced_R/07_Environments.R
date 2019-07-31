set.seed(1014)

# 7 Envionments

# 7.1 Introduction

# The envionment is the data structure that powers scoping.
# This chapter dives deep into envionments, describing their structure in depth, 
# and usign them to imporve your understainding of the foru scoping rules described in Section 6.4.
# Understanding envionments is not necessary for day-to-day use of R.
# But they are important to unerstand because they power many important R features like lexical scoping,
# namespaces, and R6 classes, and interact with evaluation to give you powerful tools for making domain specific languages, like dplyr and ggplot2.

# Quiz

# If you can answer the following questions correctly, you already know the most important topics in this chapter.
# You can find the answers at the end of the chapter in Section 7.7.

# 1. List at least three ways that an envionment differs from a list.

# There are four ways: 

# (1) ever object in an environment must have a name;
# (2) order doesn't matter;
# (3) environments have parents;
# (4) environments have reference semantics.

# 2. What is the parent of the global envionment? What is the only envionments that doesn't have a parnet?

# The parent of the global environment is the last package that you loaded.
# The only environment that doesn't have a parent is the empty environment.

# 3. What is the enclosing envionment of a function? Why is it important?

# The enclosing environment of a function is the environment where it was created.
# It determines where a function looks for variables.

# 4. How do you determine the envionment from which a function was called?

# Use `caller_env()` or `parent.frame()`.

# 5. How are `<-` and `<<-` different?

# `<-` always creates a binding in the current environment;
# `<<-` rebinds an existing name in a parent of the current environment, 

# Outline 

# - Section 7.2 introduces you to the basic properites of an envionment and shows you how to create your own.

# - Section 7.3 provides a function template form computing with envionments, ullustrating the idea with a useful function.

# - Section 7.4 describes envionments used for special purposes: for packages, within functions ,for namespaces, and for function execution.

# - Section 7.5 ecplains the last important envionment: the caller envionment.
#   This requires you to learn about the call stack, that describes how a functoin was called.
#   You'll have seen the call stack if you've ever called `traceback()` to aid debugging.

# - Section 7.6 briefly discusses three places where envionments are useful data structures for solving other problems.

# Prerequisites

# This chapter will use rlang functions for working with envionments, because it allows us to focus on the essence of envionments, rather than the incidental details.
library(rlang)

# The `env_` functions in rlang are designed to work with th pipe: all take an envionment as the first argument, and many also return an envionment.
# I won't use the pipe in this chapter in the interest of keeping the code as simple as possible, 
# but you should consider it for your own code.

# 7.2 Environment basics

# Generally, an environment is similar to a named list, with four important exceptions:

# - Every name must be unique.
# - The names in an environment are not ordered.
# - An environment has a parent.
# - Environment are not copied when modified.

# Let's ecplore these idea with code and pictures.

# 7.2.1 Basics

# To create an environment, use `rlang::env()`.
# It works like `list()`, taking a set of name-value pairs:
e1 <- env(
  a = FALSE,
  b = "a",
  c = 2.3,
  d = 1:3
)

####### In base R #######
# Use `new.env()` to create a new environment. Ignore the `hash` and `size` parameters; they are not needed.
# You cannot simultaneously create and difine values; use `$<-`, as shown below.
#########################

# The job of an environment is to associate, or __bind__, a set of names to a set of values.
# You can think of an environment as a bag of names, with no implied order(i.e. it doesn't make sense to ask which is the first element in an environment).
# For that reason, we'll draw the environment as so:

# As discussed in Section 2.5.2, environments have reference semantics: unlike most R objects, when you modify them, you modify them in place, and don't create a copy.
# One important implication is that environments can contain themselves.
e1$d <- e1

# Printing an environment just displays its memory address, which is not terribly useful:
e1
#> <environment: 0x109aed9e0>

# Instead, we'll use `env_print()` which gives us a little more information:
env_print(e1)
#> <environment: 0x109aed9e0>
#>   parent: <environment: global>
#>   bindings:
#>   * a: <lgl>
#>   * b: <chr>
#>   * c: <dbl>
#>   * d: <env>

# You can use `env_names()` to get a character vector giving the current bindings 
env_names(e1)
#> [1] "a" "b" "c" "d"

####### In base R #######
# In R 3.2.0 and greater, use `names()` to list the bindings in an environment.
# If your code needs to work with R 3.1.0 or earlier, use ls(), 
# but note that you'll need to set `all.names = TRUE` to show all bindings.
#########################

# 7.2.2 Important environments

# We'll talk in deatil about special environment in 7.4., but for now we need to mention two.
# The current environmetn, or `current_env()` is the environment in which code is currently executing.
# When you're experimenting interactively, that's ususally eht global envionment, or `global_env()`.
# The global environment is sometimes called your "workspace", as it's where all interactive(i.e. outside of a function) computation takes place.

# To compare environments, you need to use `idnetical()` and not `==`. 
# This is because `==` is a vectorised operator, and environments are not vectors.
identical(global_env(), current_env())
#> [1] TRUE

global_env() == current_env()
#> Error in global_env() == current_env() : 
#>   comparison (1) is possible only for atomic and list types

####### In base R #######
# Access the global environment with `globalenv()` and the current environment with `environment()`.
# The global environment is printed as `Rf_GlobalEnv` and `.GlobalEnv`.
#########################

# 7.2.3 Parents 

# Every environment has a __parnet__, another environment.
# In diagrams, the parent is shown as a small pale blue circle an darrow that points to another environment.
# The parnet is what's used to implement lexical scoping: if a name is not found in an environment, then R will look in its parent (and so on).
# You can set the parent environment by supplying an unnamed argument ot `env()`.
# If you don't supply it, it defaults to the currnet environment. 
# In the code below, `e2a` is the parent of `e2b`.
e2a <- env(d = 4, e = 5)
e2b <- env(e2a, a = 1, b = 2, c = 3)

# To save space, I typically won't draw all the ancestors; just remember whenever you see a pale blue circle, 
# there's a parnet environment somewhere.

# You can find the parent of an environment with `env_parent()`:
env_parent(e2b)
#> <environment: 0x10375bdf0>
env_parent(e2a)
#> <environment: R_GlobalEnv>

# Only one environment doesn't have a parent: the __empty__ environment.
# I draw the empty environment with a hollow parent environment, and where space allows I'll label it with `R_EmptyEnv`, the name R uses.
e2c <- env(empty_env(), d = 4, e = 5)
e2d <- env(e2c, a = 1, b = 2, c = 3)

# The ancestors of every environment eventually terminate with the empty environment.
# You can see all ancestors with `env_parents()`:
env_parents(e2b)
#> [[1]]   <env: 0x10375bdf0>
#> [[2]] $ <env: global>
env_parents(e2d)
#> [[1]]   <env: 0x10b7e8a88>
#> [[2]] $ <env: empty>

# By default, `env_parents()` stops when it gets to the global environment.
# This is usefulu because the ancestors of the global environment in clude every attached package, 
# which you can seee if you override the default behaviour as below.
# We'll come back to these envorinments in Section 7.4.1.
env_parents(e2b, last = empty_env())
#> [[1]]   <env: 0x10375bdf0>
#> [[2]] $ <env: global>
#> [[3]] $ <env: package:rlang>
#> [[4]] $ <env: tools:rstudio>
#> [[5]] $ <env: package:stats>
#> [[6]] $ <env: package:graphics>
#> [[7]] $ <env: package:grDevices>
#> [[8]] $ <env: package:utils>
#> [[9]] $ <env: package:datasets>
#> [[10]] $ <env: package:methods>
#> [[11]] $ <env: Autoloads>
#> [[12]] $ <env: package:base>
#> [[13]] $ <env: empty>

####### In base R #######
# Use `parent.env()` to find the parent of an environment.
# No base function returns all ancestors.
########################

# 7.2.4 Super assignment, <<-

# The ancestors of environment have an important relationship to `<<-`.
# Regular assignment, `<-`, always creates a variable in the current environment.
# Super assignment, `<<-`, never creates a variable in the current environment, 
# but instead modifies an existing variable found in a parent environment.
x <- 0
f <- function() {
  x <<- 1
}
f()
x
#> [1] 1

# If `<<-` doesn't find an existing variable, it will create one in the global environment.
# This is usually undesirable, because global variables introduce non-obvious dependencies between functions.
# `<<-` is most often used in conjunctoin with a function factory, as described in Section 10.2.4.

# 7.2.5 Getting and setting 

# You can get and set elements of an environment with `$` and `[[` in the same way as a list:
e3 <- env(x = 1, y = 2)
e3$x
#> [1] 1
e3$z <- 3
e3[["z"]]
#> [1] 3

# But you can't use `[[` with numeric indices, and you can't use `[`:
e3[[1]]
#> Error in e3[[1]] : wrong arguments for subsetting an environment
e3[c("x", "y")]
#> Error in e3[c("x", "y")] : object of type 'environment' is not subsettable

# `$` and `[[` will return `NULL` if the binding doesn't exist.
# Use `env_get()` if you want an error:
e3$xyz
#> NULL
env_get(e3, "xyz")
#> Error in env_get(e3, "xyz") : object 'xyz' not found

# If you want to use a default value if the binding doesn't exist,, you can use the `default` argument.
env_get(e3, "xyz", default = NA)
#> [1] NA

# There are two other ways to add bindings to an environment:

# - `env_poke()` takes a name (as strign) and a value:
env_poke(e3, "a", 100)
e3$a
#> [1] 100

# - `env_bind()` allows you to bind multiple values:
env_bind(e3, a = 10, b = 20)
env_names(e3)
#> [1] "x" "y" "z" "a" "b"

# You can determine if an environment has a binding with `env_has()`:
env_has(e3, "a")
#>    a
#> TRUE

# Unlike lists, setting an element to `NULL` does not remove it, because sometimes you want a name that refers to `NULL`.
# Instead, use `env_unbind()`:
e3$a <- NULL
env_has(e3, "a")
#>    a
#> TRUE

env_unbind(e3, "a")
env_has(e3, "a")
#>     a
#> FALSE

# Unbinding a name doesn't delete the object.
# That's the job of the garbage collector, which automatically removes objects with no names binding to them.
# This process is described in more in Section 2.6.

####### In base R #######
# See `get()`, `assign()`, `exists()`, and `rm()`.
# These are designed interactively for use with the current environment, to working with other environments is a little clunky.
# Also beware the `inherits` argument: it defaults to `TRUE` meaning that the base equivalents will inspect the supplied environment and all its ancestrs.
########################

# 7.2.6 Advanced bindings

# There are two more exotic variants of `env_bind()`:

# - `env_bind_lazy()` creates __delayed bindings__, which are evaluated the first time they are accessed.
#    Behind the scenes, delayed bindings cteate promies, so behave in the same way as function arguments.
env_bind_lazy(current_env(), b = {Sys.sleep(1); 1})

system.time(print(b))
#> [1] 1
#>   user  system elapsed 
#>  0.013   0.006   1.002 
system.time(print(b))
#> [1] 1
#>   user  system elapsed 
#>      0       0       0

#   The primary use of delayed bindings is in `autoload()`, which allows R packages to provide datasets that behave lik ethey are loaded in memory, 
#   even though they're only loaded from disk when needed.

# - `env_bind_active()` creates __active bindings__ which are re-computed every time they're accessed:
env_bind_active(current_env(), z1 = function(val) runif(1))
z1
#> [1] 0.08075014
z1
#> [1] 0.6007609

#   Active bindings are used to implement R6's active fields, which you'll learn about in Section 14.3.2.

####### In base R #######
# See `?delayedAssign()` and `?makeActiveBinding()`.
#########################

# 7.2.7 Exercises

# 1. List three way in which an environment differs from a list.

# - Every name must be unique.
# - The name in an environment are not ordered.
# - An environment has a parent.
# - Environments are not copied when modified.

# 2. Create an environment as illustrated by this picture.
e1 <- env()
e1$loop <- e1

# 3. Create a pair of environments as illustrated by this picture.
e1 <- env()
e2 <- env()
e1$loop <- e2
e2$dedoop <- e1

# 4. Explain why `e[[1]]` and `e[c("a", "b")]` don't make sense when `e` is an environment.

# The first option doesn't make sense, because elements of an environment are not ordered.
# The second option would return two objects at the same time.
# What data structure would they be contained inside?

# 5. Create a version of `env_poke()` that will only bind new names, never re-bind old names.
#    Some programming languages only do this, and are known as single assignment languages.

# We want `env_poke2()` to test, if the supplied name is already present in the given environment.
# We only allow new names to be assigned to a value, otherwise an (informative) error is thrown.
env_poke2 <- function(env, name, value) {
  if (env_has(env, name)) {
    abort(paste0("\"", name, "\" is already assigned to a value."))
  }
  
  env_poke(env, name, value)
  invisible(env)
}

# Test 
env_1 <- env(a = 1)
env_poke2(env_1, "b", 2)
env_names(env_1)
#> [1] "a" "b"
env_poke2(env_1, "b", 2)
#>  Error: "b" is already assigned to a value.

env_poke2 <- function(env, nm, value) {
  if (env_has(env, nm)) {
    stop("Can't re-bind old names")
  } else {
    env_poke(env, nm, value)
  }
}

# 6. What does this function do? How does it differ from `<<-` and why might you prefer it?
rebind <- function(name, value, env = caller_env()) {
  if (identical(env, empty_env())) {
    stop("Can't find `", name, "`", call. = FALSE)
  } else if (env_has(env, name)) {
    env_poke(env, name, value)
  } else {
    rebind(name, value, env_parent(env))
  }
}
rebind("a", 10)  
#>  Error: Can't find `a` 
a <- 5
rebind("a", 10)
a
#> [1] 10

# The primary difference between `rebind()` and `<<-` is that `rebind()` will only carry out an assignment when it finds an existing binding;
# unlike `<<-` it will never create a new one in the blobal environment.
# This is usually undersirable, because global variables introduce non-obvous dependencies between functions.

# 7.3 Recursing over environments

# If you want to operate on every ancestor of an environment, it's often convenient to write a recursive function.
# This section shows you how, applying your new knowledge of environment to write a function that given a name, 
# finds the environment `where()` that name is defined, using R's regular scoping rules.

# The definition of `where()` is straightforward. It ahs two arguments: the name to look for (as a string),
# and the environment in which to start the search.
# (We'll learn why `caller_env()` is a good default in Section 7.5.)
where <- function(name, env = caller_env()) {
  if (identical(env, empty_env())) {
    # Base case
    stop("Can't find ", name, call. = FALSE)
  } else if (env_has(env, name)) {
    # Success case
    env
  } else {
    # Recursive case
    where(name, env_parent(env))
  }
}

# There are three cases:

# - The base case: we've reached the empty environment and haven't found the binding.
#   We can't go any further, so we throw an error.
# - The successful case: the name exists in this environment, so we return the environment.
# - The recursive case: the name was not found in this environment, so try the parent.

# These three cases are illustrated with these three examples:
where("yyy")
#>  Error: Can't find yyy 

x <- 5
where("x")
#> <environment: R_GlobalEnv>

where("mean")
#> <environment: base>

# It might help to see a picture. Imagine you have two environments, as in the following code and diagram:
e4a <- env(empty_env(), a = 1, b = 2)
e4b <- env(e4a, x = 10, a = 11)

# - `where("a", e4b)` will find `a` in `e4b`.
# - `where("b", e4b)` doesn't find `b` in `e4b`, so it looks in its parent, `e4a`, and finds it there.
# - `where("c", e4b)` looks in `e4b`, then `e4a`, then hits the empty environment and throws an error.

# It's natural to work with environments recursively, so `where()` provides a useful template.
# Removing the specifics of `where()` shows the structure more clearly:
f <- function(..., env = caller_env()) {
  if (identical(env, empty_env())) {
    # base case
  } else if (success) {
    # success case
  } else {
    # recursive case
    f(..., env = env_parent(env))
  }
}

####### Iteration versus recursion #######
# It's possible to use a loop instead of recursion. I think it's harder to understand than the recursive version, 
# but I include it because you might find it easier to see what's happening if you haven't written many recursive functions.
f2 <- function(..., env = caller_env()) {
  while(!identical(env, empty_env())) {
    if (success) {
      # success case
      return()
    }
    # inspect parent
    env <- env_parent(env)
  }
  # base case
}
##########################################

# 7.3.1 Exercises

# 1. Modify `where()` to return all environments that contain a binding for `name`.
#    Carefully think through what type of object the function will ennd to return.



where <- function(name, env = caller_env()) {
  if (identical(env, empty_env())) {
    stop("Can't find ", name, call. = FALSE)
  } else if (env_has(env, name)) {
    env
  } else {
    where(name, env_parent(env))
  }
}

where2 <- function(name, env = caller_env(), results = list()) {
  if (identical(env, empty_env())) {
    results
  } else {
    if (env_has(env, name)) {
      results <- c(results, env)
    } 
    where2(name, env_parent(env), results)
  }
}

# Test
e1a <- env(empty_env(), a = 1, b = 2)
e1b <- env(e1a, b = 10, c = 11)
e1c <- env(e1b, a = 12, d = 13)

where2("a", e1c)

# 2. Write a function called `fget()` that finds only function objects.
#    It should have two arguments, `name` and `env`, and should obey the regular scoping rules for functions:
#    if there's an object with a matching name that's not a function, look in the parent.
#    For an added challenge, also add an `inderits` argument which controls whether the function recurses up the parents or only looks in one environment.

# We follow a similar approach to the previous exercise.
# This time we additionally check if the found object is a function and implement and argument to turn off the recursion, if desired.

fget <- function(name, env = caller_env(), inherits = TRUE) {
  # Base case
  if (env_has(env, name)) {
    obj <- env_get(env, name)
    
    if (is.function(obj)) {
      return(obj)
    }
  }
  
  if (identical(env, empty_env()) || !inherits) {
    stop("Could not find function called \"", name, "\"", call. = FALSE)
  }
  
  # Recursive Case
  fget(name, env_parent(env))
}

# Test 
mean <- 10
fget("mean", inherits = TRUE)

# 7.4 Special environments

# Most environment are not created by you (e.g. with `env()`) but are instead created by R.
# In this section, you'll learn about the most important enviornments, starting with the package environments.
# You'll then learn about the function environment bound to the function when it is created, and the (usually) ephemeral execution environment created every time the function is called.
# finally, you'll see how the package and function environments interact to support namespaces, which ensure that a package always behaves the same way, 
# regardless of what other packages the user has loaded.

# 7.4.1 Pakcage environments and the search path

# Each package attached by `library()` or `require()` becomes one of the parents of the blobal environment.
# The immediate parent of the global environment is the last package you attached, 
# the parent of that package is the second to last package you attached.

# If you follow all the parent back, you see the order in which every package has been attached.
# This is known as the __search path__ because all objects in these environments can be found from the top-lovel interactive workspace.
# You can see the names of these environments with `base::search()`, or the environments themselfes with `rlang::search_envs()`:
search()
#> [1] ".GlobalEnv"        "package:rlang"     "tools:rstudio"     "package:stats"    
#> [5] "package:graphics"  "package:grDevices" "package:utils"     "package:datasets" 
#> [9] "package:methods"   "Autoloads"         "package:base" 

search_envs()
#>  [[1]] $ <env: global>
#>  [[2]] $ <env: package:rlang>
#>  [[3]] $ <env: tools:rstudio>
#>  [[4]] $ <env: package:stats>
#>  [[5]] $ <env: package:graphics>
#>  [[6]] $ <env: package:grDevices>
#>  [[7]] $ <env: package:utils>
#>  [[8]] $ <env: package:datasets>
#>  [[9]] $ <env: package:methods>
#> [[10]] $ <env: Autoloads>
#> [[11]] $ <env: package:base>

# The last two environment on the search path are always the same:

# - The `Autoloads` environment uses delayed bindings to save memory by only loading package objects (like big datasets) when needed.
# - The base environment, `package:base` or sometimes just `base`, is the environment of the base package.
#   It is special because it has to be able to bootstrap the th eloading of all other packages.
#   You can access it directly with `base_env()`.

# Note that when you attach another package with `library()`, the parent environment of the global environment changes:

# 7.4.2 The function environment 

# A function binds the current environment when it is created.
# This is called the __function environment__, and is used for lexical scoping.
# Across computer languages, functions that capture (or enclose) their environments are called __closures__,
# which is why this term is often used interchangeably with function in R'l documentation.

# You can get the function environment with `fn_env()`:
y <- 1
f <- function(x) x + y
fn_env(f)
#> <environment: R_GlobalEnv>

####### In base R #######
# use `environment(f)` to access the environment of function `f`.
########################

# In diagrams, I'll draw a function as a rectangle with a rounded end that binds an environment.

# In this case, `f()` binds the environment that binds the name `f` to the function.
# But that's not always the case: in the following example `g` is bound in a new environment `e`, but `g()` binds the global environment.
# The distinction between binding and being bound by is subtle but important;
# the different is how we find `g` versus how `g` finds its variables.
e <- env()
e$g <- function() 1

# 7.4.3 Namespaces

# In the diagram above, you saw that the parent environment of a package varies based on that other packages have been loaded.
# This seems worrying: doesn't that mean that the package will find different functions if packages are loaded in a different order? 
# The goal of __namespaces__ is to make sure that this does not happen,
# and that every package works the same way regardless of what packages are attached by the user.

# For example, take `sd()`:
sd
#> function (x, na.rm = FALSE) 
#>   sqrt(var(if (is.vector(x) || is.factor(x)) x else as.double(x), 
#>            na.rm = na.rm))
#> <bytecode: 0x10e027b28>
#>   <environment: namespace:stats>

# `sd()` is defined in terms of `var()`, so you might worry that the result of `sd()` would be affected by any function called `var()` either in the global environment, or in one of the other attached packages.
# R avoids this problem by taking advantage of the function versus binding environment described above.
# Every function in a package is associated with a pair of environments: the package environment, which you learned about earlier and the __namespace__ environment.

# - The package environment is the external interface to the package.
#   It's how you, the R user, find a function in an attached package or with `::`.
#   It's parent is determined by search path, i.e. the order in which packages have been attached.

# - The namespace environment is the internal interface to the package.
#   The package environment controls how we find the function; the namespace controls how the function finds its variables.

# Every binding in the package environment is also found in the namespace environment;
# this ensures every function can use every other function in the package.
# But some bindings only occur in the namespace environment.
# These are known as internal or non-exported objects, which make it possible to hide internal implementation details from the user.

# Every namespace environment has the same set of ancestors:

# - Each namespace has an __imports__ environment that contains bindings to all the functions used by the package.
#   The imports environment is controlled by the package developer with `NAMESPACE` file.

# - Explicitly importing every base function would be tiresome, so the parent of the imports environment is the base __namespace__.
#   The base namespace contains the same bindings as the base environment, but it has a different parent.

# - The parnet of the base namespace is the global enviroment.
#   This means that if a binding isn't defined in the imports environment the package will look for it in the usual way.
#   This is usually a bad idea(because it makes code depend on other loaded packages),
#   so `R CMD check` automatically warns about such code.
#   It is needed primarily for historical reasons, particularly due to how S3 method dispatch works.

# Putting all these diagrams together we get:

# So when `sd()` looks for the value of `var` it always finds it in a sequence of environments determined by the package developer, but not by the package user.
# This ensures that apckage code always works the same way regardless of what packages have been attached by the user.

# There's no direct link between the package and namespace environments;
# the link is defined by the function environment.

# 7.4.4 Execution environments

# The last important topic we need to cover is the __execution__ environment.
# What will the following function return the first time it's run?
# What about the second?
g <- function(x) {
  if (!env_has(current_env(), "a")) {
    message("Defining a")
    a <- 1
  } else {
    a <- a + 1
  }
  a
}

# Think about it for a moment before you read on.
g(10)
#> Defining a
#> [1] 1
g(10)
#> Defining a
#> [1] 1

# This function returns the same value every time because of the fresh start principle, described in Section 6.4.3.
# Each time a functino is called, a new environment is created to host execution.
# This is called the execution environent, and its parent is the function environment.
# Let's illustrate that process with a simpler function.
# Figure 7.1 illustrates the graphical conventions: I draw execution environments with an indirect parent;
# the parent environment is found via the function environment.
h <- function(x) {
              # 1. Function called with x = 1
  a <- 2      # 2. a bound to value 2
  x + a
}

y <- h(1)     # 3. Function completes returning value 3. Execution environment goes away.

# An execution environment is usually ephemeral;
# once the function has completed, the environment will be garbage collected.
# There are several ways to make it stay around for longer.
# The first is to explicitly return it:
h2 <- function(x) {
  a <- x * 2
  current_env()
}

e <- h2(x = 10)
env_print(e)
#> <environment: 0x113830300>
#>   parent: <environment: global>
#>   bindings:
#>   * a: <dbl>
#>   * x: <dbl>
fn_env(h2)
#> <environment: R_GlobalEnv>

# Another way to capture it is to return an object with a binding to that environment, like a function.
# The following example illustrates that idea with a function factory, `plus()`.
# We use that factory to create a function called `plus_one()`.

# There's a lot going on in the diagram because the enclosing environment of `plus_one()` is the execution environment of `plus()`.
plus <- function(x) {
  function(y) x + y
}

plus_one <- plus(1)
plus_one
#> function(y) x + y
#> <bytecode: 0x10f3744b8>
#> <environment: 0x10e963158>

# What happens when we call `plus_one()`?
# Its execution environment will have the captured execution environment of `plus()` as its parent:
plus_one(2)
#> [1] 3

# You'll learn more about function factories in Section 10.2.

# 7.4.5 Exercises

# 1. How is `search_envs()` different from `env_parents(global_env())`?

# `search_envs()` returns all the environments on the search path.
# "The search path is a chain of environments containing exported functions is attached packages" (from `?search_envs`).
# Every time you attach a new package, this search path will grow.
# The search path ends with the base-environment.
# The global environment is included, because functions present in the global environment will always be part of the search path.
search_envs()
#>  [[1]] $ <env: global>
#>  [[2]] $ <env: package:rlang>
#>  [[3]] $ <env: tools:rstudio>
#>  [[4]] $ <env: package:stats>
#>  [[5]] $ <env: package:graphics>
#>  [[6]] $ <env: package:grDevices>
#>  [[7]] $ <env: package:utils>
#>  [[8]] $ <env: package:datasets>
#>  [[9]] $ <env: package:methods>
#> [[10]] $ <env: Autoloads>
#> [[11]] $ <env: package:base>

# `env_parents(global_env())` will list all the ancestors of the global environment, 
# therefore the global environment itself is not included.
# This also incluedes the "ultimate ancestor", the empty environment.
# This environment is not considered part of the search path because it contains no ogjects.

# 2. Draw a diagram that shows the enclosing environemnts of this function:
f1 <- function(x1) {
  f2 <- function(x2) {
    f3 <- function(x3) {
      x1 + x2 + x3
    }
    f3(3)
  }
  f2(2)
}
f1(1)

# 3. Write an enhanced version of `str()` that proivdes more information about functions.
#    Show where the function was found and what environment it was defined in.

# To solve this problem, we need to write a function that takes the name of a function and look for that function returning both the function and the environment that it was found in.
fget2 <- function(name, env = caller_env()) {
  # base case
  if (env_has(env, name)) {
    obj <- env_get(env, name)
    if (is.function(obj)) {
      return(list(fun = obj, env = env))
    }
  }
  
  if (identical(env, empty_env())) {
    stop("Could not find function called \"", name, "\"", call. = FALSE)
  } 
  # recurisive case
  fget2(name, env_parent(env))
}

fstr <- function(fun_name, env = caller_env()) {
  if (!is.character(fun_name) && length(fun_name) == 1) {
    stop("`fun_name` must be a string", call. = FALSE)
  }
  fun_env <- fget2(fun_name, env)
  
  list(
    where = fun_env$env,
    enclosing = fn_env(fun_env$fun)
  )
}

# Once you have learned about tidyeval, you could rewrite `fstr()` to use `enquo()` so that you'd call it like more like `str()`, i.e. `fstr(sum)`.

# 7.4 The call stack

# There is one last environment we need to explain, the __caller__ environment, accessed with `rlang::caller_env()`.
# This provides the environment from which the function was called, and hence varies based on how the function is called, not how the function was created.
# As we saw above this is a useful default whenever you write a function that takes an environment as an argument.

####### In base R #######
# `parent.frame()` is equivalent to `caller_env()`; just note that it returns an environment, not a frame.
#########################

# To fully understand the caller environment we need to discuss two related concepts: the __call stack__, which is make up of __frames__.
# Excuting a function creates two types of context.
# You've learned about one already: the execution environment is a child of the function environment, 
# which is determined by where the function was created.
# There's another type of context created by where the function was called: this is called the call stack.

# 7.5.1 Simple call stacks

# Let's illustrate this with a simple sequence of calls: `f()` calls `g()` calls `h()`.
f <- function(x) {
  g(x = 2)
}
g <- function(x) {
  h(x = 3)
}
h <- function(x) {
  stop()
}

# The way you most commonly seea call stack in R is by looking at the `traceback()` after an error has occurred:
f(x = 1)
#>  Error in h(x = 3) :
traceback()
#> 4: stop()
#> 3: h(x = 3) 
#> 2: g(x = 2)
#> 1: f(x = 1)

# Instead of `stop()` + `traceback()` to understand the call stack, we're going to use `lobstr::cst()` to print out the call stack tree:
h <- function(x) {
  lobstr::cst()
}
f(x = 1)
#> █
#> └─f(x = 1)
#>   └─g(x = 2)
#>     └─h(x = 3)
#>       └─lobstr::cst()

# This shows us that `cst()` was called form `h()`, which was called form `g()`, which was called from `f()`.
# Note that the order is the opposite from `traceback()`.
# As the call stacks get more complicated, I think it's easier to understand teh seqence of calls if you start from the begining, rather than the end (i.e.`f()` calls `g()`; rather than `g()` was called by `f()`).

# 7.5.2 Lazy evaluation

# The call stack above is simple: while you get a hint that there's some tree-like sturcture involved, everything happens on a single branch.
# This is typical of a call stack when all argument are eagerly evaluated.

# Let's create a more complicated example that involves some lazy evaluation.
# We'll create a sequence of functions, `a()`, `b()`, `c()`, that pass along an argument `x`.
a <- function(x) b(x)
b <- function(x) c(x) 
c <- function(x) x

a(f())
#> █
#> ├─a(f())
#> │ └─b(x)
#> │   └─c(x)
#> └─f()
#>   └─g(x = 2)
#>     └─h(x = 3)
#>       └─lobstr::cst()

# `x` is laily evaluated so this tree gets two branches.
# In the first branch `a()` calls `b()`, then `b()` calls `c()`.
# The second branch starts when `c()` evaluates its argument `x`.
# This argument is evaluated in a new branch because the rnvironment in which it is evaluated is the global environment,
# not the environment of `c()`.

# 7.5.3 Frames 

# Each element of the call stack is a __frame__, also known as an evaluation context.
# The frae is an extremely important internal data structure, and R code can only access a small part of the ata structure because tampering with it will break R.
# A frame has threee key components:

# - An expression (labelled with `expr`) giveing the function call.
#   This is what `traceback()` prints out.

# - An environment (labelled with `evn`), which is typically the execution environment of a function.
#   There are two main exceptions: the environment of the global frame is the global environment, 
#   and calling `eval()` also generates frames, where the environment can be anything.

# - A parent, the previous call in the call stack (shown by a grey arrow).

# Figure 7.2 illustrate the stack for the call to `f(x = 1)` shown in Section 7.5.1.

# (To focus on the calling environemnts, I have ommited the bindings in the goabal environment from `f`, `g`, and `g` to the respective function objects.)

# The frame also holds exit handlers created with `on.exit()`, restarts and handlers for the condition system, 
# and which context to `return()` to when a function completes.
# These are important internal details that are not accessible with R code.

# 7.5.4 Dynamic scope

# Looking up variables in the calling stack rather than in the enclosing environment is called __dynamic scoping__.
# Few laguages impliment dynamic scoping (Emacs Lisp is a notable exception.)
# This is because dynamic scoping makes it much harder to reastion about how a function operates: not only do you know how it was defined, 
# you also need to know the context in which it was called.
# Dynamic scoping is primarily useful for developing functions that aid interactive data analysis, and one of the topic discussed in Cahpter 20.

# 7.5.5 Exercises

# 1. Write a function that lists all the variables defined in the environment in which it was called.
#    It should return the same results as `ls()`.

# We can implement this dynamic scoping behaviour, by explicitly referencing the caller environment.
# Please not, that this approach returns also variables starting with a dot, an option that `ls()` usually require.

ls2 <- function(env = caller_env()) {
  env_names(env)
}
ls2()

ls(all.names = TRUE)
#>  [1] ".Random.seed" "a"            "b"            "c"            "f"            "f1"          
#> [7] "fget2"        "fstr"         "g"            "h"            "ls2"          "objs" 

ls2()
#> [1] "fget2"        "a"            "objs"         "b"            "c"            ".Random.seed"
#> [7] "f"            "ls2"          "g"            "h"            "fstr"         "f1" 

# Test in "sandbox" environment 
e1 <- env(a = 1, b = 2)
invoke(ls, .env = e1)
#> [1] "a" "b"
invoke(ls2, .env = e1)
#> [1] "a" "b"

# 7.6 As data structures

# As well as powering scoping, environments are also useful data structures in their own right because they have reference semantics.
# There are three common problems that they can help solve:

# - Avoiding copies of large data. Since environments have reference semantics, you'll never accidentally create a copy.
#   But bare environments are painful to work with, wo instad I recommend using R6 objects, 
#   which are built on top of environments. Learn more in Chapter 14.

# - Managing state within a package. Explicit environments are useful in packages because they allow you to maintain state across function calls.
#   Normally, objects in a package are locked, so you can't modify them directly.
#   Instead, you can do something like this:
my_env <- new.env(parent = emptyenv())
my_env$a <- 1

get_a <- function() {
  my_env$a
}
set_a <- function(value) {
  old <- my_env$a
  my_env$a <- value
  invisible(old)
}
# Returning the old value from setter functions is a good pattern because it makes it easier to reset the previous value in conjunction with `on.exit()`(Section 6.7.4).

# - AS a hashmap. A hashmap is a data stuctrure that takes constant, O(1), time to find an object based on its name.
#   Environments provide this behaviour by default, so can used to simulate a hashmap.
#   See the hash package (Brown 2013) for a complete development of this idea.

# References

# Brown, Christopher. 2013. Hash: Full Feature Implementation of Hash/Associated Arrays/Dictionaries.
# https//CRAN.R-project.org/package=hash.