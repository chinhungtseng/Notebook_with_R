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




































