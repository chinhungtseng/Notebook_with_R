# 8 Workflow: projects
# To handle these real life situations, you need to make two decisions:
## What about your analysis is “real”, i.e. what will you save as your lasting record of what happened?
## Where does your analysis “live”?

# 8.1 What is real?
## As a beginning R user, it’s OK to consider your environment 
## (i.e. the objects listed in the environment pane) “real”. 
## However, in the long run, you’ll be much better off if you consider your R scripts as “real”.

## There is a great pair of keyboard shortcuts that will work together to 
## make sure you’ve captured the important parts of your code in the editor:

# Press Cmd/Ctrl + Shift + F10 to restart RStudio.
# Press Cmd/Ctrl + Shift + S to rerun the current script.

# 8.2 Where does your analysis live?
getwd()

# 8.3 Paths and directories

# 8.4 RStudio projects

# 8.5 Summary
# In summary, RStudio projects give you a solid workflow that will serve you well in the future:

# 1. Create an RStudio project for each data analysis project.
# 2. Keep data files there; we’ll talk about loading them into R in data import.
# 3. Keep scripts there; edit them, run them in bits or as a whole.
# 4. Save your outputs (plots and cleaned data) there.
# 5. Only ever use relative paths, not absolute paths.

# Everything you need is in one place, and cleanly separated from all the other projects that you are working on.
