# Advanced R - Hadley wickham
# This is the website for 2nd edition of __Advanced R__.
# Lindk: https://adv-r.hadley.nz

# The 1st edition: http://adv-r.had.co.nz/

# Other books
# - Advanced R solutions: http://advanced-r-solutions.rbind.io/
# - R for Data Science: http://r4ds.had.co.nz/
# - R packages: http://r-pkgs.had.co.nz/

# -----------------------------------------------------------------------------------------
# 1. Introduction

# 1.1 Why R

# Some of the best features are:
# 1. It's free, open source, and available on every major patform.
# 2. Diverse and welcoming community.
# 3. A massive set of packages for statistical modelling.
# 4. Powerful tools for communicating your results. Like RMarkdown, Shiny, etc.
# 5. RStudio IDE.
# 6. Cutting edge tools.
# 7. Deep-seated language suport for data anylysis.
# 8. A strong foundation of functional programming.
# 9. Powerful metaprogramming facilities.
# 10. The ease with which R can connect to high-performance programming languages like C, Fortran, and C++.

# Opportunity
# 1. Much of the R code you’ll see in the wild is written in haste to solve a pressing problem.
# 2. Compared to other programming languages, the R community is more focussed on results than processes.
# 3. Metaprogramming is a double-edged sword. Too many R functions use tricks to reduce the amount of typing at the cost of making code that is hard to understand and that can fail in unexpected ways.
# 4. Inconsistency is rife across contributed packages, and even within base R. 
# 5. R is not a particularly fast programming language, and poorly written R code can be terribly slow. R is also a profligate user of memory.

# 1.2 Who should read this book

# - Intermediate R programmers who want to dive deeper into R, understand how the language works, and learn new strategies for solning diverse problems.
# - Programmers from other languages who are learning R and want to understand why r works the way it does.

# 1.3 What you will get out of this book

# - Be familar with the foundations of R.
# - Understand what funcitonal programming means, and why it is a useful tool for data science.
# - know about R's rich variety of object-oriented systems.
# - Appreciate the double-edged sword of metaprogramming.
# - Have a good intuition for which operations in r are slow or use a lot of memory.

# 1.4 What you will not learn

# This book is about R the programming language, not R the data analysis tool.

# 1.5 Meta-techniques

# There are two meta-techniques that are tremendously helpful for improving your skills as an R programmer:
# - reading source code 
# - adoptng a scientific mindset

# 1.6 Recommended reading 

# - To understand why R's object systems work the way they do: The Structure and Interpretation of Computer Programs1 (Abelson, Sussman, and Sussman 1996) (SICP) 
# - To understand the trade-offs that R ahs made compared to other programming languages: Techniques and Models of Computer Programming (Van-Roy and Haridi 2004)
# - Want to learn to be a better programmer: The Pragmatic Programmer (Hunt and Thomas 1990)

# 1.7 Getting help 

# There are three main venues to get help when you're stuck and can't figure out waht's causing the problem:
# - RStudio Community 
# - StackOverflow
# - R-help mailing list

# 1.8 Acknowledgments

# 1.9 Conventions

# Many examples use random numbers. There are made reproducible by `set.seed(1014)`, which is executed automatically at the start of each chapter.

# 1.1o colophon
