# Communicate

# 26 Introduction

# So far, you've learned the tools to get your data into R, tidy it into a from convenient for analysis, 
# and then understand your data through transfromation, visualisation and modelling.
# Howevery, it doesn't matter how great your analysis is unless you can explain it ot others: you need to comunicate your results.

#  /-----------------------------------------------------------------\
#  |                                                                 |
#  |                   /---------------------------\                 |
#  |                   |         --> Visualise --> |                 |
#  |                   |        |               |  |                 |
#  | Import --> Tidy --|--> Transform           |  |--> Communicate  |
#  |                   |        |               |  |                 |
#  |                   |        <---  Model <---   |                 |
#  |                   \---------------------------/                 |
#  |                   Understand                                    |
#  \-----------------------------------------------------------------/
#  Program

# Communication is the theme of the following four chapters:
# 1. In R Markdown, you will learn about R Markdown, a tool for integrating prose, code, and results.
#    You can use R Markdown in notebook mode for analyst-to-analyst communicatio, and in report mode for analyst-to-decision-maker communication.
#    Thanks to the power of R Markdown formats, you can even use the same document for both purposes.
# 2. In graphics for communication, you will learn how to take your exploratory graphics and turn them into expositor graphics,
#    graphics that help the newcomer to your analysis understand what's going on as quickly and easily as possibel.
# 3. In R Markdown formats, you'll learn a little about the many other vauieties of outputs you can produce using R Markdown, 
#    inluding dashboards, websites, and books.
# 4. We'll finish up with R Markdown workflow, where you'll learn about the "analysis notebook" 
#    and how to systematically recoud your successes and failures so that you can learn from them.

# Unfortunately, these chapters focus mostly on the technical mechanics of communication, 
# not the really hard problems of communicating your thoughts to other humans.
# However, there are lot of other great books about communication, which we'll point you to at the end of each chapter.

# ----------------------------------------------------------------------------------------------------------------------------

# 27 R Markdown

# 27.1 Introduction

# R Markdown provides an unified authoring framework for data science, combining your code, its results, and your prose commentray.
# R Markdown documents are fully reproducible and support dozens of output formats, like PDFs, Word files, slideshows, and more.

# R Markdown files are designed to be used in three ways:
# 1. For communicating to decision makers, who want to focus on the conclusions, not the code behind the analysis.
# 2. For collaborating with other data scientists (including future you!), who are interested in both your conclusions, 
#    and how you reached them (i.e. the code).
# 3. As an environment in which to do data science, as a modern day lab notebook where you can capture not only what you did, 
#    but also what you were thinking.

# R Markdown integrates a number of R packages and external tools. This means that help is, by-and-large, not available through ?.
# Instead, as you work through this chapter, and use R Markdown in the future, keep these resource close to hand:
# 1. R Markdown Cheat Sheet: Help > Cheatsheets > R Markdown Cheat Sheet,
# 2. R Markdown Reference Guide: Help > Cheatssheets > R Markdown Reference Guide.

# Both cheatsheets are also available at http://rstudio.com/cheatsheets.

# 27.1.1 Prerequisites

# You need the rmarkdown package, but you don't need to explicitly installl it or load it, as RStudio automatically does both when needed.

# 27.2 R Markdown basics

# This is an R Markdown file, a plain text file that has the extension .Rmd:
# |---------------------------------------------------------------|
# |                                                               |
# |  ---                                                          |
# |  title: "Diamond sizes"                                       |
# |  date: 2016-08-25                                             |
# |  output: html_document                                        |
# |  ---                                                          |
# |                                                               |
# |  ```{r setup, include = FALSE}                                |
# |  library(ggplot2)                                             |
# |  library(dplyr)                                               |
# |                                                               |
# |  smaller <- diamonds %>%                                      |
# |  filter(carat <= 2.5)                                         |
# |  ```                                                          |
# |                                                               |
# |  We have data about `r nrow(diamonds)` diamonds. Only         |
# |  `r nrow(diamonds) - nrow(smaller)` are larger than           |
# |  2.5 carats. The distribution of the remainder is shown       |
# |  below:                                                       |
# |                                                               |
# |  ```{r, echo = FALSE}                                         |
# |  smaller %>%                                                  |
# |  ggplot(aes(carat)) +                                         |
# |  geom_freqpoly(binwidth = 0.01)                               |
# |  ```                                                          |
# |---------------------------------------------------------------|

# It contains therr important types of content:
# 1. An (optional) YAML heaker surrounded by --- s.
# 2. Chunks of R code surrounded by ```.
# 3. Text mixed with simple text formatting like # heading and _italics_.

# When you open an .Rmd, you get a notebook interface where code and output are interleaved.
# You can run each code chunk by clicking the Run icon (it looks like a play button at the top of the chunk), 
# or by pressing Cmd/Ctrl + Shift + Enter. RStudio executes the code and displays the results inline with the code:

# |--------------------------------------------------------------------------------------------------------------------------------------|
# | O O O                                    ~/Documents/Project/Notebook_with_R - master - RStudio                                      |    
# |--------------------------------------------------------------------------------------------------------------------------------------|
# | H H H H H H Addins v                                                                                                 Notebook_with_R |
# |--------------------------------------------------------------------------------------------------------------------------------------|
# |xxxxx.Rmd |                                                                                                                           |
# |----------|---------------------------------------------------------------------------------------------------------------------------|
# | 1 library(tidyverse)                                               | Files | Plots | Packages | Help | Viewer|                       |
# | 2                                                                  |-----------------------------------------------------------------|
# | 3 library(modelr)                                                  |                                                               O |
# | 4 options(na.action = na.warn)                                     |                                                                 |
# | 5                                                                  |                                                                 |
# | 6 ggplot(sim1, aes(x, y)) +                                        |                                                                 |
# | 7   geom_point()                                                   |                                                                 |
# | 8                                                                  |                                                                 |
# | 9                                                                  |                                                                 |
# |10                                                                  |                                                                 |
# |11                                                                  |                                                                 |
# | |------------------------------------------------------------------|                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                         graphic                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# | |                                                                  |                                                                 |
# |--------------------------------------------------------------------------------------------------------------------------------------|

# To produce a complete report containing all text, code, and results, click “Knit” or press Cmd/Ctrl + Shift + K. 
# You can also do this programmatically with rmarkdown::render("1-example.Rmd"). 
# This will display the report in the viewer pane, and create a self-contained HTML file that you can share with others.

# When you knit the document, R Markdown sends the .Rmd file to knitr, http://yihui.name/knitr/,
# which executes all of the code chunks and creates a new markdown (.md) document which includes the code and its output. 
# The markdown file generated by knitr is then processed by pandoc, http://pandoc.org/, which is responsible for creating the finished file. 
# The advantage of this two step workflow is that you can create a very wide range of output formats, as you’ll learn about in R markdown formats.

#  |-------|                     |-------|                               |-------|
#  |       |      |-------|      |       |        |--------|        |------|     |
#  |  Rmd  |  =>  | knitr |  =>  |  md   |   =>   | pandoc |   =>   |      |     |----|
#  |       |      |-------|      |       |        |--------|        |      |     |    |
#  |-------|                     |-------|                          |      |-----|    |
#                                                                   |------|   |      | 
#                                                                              |------|

# To get started with your own .Rmd file, select File > New File > R Markdown… in the menubar. 
# RStudio will launch a wizard that you can use to pre-populate your file with useful content 
# that reminds you how the key features of R Markdown work.

# The following sections dive into the three components of an R Markdown document in more details: 
# the markdown text, the code chunks, and the YAML header.

# 27.2.1 Exercises

# 1. Create a new notebook using File > New File > R Notebook. Read the instructions. 
#    Practice running the chunks. 
#    Verify that you can modify the code, re-run it, and see modified output.

## DONE

# 2. Create a new R Markdown document with File > New File > R Markdown… Knit it by clicking the appropriate button. 
#    Knit it by using the appropriate keyboard short cut. Verify that you can modify the input and see the output update.

## DONE

# 3. Compare and contrast the R notebook and R markdown files you created above. 
#    How are the outputs similar? 
#    How are they different? How are the inputs similar? How are they different? 
#    What happens if you copy the YAML header from one to the other?
  
## (1) https://stackoverflow.com/questions/43820483/difference-between-r-markdown-and-r-notebook/43898504#43898504
## (2) http://uc-r.github.io/r_notebook

# 4. Create one new R Markdown document for each of the three built-in formats: HTML, PDF and Word. 
#    Knit each of the three documents. How does the output differ? 
#    How does the input differ? 
#    (You may need to install LaTeX in order to build the PDF output — RStudio will prompt you if this is 

# 27.3 Text formatting with Markdown

# Prose in .Rmd files is writen in Markdown, a lightweight set of conventions for formatting plain text files.
# Markdown is designed to be easy to easy to write. It is also very easy to learn.
# The guide below shows how to use Pandoc's Markdown, a slightly extended version of Markdown that R Markdown understands.

# |------------------------------------------------------------------------------------|
# |                                                                                    |
# | Text formatting                                                                    |
# | ------------------------------------------------------------                       |
# |                                                                                    |
# |  *italic*  or _italic_                                                             |
# |  **bold**   __bold__                                                               |
# |  `code`                                                                            |
# |  superscript^2^ and subscript~2~                                                   |
# |                                                                                    |
# |  Headings                                                                          |
# |  ------------------------------------------------------------                      |
# |                                                                                    |
# |  # 1st Level Header                                                                |
# |                                                                                    |
# |  ## 2nd Level Header                                                               |
# |                                                                                    |
# |  ### 3rd Level Header                                                              |
# |                                                                                    |
# |  Lists                                                                             |
# |  ------------------------------------------------------------                      |
# |                                                                                    |
# |  *   Bulleted list item 1                                                          |
# |                                                                                    |
# |  *   Item 2                                                                        |
# |                                                                                    |
# |     * Item 2a                                                                      |
# |                                                                                    |
# |     * Item 2b                                                                      |
# |                                                                                    |
# |  1.  Numbered list item 1                                                          |
# |                                                                                    |
# |  1.  Item 2. The numbers are incremented automatically in the output.              |
# |                                                                                    |
# |  Links and images                                                                  |
# |  ------------------------------------------------------------                      |
# |                                                                                    |
# |  <http://example.com>                                                              |
# |                                                                                    |
# |  [linked phrase](http://example.com)                                               |
# |                                                                                    |
# |  ![optional caption text](path/to/img.png)                                         |
# |                                                                                    |
# |  Tables                                                                            |
# |  ------------------------------------------------------------                      |
# |                                                                                    |
# |  First Header  | Second Header                                                     |
# |  ------------- | -------------                                                     |
# |  Content Cell  | Content Cell                                                      |
# |  Content Cell  | Content Cell                                                      |
# |                                                                                    |
# |                                                                                    |
# |------------------------------------------------------------------------------------|

# The best way to learn these is simply to try them out. It will take a few days, 
# but soon they will become second nature, and you won’t need to think about them. 
# If you forget, you can get to a handy reference sheet with Help > Markdown Quick Reference.

# 27.3.1 Exercises

# 1. Practice what you've learned by creating a brief CV. 
#    The title should be your name, and you should include headings for (at least) education or employment.
#    Each of the secitons should include a bulleted of jobs/degrees. Highlight the year in bold.

## Done

# 2. Using the R Markdown quick reference, figure out how to:
#    (1) Add a footnote.
#    (2) Add a horizontal rule.
#    (3) Add a block quote.

## Done

# 3. Copy and paste the contents of diamond-sizes.Rmd from https://github.com/hadley/r4ds/tree/master/rmarkdown in to a local R markdown document.
#    Check that you can run it, then add text after the frequency polygon that describes its most striking features.



# 27.4 Code chunks

# To run code inside an R Markdown document, you need to insert a chunk.
# There are three ways to do so:
# 1. The keyboard shortcut Cmd/Ctrl + Alt + I
# 2. The "Insert" button icon in the editor toolbar.
# 3. By manually typing the chunk delimiters ```{r} and ```.

# Obvously, I'd recommend you learn the keyboard shortcut. It will save you a lot of time in the long run!

# You can continue to run the code using the keyboard shortcut that by now (I hope!) you know and love: Cmd/Ctrl + Enter.
# However, chunks get a new keyboard shortcut: Cmd/Ctrl + Shift + Enter, which runs all the code  in the chunk.
# Think of a chunk like a function. A chunk should be relatively self-contained, and focussed around a single task.

# The following sections describe the chunk header which consists of 
# ```{r, followed by an optional chunk name, followed by comma separated options, followed by}.
# Next comes your R code and the chunk end is indicated by a final ```.

# 27.4.1 Chunk name

# Chunks can be given an optional name: ``` { r by-name}. This has three advantages:
# 1. You can more easily navigate to specific chunks using the drop-down code navigator in the bottom-left of the script editor:
# 2. Graphics producted by the chunks will have useful names that make them easier to use elsewhere.
#    More on that in other important options. (https://r4ds.had.co.nz/graphics-for-communication.html#other-important-options)
# 3. You can set up networks of cached chunks to avoid re-performing expensive computations on every run. More on that below.

# There is one chunk name that imbues special behaviour: setup. 
# When you're in a notebook mode, the chunk names setup will be run automatically once, before any other code is run.

# 27.4.2 Chunk options

# Chunk output can be customised with options, arguments supplied to chunk header. 
# Knitr provides almost 60 options that you can use to customize your code chunks.
# Here we'll cover the most important chunk options that you'll ues frequently.
# You can see the full list at http://yihui.name/knitr/options/.

# The most important set of options controls if your code block is executed and what results are inserted in the finished report:
# 1. eval = FALSE      prevent code from being evaluated. (And obviously if the code is not run, no results will be generated).
#                      This is useful for displaying example code, or for disabling a large block of code without commenting each line.
# 2. include = FALSE   runs the code, but doesn't show the code or results in the final document.
#                      Use this for setup code that you don't want cluttering your report.
# 3. echo = FALSE      prevents code, but not the result from appearing in the finished file.
#                      Use this when writing reports aimed at people who don't want cluttering your report.
# 4. message = FALSE   or warning = FALSE prevents messages or warnings from appearing in the finished file.
# 5. results = 'hide'  hides printed output; fig.show = 'hide' hides plots.
# 6. error = TRUE      cause the render to continue even if code returns an error. 
#                      This is rarely something you;ll want ot include in the final version of your report, 
#                      but can be very useful if you need to debug exactly what is going on inside your .Rmd.
#                      It's also useful if you're teaching R and want to dliberately include an error.
#                      The default, error = FALSE causes knitting to fail if there is a single error in the document.

# The following table summarises which types of output each option supressess:
# |-------------------|----------|-----------|--------|-------|----------|----------|
# | Option            | Run code | Show code | Output | Plots | Messages | Warnings |
# |-------------------|----------|-----------|--------|-------|----------|----------|
# | eval = FALSE      |    v     |           |    v   |   v   |     v    |     v    |
# |                   |          |           |        |       |          |          |
# | include = FALSE   |          |     v     |    v   |   v   |     v    |     v    |
# |                   |          |           |        |       |          |          |
# | echo = FALSE      |          |     v     |        |       |          |          |
# |                   |          |           |        |       |          |          |
# | results = "hide"  |          |           |    v   |       |          |          | 
# |                   |          |           |        |       |          |          |
# | fig.show = "hide" |          |           |        |   v   |          |          |
# |                   |          |           |        |       |          |          |
# | message = FALSE   |          |           |        |       |     v    |          |
# |                   |          |           |        |       |          |          |
# | warning = FALSE   |          |           |        |       |          |    v     |
# |-------------------|----------|-----------|--------|-------|----------|----------|

# 27.4.3 Table

# By defualt, R Markdown prints data frames and matrices as you'd see them in the console:
mtcars[1:5, ]

# If you prefer that data be displayed with additional formatting you can use the knitr::kable function.
# The code below generates Table 27.1.

knitr::kable(
  mtcars[1:5, ],
  caption = "A knitr kable."
)

#                                 Table 27.1: A knitr kable.
#  |                  |  mpg| cyl| disp|  hp| drat|    wt|  qsec| vs| am| gear| carb|
#  |:-----------------|----:|---:|----:|---:|----:|-----:|-----:|--:|--:|----:|----:|
#  |Mazda RX4         | 21.0|   6|  160| 110| 3.90| 2.620| 16.46|  0|  1|    4|    4|
#  |Mazda RX4 Wag     | 21.0|   6|  160| 110| 3.90| 2.875| 17.02|  0|  1|    4|    4|
#  |Datsun 710        | 22.8|   4|  108|  93| 3.85| 2.320| 18.61|  1|  1|    4|    1|
#  |Hornet 4 Drive    | 21.4|   6|  258| 110| 3.08| 3.215| 19.44|  1|  0|    3|    1|
#  |Hornet Sportabout | 18.7|   8|  360| 175| 3.15| 3.440| 17.02|  0|  0|    3|    2|

# Read the documentation for ?knitr::kable to see the other ways in which you can customise the table.
# For even deeper customisation, consider the xtable, stargazer, pander, tables, and ascii packages.
# Each provides a set of tools for returning formatted tables from R code.

# There is also a rich set of options for controlling how figures are embedded.
# You'll learn about there in saving your plots. (https://r4ds.had.co.nz/graphics-for-communication.html#saving-your-plots)

# 27.4.4 Caching 

# Normally, each knit of a document starts from a completely clean slate.
# This is great for reproducibility, because it ensures that you've captured every important computation in code.
# However, it can be painful if you have some computations that take a long time. The solution is cache = TRUE.
# When set, this will save the output of the chunk to a specially named file on disk.
# On subsequent runs, knitr will check to see if the code has changed, and if it hasn't, it will reuse the cached results.

# The caching system must be used with care, because by default it is based ont the code only, not its dependencies.
# For example, here the precessed_data chunk depends on the raw_data chunk:

# |-----------------------------------------------------------------------|
# |                                                                       | 
# |      ```{r raw_data}                                                  |
# |      rawdata <- readr::read_csv("a_very_large_file.csv")              |
# |      ```                                                              |
# |                                                                       | 
# |      ```{r processed_data, cache = TRUE}                              |
# |      processed_data <- rawdata %>%                                    |
# |       filter(!is.na(import_var)) %>%                                  |
# |       mutate(new_variable = complicated_transformation(x, y, z))      |
# |      ```                                                              |
# |                                                                       | 
# |-----------------------------------------------------------------------|

# Caching the processed_data chunk means that it will get re-run if th edplyr pipeline is changed, 
# but it won't get rerun if the read_csv() call changes.
# You can avoid that problem with the dependson chunk option:

# |-----------------------------------------------------------------------|
# |                                                                       | 
# |     ```{r processed_data, cache = TRUE, dependson = "raw_data"}       |
# |     processed_data <- rawdata %>%                                     |
# |       filter(!is.na(import_var)) %>%                                  |
# |       mutate(new_variable = complicated_transformation(x, y, z))      |
# |     ```                                                               |
# |                                                                       | 
# |-----------------------------------------------------------------------|

# dependson should contain a character vector of every chunk that cached chunk depends on.
# Knitr will update the results for the cached chunk whenever it detects that one of its dependencies have changed.

# Note that chunks won't update if a_very_large_file.csv changes, because knitr caching only tracks changes within the .Rmd file.
# If you want to also track changes to that file you can use the cache.extra option.
# This is an arbitrary R expression that will invalidate the cache whenever it changes.
# A good function to use is file.info(): it returns a bunch of information about the file including when it was last modefied. 
# Then you can write:

# |-----------------------------------------------------------------------|
# |    ```{r raw_data, cache.extra = file.info("a_very_large_file.csv")}  |
# |    rawdata <- readr::read_csv("a_very_large_file.csv")                |
# |    ```                                                                |
# |-----------------------------------------------------------------------|

# As your caching strategies get progressively more complicated, 
# it's a good idea to regularly clear out al your caches with knitr::clean_cache().

# I've used the advice of David Robinson to name these chunks: each chunk is named after the primary object that it creates.
# This makes it easier to understand the dependson specification.
# (https://twitter.com/drob/status/738786604731490304)

# 27.4.5 Global options

# As you work more with knitr, you will discover that some of the default chunk options don't fit your needs and you want to cgabge them.
# You can do this by calling knitr::opts_chunk$set() in a code chunk.
# For example, when writing books and tutorials I set:
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE
)

# This uses my prefered comment formatting, and ensures that the code and output are kept closely entwined.
# On the other hand, if you were preparing a report, you might set:
knitr::opts_chunk$set(
  echo = FALSE
)

# That will hide the code by default, so only showing the chunks you deliberately choose to show (with echo = TRUE).
# You might consider setting message = FALSE and warning = FALSE,
# but that would makd it harder to debug problems because you wouldn't see any messages in the final document.

# 27.4.6 Inline code 

# There is on eother way to embed R code into an R Marksown document: directly into the text, with: `r`.
# This can be very useful if you mention properties of your data in the text.
# For example, in the example document I used at the start of the chapter I had:

## We have data about `r nrow(diamonds)` diamonds. Only `r nrow(diamonds) - nrow(smaller)` are larger than 2.5 carats. 
## The distribution of the remainder is shown below:

# When the report is knit, the results of these computations are inserted into the text:

## We have data about 53949 diamonds. Only 126 are larger than 2.5 carats.
## The distribution of th eremainder is shown below:

# When inserting numbers into text, format() is your friend.
# It allows you to set the number of digits so you don't print to a riduculous degree of accuracy, 
# and a bid.mark to make numbers easier to read. I'll often combine these into a helper function:
comma <- function(x) format(x, digits = 2, big.mark = ",")
comma(3452345)
comma(.12358124331)

# 27.4.7 Exercises

# 1. Add a section that explores how diamond sizes vary by cut, colour, and clarity.
#    Assume you're writing a report for someone who doesn't know R, 
#    and instead of setting echo = FALSE on each chunk, set a global option.




# 2. Download diamond-sizes.Rmd from https://github.com/hadley/r4ds/tree/master/rmarkdown.
#    Add a section that describes the largest 20 diamonds, including a table that displays their most important attributes.




# 3. Modify daimonds-size.Rmd to use comma() to produce nicely formatted output.
#    Also include the percentage fo diamonds that are larger than 2.5 carats.




# 4. Set up a network of chunks where d depends on c and b, and both b and c depend on a.
#    Have each chunk print lubridate::now(), set cache = TRUE, then verufy your nuderstanding of caching.






# 27.5 Troubleshooting 

# Troubleshooting R Markdown documents can be challenging because you are no longer in an interactive R environment, and you need to learn some new tricks.
# The first thing you should always try is to recreate the problem in an interactive session.
# Restart R, then "Run all chunks" (either from Code menu, under Run region), or with the keyboard shortcut Ctrl + Alt + R.
# If you're lucky, that will recreate the problem, and you cna figure out what's going on interactively.

# If that doesn't help, there must be something defferent between your interactive environment and the R markdown environment.
# You're going to need to systematically explore the options.
# The most common difference is the working directory: the working directory of an R Markdown is the directory in which it lives.
# Check the working directory is what you expect by including getwd() in a chunk.

# Next, brainstorm all the things that might cause the bug. 
# You'll need to systematically check that they're the same in your R session and your R markdown session.
# The easiest way to do that is to set error = TRUE on the chunk causing the problem, 
# then use print() and str() to check that settings are as you expect.

# 27.6 YANL header 

# You can control many other "whole document" settings by tweading the parameters of the YAML header.
# You might wonder what YAML stands for: it's "yet another markup language", 
# which is designed for representing hierarchicaldata in a way that's easy for humans to read and write.
# R Markdown uses it to control many details of the output.
# Here we'll discuss two: document parameters and bibliographies.

# 27.6.1 Parameters

# R Markdown documents can include one or more parameters whose values can be set when you render the report.
# Parameters are useful when you want to re-render the same report with distinct values for various key inputs.
# For example, you might be producing sales reports per branch, exam results by student, or demographic summaries by country.
# To declare one or more parameters, use the params field.

# This example uses a my_class parameter to determine which class of cars to display:

# |-----------------------------------------------------------------------|
# |      ---                                                              |
# |      output: html_document                                            |
# |      params:                                                          |
# |        my_class: "suv"                                                |
# |      ---                                                              |
# |      ---                                                              |
# |       ```{r setup, include = FALSE}                                   |
# |      library(ggplot2)                                                 |
# |      library(dplyr)                                                   |
# |                                                                       |
# |      class <- mpg %>% filter(class == params$my_class)                |
# |      ```                                                              |
# |                                                                       |
# |      # Fuel economy for `r params$my_class`s                          |
# |                                                                       |                          
# |      ```{r, message = FALSE}                                          |     
# |      ggplot(class, aes(displ, hwy)) +                                 |
# |        geom_point() +                                                 |  
# |        geom_smooth(se = FALSE)                                        | 
# |      ```                                                              | 
# |-----------------------------------------------------------------------|

# As you can see, parameters are available within the code chunks as a read-only list named params.

# You can write atomic vectors directly into the YAML header.
# You can also run arbitrary R expressions by prefacing the parameter value with !r.
# This is a good way to specify date/time parameters.

# |-----------------------------------------------------------------------|
# |                                                                       |
# |     params:                                                           |
# |       start: !r lubridate::ymd("2015-01-01")                          |
# |       snapshot: !r lubridate::ymd_hms("2015-01-01 12:30:00")          |
# |                                                                       |
# |-----------------------------------------------------------------------|

# In RStudio, you can click the "Knit with Parameters" option in the Knit dropdown menu to set parameters, 
# render. and preview the report in a single user friendly step.
# You can customise the dialog by setting other options in the header. 
# See http://rmarkdown.rstudio.com/developer_parameterized_reports.html#parameter_user_interfaces for more details.

# Alternatively, if you need to produce many such parameterised reports, you can call rmarkdown::render() with a list of params:

rmarkdown::render("fuel-economy.Rmd", params = list(my_class = "suv"))

# This is particularly powerful in conjunction with purrr::pwalk().
# The following example creates a report for each value of class found in mpg.
# First we create a frame that has one row for each class, giving the filename of the report and the params:
reports <- tibble(
  class = unique(mpg$class),
  filename = stringr::str_c("fuel-economy", class, ".html"),
  params = purrr::map(class, ~ list(my_class = .))
)
reports

# Then we match the column names to the argument names of render(), and use purrr's parallel walk to call render() once for each row:
reports %>% 
  select(output_file = filename, params) %>% 
  purrr::pwalk(rmarkdown::render, input = "./R_for_Data_Science/Rmd/fuel-economy.Rmd")

# 27.6.2 Bibliographies and Citations 

# Pandoc can automatically generate citations and a bibliography in a number of styles.
# To use this feature, specify a bibliography file using the bibliography field in your file's header.
# The field should contain a path from the directory that contains your.
# Rmd file to the file that contains the bibliography file:

bibliography: rmarkdown.bib

# You can use many common bibliography formats including BibLaTeX, BibTeX, endnote, medline.

# To create a citation within your .Rmd file, use a key composed of '@' + the citation identifier from the bibliography file.
# Then place the citation in square brackets. Here are some examples:

# |-------------------------------------------------------------------------------|
# |                                                                               |
# |     Separate multiple citations with a `;`: Blah blah [@smith04; @doe99].     |
# |                                                                               |
# |     You can add arbitrary comments inside the square brackets:                |
# |     Blah blah [see @doe99, pp. 33-35; also @smith04, ch. 1].                  |
# |                                                                               |
# |     Remove the square brackets to create an in-text citation: @smith04        |
# |     says blah, or @smith04 [p. 33] says blah.                                 |
# |                                                                               |
# |     Add a `-` before the citation to suppress the author's name:              |
# |     Smith says blah [-@smith04].                                              |
# |                                                                               |
# |-------------------------------------------------------------------------------|

# When R Markdown renders your file, it will build and append a bibliography to the end of your document.
# The bibliography will contain each of the cited references from your bibliography file, but it will not contain a section deading.
# As a result it is common pracitce to end your file with a section header for the bibliography, such as # References or # Bibliography.

# You can change the style of your citations and bibliography by referencing a CSL (citation style language) file in the csl field:
bibliography: rmarkdown.bib
csl: apa.csl

# As with the bibliography field, your csl file should contain a path to the file.
# Here I assume that the csl file is in the same directory as the .Rmd file.
# A good place to find CSL style files for common bibliography styles is http://github.com/citation-style-language/styles.

# 27.7 Learning more 

# R Markdown is still relatively young, and is still growing rapidly.
# The best place to stay on top of innovation is the official R Markdown website: http://rmarkdown.rstudio.com.

# There are two important topics that we haven't covered here: 
# collaboation, and the details of accurately communication your ideas to other humans.
# Colalboration is a vital part of modern data science, 
# and you can make your life much easier by using version control tools, like Git and Github.
# We recommend two free resources that will teach you about Git:

# 1. "Happy git with R": a user friendly introduction to Git and GitHub from R users, by Jenny Bryan.
#     The book is freely available online: http://happygitwithr.com
# 2. The "Git and GitHub" chapter of R Packages, by Hadley.
#    You can also read it for free online: http://r-pkgs.had.co.nz/git.html.

# I have also not touched on what you should actually write in order to cleaerly communicate the results of your analysis.
# To imporve your writing, I highly recommend reading either:Style: 
# Lessons in Clarity and Grace by Joseph M. Williams & Joseph Bizup (https://amzn.com/0134080416), 
# or The Sense of Structure: Writing from the Reader’s Perspective by George Gopen (https://amzn.com/0205296327).
# Both books will help you understand the structure of sentences and paragraphs, and give you the tools to make your writing more clear. 
# (These books are rather expensive if purchased new, but they’re used by many English classes so there are plenty of cheap second-hand copies). 
# George Gopen also has a number of short articles on writing at https://www.georgegopen.com/the-litigation-articles.html. 
# They are aimed at lawyers, but almost everything applies to data scientists too.

# ----------------------------------------------------------------------------------------------------------------------------

# 28 Graphics for communication

# 28.1 Introduction

# In exploratory data analysis, you learned how to use plots as tools for exploration. 
# When you make exploratory plots, you know—even before looking—which variables the plot will display. 
# You made each plot for a purpose, could quickly look at it, and then move on to the next plot. 
# In the course of most analyses, you’ll produce tens or hundreds of plots, most of which are immediately thrown away.

# Now that you understand your data, you need to communicate your understanding to others. 
# Your audience will likely not share your background knowledge and will not be deeply invested in the data. 
# To help others quickly build up a good mental model of the data, 
# you will need to invest considerable effort in making your plots as self-explanatory as possible.
# In this chapter, you’ll learn some of the tools that ggplot2 provides to do so.

# This chapter focuses on the tools you need to create good graphics. 
# I assume that you know what you want, and just need to know how to do it. 
# For that reason, I highly recommend pairing this chapter with a good general visualisation book. 
# I particularly like The Truthful Art, by Albert Cairo. 
# It doesn’t teach the mechanics of creating visualisations, but instead focuses on what you need to think about in order to create effective graphics.

# 28.1.1 Prerequisites

# In this chapter, we’ll focus once again on ggplot2.
# We’ll also use a little dplyr for data manipulation, and a few ggplot2 extension packages, including ggrepel and viridis. 
# Rather than loading those extensions here, we’ll refer to their functions explicitly, using the :: notation. 
# This will help make it clear which functions are built into ggplot2, and which come from other packages. 
# Don’t forget you’ll need to install those packages with install.packages() if you don’t already have them.

library(tidyverse)

# 28.2 Label

# The easiest place start when turning an exploratory graphic into an expository graphic is with good labels.
# You add labels with the labs() function. This example adds aplot title:

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(se = FALSE) + 
  labs(title = "Fuel efficiency generally decreases with engine size")

# The purpose of a plot title is to summarise the main finding. 
# Avoid titles that just describe what the plot is, e.g. “A scatterplot of engine displacement vs. fuel economy”.

# If you need to add more text, there are two other useful labels that you can use in ggplot2 2.2.0 and above 
# (which should be available by the time you’re reading this book):
  
# 1. subtitle adds additional detail in a smaller font beneath the title.
# 2. caption adds text at the bottom right of the plot, often used to describe the source of the data.

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(se = FALSE) + 
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov"
  )

# You can also use labs() to replace the axis and legend titles. 
# It’s usually a good idea to replace short variable names with more detailed descriptions, and to include the units.

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(se = FALSE) + 
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# It’s possible to use mathematical equations instead of text strings. 
# Just switch "" out for quote() and read about the available options in ?plotmath:

df <- tibble(
  x = runif(10),
  y = runif(10)
)
ggplot(df, aes(x, y)) + 
  geom_point() + 
  labs(
    x = quote(sum(x[i] ^ 2, i == 1, n)),
    y = quote(alpha + beta + frac(delta, theta))
  )

# 28.2.1 Exercises

# 1. Create one plot on the fuel economy data with customised title, subtitle, caption, x, y, and colour labels.

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(se = FALSE) + 
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov",
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# 2. The geom_smooth() is somewhat misleading because the hwy 
#    for large engines is skewed upwards due to the inclusion of lightweight sports cars with big engines. 
#    Use your modelling tools to fit and display a better model.

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(method = "lm", se = FALSE) + 
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov",
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )

# 3. Take an exploratory graphic that you’ve created in the last month, 
#    and add informative titles to make it easier for others to understand.



# 28.3 Annotations

# In addition to labelling major components of your plot, it's often useful to label individual observations or groups of observations.
# The first tool you have at your disposal is geom_text().
# geom_text() is similar to geom_point(), but it has an additional aesthetic: label.
# This makes it possible to add textual labels to your plots.
best_in_class <- mpg %>% 
  group_by(class) %>% 
  filter(row_number(desc(hwy)) == 1)

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_text(aes(label = model), data = best_in_class)

# This is hard to read because the labels overlap with each other, and with the points. 
# We can make things a little better by switching to geom_label() which draws a rectangle behind the text.
# We also use the nudge_y parameter to move the labels slightly above the corresponding points:
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_label(aes(label = model), data = best_in_class, nudge_y = 2, alpha = .5)

# That helps a bit, but if you look closely in the top-left hand corner, 
# you’ll notice that there are two labels practically on top of each other. 
# This happens because the highway mileage and displacement for the best cars in the compact and subcompact categories are exactly the same.
# There’s no way that we can fix these by applying the same transformation for every label.
# Instead, we can use the ggrepel package by Kamil Slowikowski.
# This useful package will automatically adjust labels so that they don’t overlap:
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_point(size = 3, shape = 1, data = best_in_class) + 
  ggrepel::geom_label_repel(aes(label = model), data = best_in_class)

# Note another handy technique used here: I added a second layer of large, hollow points to highlight the points that I’ve labelled.

# You can sometimes use the same idea to replace the legend with labels placed directly on the plot. 
# It’s not wonderful for this plot, but it isn’t too bad. 
# (theme(legend.position = "none") turns the legend off — we’ll talk about it more shortly.)
class_avg <- mpg %>% 
  group_by(class) %>% 
  summarise(
    displ = median(displ),
    hwy = median(hwy)
  )
ggplot(mpg, aes(displ, hwy, color = class)) + 
  ggrepel::geom_label_repel(aes(label = class),
     data = class_avg,
     size = 6,
     label.size = 0,
     segment.color = NA
  ) + 
  geom_point() + 
  theme(legend.position = "none")

# Alternatively, you might just want to add a single label to the plot, but you’ll still need to create a data frame. 
# Often, you want the label in the corner of the plot, 
# so it’s convenient to create a new data frame using summarise() to compute the maximum values of x and y.
label <- mpg %>% 
  summarise(
    displ = max(displ),
    hwy = max(hwy),
    label = "Increasing engine size is \nrelated to decreasing fuel economy."
  )
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right")

# If you want to place the text exactly on the borders of the plot, you can use +Inf and -Inf. 
# Since we’re no longer computing the positions from mpg, we can use tibble() to create the data frame:
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right")

# In these examples, I manually broke the label up into lines using "\n". 
# Another approach is to use stringr::str_wrap() to automatically add line breaks, given the number of characters you want per line:
"Increasing engine size is related to decreasing fuel economy." %>% 
  stringr::str_wrap(width = 40) %>% 
  writeLines()

# Note the use of hjust and vjust to control the alignment of the label. Figure 28.1 shows all nine possible combinations.

# 1.00 -|------------------|------------------|------------------|------------------|
#       | hjust = 'left'   |            hjust = 'center'         |  hjust = 'right' |
#       | vjust = 'top'    |            vjust = 'top'            |    vjust = 'top' |
# 0.75 -|------------------|------------------|------------------|------------------|
#       |                  |                  |                  |                  |
#       | hjust = 'left'   |            hjust = 'center'         |  hjust = 'right' |
# 0.50 -|------------------|------------------|------------------|------------------|
#       | vjust = 'center' |            vjust = 'center'         | vjust = 'center' |
#       |                  |                  |                  |                  |
# 0.25 -|------------------|------------------|------------------|------------------|
#       | hjust = 'left'   |            hjust = 'center'         |  hjust = 'right' |
#       | vjust = 'bottom' |            vjust = 'bottom'         | vjust = 'bottom' |
# 0.00 -|------------------|------------------|------------------|------------------|
#     0.00               0.25               0.50               0.75                1.00
#
#                     Figure 28.1: All nine combinations of hjust and vjust.

# Remember, in addition to geom_text(), you have many other geoms in ggplot2 available to help annotate your plot. A few ideas:
# 1. Use geom_hline() and geom_vline() to add reference lines. 
#    I often make them thick (size = 2) and white (colour = white), and draw them underneath the primary data layer. 
#    That makes them easy to see, without drawing attention away from the data.
# 2. Use geom_rect() to draw a rectangle around points of interest. 
#    The boundaries of the rectangle are defined by aesthetics xmin, xmax, ymin, ymax.
# 3. Use geom_segment() with the arrow argument to draw attention to a point with an arrow. 
#    Use aesthetics x and y to define the starting location, and xend and yend to define the end location.

# The only limit is your imagination (and your patience with positioning annotations to be aesthetically pleasing)!

# 28.3.1 Exercises

# 1. Use geom_text() with infinite positions to place text at the four corners of the plot.




# 2. Read the documentation for annotate(). How can you use it to add a text label to a plot without having to create a tibble?
  




# 3. How do labels with geom_text() interact with faceting?
#    How can you add a label to a single facet? 
#    How can you put a different label in each facet? (Hint: think about the underlying data.)




# 4. What arguments to geom_label() control the appearance of the background box?
  



# 5. What are the four arguments to arrow()? How do they work? 
#    Create a series of plots that demonstrate the most important options.







# 28.4 Scles

# The third way you can make your plot better for comunication is to adjust th scales.
# Scales control the mapping from data values to thing that you can perceive.
# Normally, ggplot2 automatically adds scales for you. For example, then you type:

ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class))

# ggplot2 automatically adds default scales behind the scenes:
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  scale_x_continuous() + 
  scale_y_continuous() +
  scale_color_discrete()

# Note the naming scheme for scales: scale_ followed by th ename of the aesthetic, then _ , then the name of the scale.
# The default scales are named according to the type of variable they align with: contiuous, discrete, datetime, or date.
# There are lots of non-dejault scales which you'll learn about below.

# The default scales have been carefully chosen to do a good job for a wide range of inputs.
# Nevertheless, you might want to override the defaults for two reasons:
# 1. You might wnat to tweak some of the parameters of the default scales.
#    This allows you to do thing like change the breaks on the axes, or the key labels on the legend.
# 2. You might want to replace the scale altogether, and use a completely different algorithm.
#    Often you can do better than the default because you know more about the data.

# 28.4.1 Axis ticks and legend keys

# There are two primary arguments that affect the appearance of the ticks on the axes and the key on the legend: breaks and labels.
# Breaks controls the position of the ticks, or the values associated with the keys.
# Labels controls the text label associated with each tick/key.
# The most common use of breaks is to override the default choice:
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  scale_y_continuous(breaks = seq(15, 40, by = 5))

# You can use labels in the same way (a character vector the same length as breaks), but you can also set it to NULL to suppress the labels altogether.
# This is useful for maps, or for publishing plots where you can't share the absolute numbers.
ggplot(mpg, aes(displ, hwy)) + 
  geom_point() + 
  scale_x_continuous(labels = NULL) + 
  scale_y_continuous(labels = NULL)

# You can also use breaks and labels to control the appearance of legends. Collectively axes and legends are called guides.
# Axes are used for x and y aesthetics; legends are used for everything else.

# Another use of breaks is when you have relatively few data points and want to highlihgt exactly where the observations occur.
# take this plot that shows when each US president started and ended their term.
presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start, id)) + 
  geom_point() + 
  geom_segment(aes(xend = end, yend = id)) + 
  scale_x_date(NULL, breaks = presidential$start, date_labels = "'%y")

# Note that the specification of breaks and labels for date and datetiem scales is a little different:
# 1. date_labels takes a format specification, in the same form as parse_datetime().
# 2. date_breaks (not shown here), takes a string like "2 days" or "1 month".

# 28.4.2 Legend layout

# You will most often use breaks and labels to tweak the axes. While they both also work for legends, 
# there are a few other techniques you are more likely to use.

# To control the overall position of the legend, you need to use a theme() setting.
# We'll come back to themes at the end of the chapter, but in brief, they control the non-data parts of the plot.
# The theme setting legend.position controls where the legend is drawn:
base <- ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class))

base + theme(legend.position = "left")
base + theme(legend.position = "top")
base + theme(legend.position = "bottom")
base + theme(legend.position = "right") # the default

# You can also use legend.potition = "none" to suppress the display of the legend altogether.

# To control the display of individual legends, use guides() along with giude_legend() or guide_colourbar()
# The following example shows two important settings: controlling the number of rows the legend used with nrow, 
# and overriding one of the aesthetics to make the points bigger.
# This is particularly useful if you have used a low alpha to display many points on a plot.
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth(se = FALSE) + 
  theme(legend.position = "bottom") + 
  guides(color = guide_legend(nrow = 1, override.aes = list(size = 4)))

# 28.4.3 Replacing a scale

# Instead of just tweaking the details a little, you can instead replace the scale altogether.
# There are two types of scales you're mostly likely to want to switch out: continuous position scales and color scales.
# Fortunately, the same principles apply to all the other aesthetics, so once you've mastered position and color, 
# you'll be able to quickly pick up other scale replacements.

# It's very useful to plot transformations of your variable.
# For exmaple, as we've seen in diamond prices it's easier to see the precise relationship between carat and price if we log transform them:
ggplot(diamonds, aes(carat, price)) + 
  geom_bin2d()

ggplot(diamonds, aes(log10(carat), log10(price))) + 
  geom_bin2d()

# However, the disadvantage of this transformation is that the axes are now labelled with the transformed values, 
# making it hard to interpret the plot.
# Instead of doing the transformation in the aesthetic mapping, we can instead do it with the scale.
# This is visually identical, except the axes are labelled on the original data scales.
ggplot(diamonds, aes(carat, price)) + 
  geom_bin2d() + 
  scale_x_log10() + 
  scale_y_log10()

# Another scale that is frequently customised is color. 
# The default categorical scale picks colors that are evenly spaced around the color wheel.
# Useful alternatives are the ColorBrewer scales which have been hand tuned to work better for people with common types of color blindness.
# The two plots below look similar,
# but there is enough difference in the shades of red and green that the dots on the right can be distinguished even by people with red-green color blindness.
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = drv))

ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) + 
  scale_color_brewer(palette = "Set1")

# Don't forget simpler techniques. If there are just a few colors, you can add a redundant shape mapping.
# This will also help ensure your plot is interpretable in black and white.
ggplot(mpg, aes(displ, hwy)) + 
  geom_point(aes(color = drv, shape = drv)) + 
  scale_color_brewer(palette = "Set1")

# The ColorBrewer scales are documented online at http://colorbrewer2.org/ and made available in R via the RColorBrewer package, by Erich Neuwirth.
# Figure 28.2 shows the complete list of all palettes.
# The sequential (top) and diverging (bottom) palettes are particularly useful if your categorical values are ordered, or have a "middle".
# This often arises if you've used cut() to make a continuous variable into a categorical variable.

# When you have a predefined mapping between values and colors, use scale_color_manual().
# For exmaple, if we map presidential party to color, we want to use the standard mapping of red for Republicans and blue for Democrats:
presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start, id, color = party)) + 
  geom_point() + 
  geom_segment(aes(xend = end, yend = id)) + 
  scale_color_manual(values = c(Republican = "red", Democratic = "blue"))

# For continuous color, you can use the built-in scale_color_gradient() or scale_fill_gradient().
# If you have a diverging scale, you can use scale_color_gradient2().
# That allows you to give, for example, positive and negative values different colors.
# That's sometimes also useful if you want to distinguish points above or below the mean.

# Another option is scale_color_virides() provided by the viridis pabkage.
# It's a continuous analog of the categorical ColorBrewer scales.
# The designers, Nathaniel Stéfan van der Walt, carefully tailored a continuous color scheme that has good perceptual properties.
# Here's an example from the viridis vignette.
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

ggplot(df, aes(x, y)) + 
  geom_hex() + 
  coord_fixed()

ggplot(df, aes(x, y)) + 
  geom_hex() + 
  viridis::scale_fill_viridis() + 
  coord_fixed()

# Note that all color scales come in two variety: scale_color_x() and scale_fill_x() for the color and fill aesthetics respectively
# (the color scales are available in both UK and US spellings).
















