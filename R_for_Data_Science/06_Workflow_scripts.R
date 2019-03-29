# 6 Workflow: scripts
# 6.1 Running code
library(dpyr)
library(nycflights13)

not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

# 6.2 RStudio diagnostics
## The script editor will also highlight syntax errors with a red squiggly line 
## and a cross in the sidebar

# 6.3 Practice
## Go to the RStudio Tips twitter account, https://twitter.com/rstudiotips 
## and find one tip that looks interesting. Practice using it!

## What other common mistakes will RStudio diagnostics report? 
## Read https://support.rstudio.com/hc/en-us/articles/205753617-Code-Diagnostics to find out.