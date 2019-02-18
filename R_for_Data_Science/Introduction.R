# This a note with the books with 'R for Data Science'
## Introduction

### A typical data science project flow
# Import data -> Tidy -> Understand{ Transform <-> Visualise <-> Model } -> Communicate


## The Tidyverse packages
if(!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)

## These packages provide data on airline flights, world development, 
## and baseball that we’ll use to illustrate key data science ideas.
if(!require(nycflights13)) install.packages('nycflights13')
if(!require(gapminder)) install.packages('gapminder')
if(!require(Lahman)) install.packages('Lahman')
library(nycflights13)
library(gapminder)
library(Lahman)

