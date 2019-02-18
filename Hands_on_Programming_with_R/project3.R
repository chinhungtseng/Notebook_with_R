# Exercise 
# BOOKS: Hands-on Programming with R

# 9 Programs
options(scipen = 999)

get_symbols <- function() {
  wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
  sample(wheel, size = 3, replace = TRUE, 
         prob = c(0.03, 0.03, 0.06, 0.1, 0.25, 0.01, 0.52))
}

score <- function(symbols) {
  
  diamonds <- sum(symbols == "DD")
  cherries <- sum(symbols == "C")
  
  # identify case
  # since diamonds are wild, only nondiamonds 
  # matter for three of a kind and all bars
  slots <- symbols[symbols != "DD"]
  same <- length(unique(slots)) == 1
  bars <- slots %in% c("B", "BB", "BBB")
  
  # assign prize
  if (diamonds == 3) {
    prize <- 100
  } else if (same) {
    payouts <- c("7" = 80, "BBB" = 40, "BB" = 25,
                 "B" = 10, "C" = 10, "0" = 0)
    prize <- unname(payouts[slots[1]])
  } else if (all(bars)) {
    prize <- 5
  } else if (cherries > 0) {
    # diamonds count as cherries
    # so long as there is one real cherry
    prize <- c(0, 2, 5)[cherries + diamonds + 1]
  } else {
    prize <- 0
  }
  # double for each diamond
  prize * 2^diamonds
}

play <- function() {
  symbols <- get_symbols()
  structure(score(symbols), symbols = symbols, class = "slots")
}


slot_display <- function(prize){
  
  # extract symbols
  symbols <- attr(prize, "symbols")
  
  # collapse symbols into single string
  symbols <- paste(symbols, collapse = " ")
  
  # combine symbol with prize as a character string
  # \n is special escape sequence for a new line (i.e. return or enter)
  string <- paste(symbols, prize, sep = "\n$")
  
  # display character string in console without quotes
  cat(string)
}

slot_display(one_play)

print.slots <- function(x, ...) {
  slot_display(x)
}


wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
combos <- expand.grid(wheel, wheel, wheel, stringsAsFactors = FALSE)
prob <- c("DD" = 0.03, "7" = 0.03, "BBB" = 0.06, 
          "BB" = 0.1, "B" = 0.25, "C" = 0.01, "0" = 0.52)
combos$prob1 <- prob[combos$Var1]
combos$prob2 <- prob[combos$Var2]
combos$prob3 <- prob[combos$Var3]
combos$prob <- combos$prob1 * combos$prob2 * combos$prob3

head(combos, 3)
symbols <- c(combos[1, 1], combos[1, 2], combos[1, 3])

combos$prize <- NA

for (i in 1:nrow(combos)) {
  symbols <- c(combos[i, 1], combos[i, 2], combos[i, 3])
  combos$prize[i] <- score(symbols)
}
head(combos, 3)

sum(combos$prize * combos$prob)









# 12 Speed 
## About how to write a fastest code that using 
## logical tests, subsetting, and element-wise execution

## Vectorized Code
### For loop
abs_loop <- function(vec) {
  for (i in 1:length(vec)) {
    if (vec[i] < 0) {
      vec[i] <- vec[i]
    }
  }
  vec
}

### vectorized code
abs_sets <- function(vec) {
  negs <- vec < 0
  vec[negs] <- vec[negs] * -1
  vec
}

### Create a sample
long <- rep(c(-1, 1), 5000000)

#### Compare this two function and measure the run time
system.time(abs_loop(long))
system.time(abs_sets(long))
system.time(abs(long))

## How to write vetorized code
# 1. Use vectorized functions to complete the sequential steps in your program.
# 2. Use logical subsetting to handle parallel cases
#    Try to manipulate every element in a case at once.

# Exercise 12.2 (Vectorize a Function)
# Convert this code to a new vectorized code
change_symbols <- function(vec){
  for (i in 1:length(vec)){
    if (vec[i] == "DD") {
      vec[i] <- "joker"
    } else if (vec[i] == "C") {
      vec[i] <- "ace"
    } else if (vec[i] == "7") {
      vec[i] <- "king"
    }else if (vec[i] == "B") {
      vec[i] <- "queen"
    } else if (vec[i] == "BB") {
      vec[i] <- "jack"
    } else if (vec[i] == "BBB") {
      vec[i] <- "ten"
    } else {
      vec[i] <- "nine"
    } 
  }
  vec
}

vec <- c("DD", "C", "7", "B", "BB", "BBB", "0")
change_symbols(vec)
many <- rep(vec, 1000000)
system.time(change_symbols(many))

# Solution 1
change_vec <- function (vec) {
  vec[vec == "DD"] <- "joker"
  vec[vec == "C"] <- "ace"
  vec[vec == "7"] <- "king"
  vec[vec == "B"] <- "queen"
  vec[vec == "BB"] <- "jack"
  vec[vec == "BBB"] <- "ten"
  vec[vec == "0"] <- "nine"
  
  vec
}

system.time(change_vec(many))

# Solution 2
change_vec2 <- function(vec) {
  tb <- c("DD" = "joker", "C" = "ace", "7" = "king", "B" = "queen", 
          "BB" = "jack", "BBB" = "ten", "0" = "nine")
  unname(tb[vec])
}

system.time(change_vec2(many))

# Another way to measure the process's run time.
start_time <- Sys.time() # Set a start time
test <- change_symbols(many) 
end_time <- Sys.time() # Set a end time 
end_time - start_time # subtract the start and end time

## 12.3 How to Write Fast for Loops in R
# 1. Do as much as you can outside of the for loop.
# 2. Make sure that any storage objects that you use with the loop 
#    are large enough to contain all of the results of the loop.

system.time({
  output <- rep(NA, 10000000)
  for (i in 1:10000000) {
    output[i] <- i + 1
  }
})

system.time({
  output <- NA 
  for (i in 1:10000000) {
    output[i] <- i + 1
  }
})

## 12.4 Vectorized Code in Practice

winnings <- vector(length = 1000000)

system.time(for(i in 1:1000000) {
  winnings[i] <- play()
})
mean(winnings)

get_many_symbols <- function(n) {
  wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
  vec <- sample(wheel, size = 3*n, replace = TRUE, 
                prob = c(.03, .03, .06, .01, .25, .01, .52))
  matrix(vec, ncol = 3)
}

play_many <- function(n) {
  symb_mat <- get_many_symbols(n = n)
  data.frame(w1 = symb_mat[, 1], w2 = symb_mat[, 2], 
             w3 = symb_mat[, 3], prize = score_many(symb_mat))
}

# create a sample for testing
symbols <- matrix(
  c("DD", "DD", "DD", 
    "C", "DD", "0", 
    "B", "B", "B", 
    "B", "BB", "BBB", 
    "C", "C", "0", 
    "7", "DD", "DD"), nrow = 6, byrow = TRUE)

# symbols should be a matrix with a column for each slot machine window
score_many <- function(symbols) {
  
  # Step 1: Assign base prize based on cherries and diamonds ---------
  ## Count the number of cherries and diamonds in each combination
  cherries <- rowSums(symbols == 'C')
  diamonds <- rowSums(symbols == 'DD')
  
  ## wild diamonds count as cherries
  prize <- c(0, 2, 5)[cherries + diamonds + 1]
  
  ## ...but not if there are zero real cherries
  ### (cherries is coerced to FALSE where cherries = 0)
  prize[!cherries] <- 0
  
  # Step 2: Change prize for combinations that contain three of a kind 
  same <- symbols[, 1] == symbols[, 2] & 
    symbols[, 2] == symbols[, 3]
  payoff <- c('DD' = 100, '7' = 80, 'BBB' = 40,
              'BB' = 25, 'B' = 10, 'C' = 10, '0' = 0)
  prize[same] <- payoff[symbols[same, 1]]
  
  # Step 3: Change prize for combinations that contain all bars ------
  bars <- symbols == 'B' | symbols == 'BB' | symbols == 'BBB'
  all_bars <- bars[, 1] & bars[, 2] & bars[, 3] & !same
  prize[all_bars] <- 5
  
  # Step 4: Handle wilds ---------------------------------------------
  
  ## combos with two diamonds
  two_wilds <- diamonds == 2
  
  ### Identify the nonwild symbol
  one <- two_wilds & symbols[, 1] != symbols[, 2] &
    symbols[, 2] == symbols[, 3]
  two <- two_wilds & symbols[, 1] != symbols[, 2] &
    symbols[, 1] == symbols[, 3]
  three <- two_wilds & symbols[, 1] == symbols[, 2] &
    symbols[, 2] != symbols[, 3]
  
  ### Treat as three of a kind
  prize[one] <- payoff[symbols[one, 1]]
  prize[two] <- payoff[symbols[two, 2]]
  prize[three] <- payoff[symbols[three, 3]]
  
  ## combos with one wild
  one_wild <- diamonds == 1
  
  ### Treat as all bars (if appropriate)
  wild_bars <- one_wild & (rowSums(bars) == 2)
  prize[wild_bars] <- 5
  
  ### Treat as three of a kind (if appropriate)
  one <- one_wild & symbols[, 1] == symbols[, 2]
  two <- one_wild & symbols[, 2] == symbols[, 3]
  three <- one_wild & symbols[, 3] == symbols[, 1]
  prize[one] <- payoff[symbols[one, 1]]
  prize[two] <- payoff[symbols[two, 1]]
  prize[three] <- payoff[symbols[three, 1]]
  
  # Step 5: Double prize for every diamond in combo ------------------
  unname(prize * 2^diamonds)
}

system.time(play_many(10000000))







