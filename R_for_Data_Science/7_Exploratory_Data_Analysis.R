# 7 Exploratory Data Analysis
## 7.1 Introduction
## This chapter will show you how to use visualisation and transformation to explore your data 
## in a systematic way, a task that statisticians call exploratory data analysis, or EDA for short. 
## EDA is an iterative cycle. You:
## (1) Generate questions about your data.
## (2) Search for answers by visaulising, transfoming and modeling your data.
## (3) Use what you learn to refine your questions and/or generate a new questions.

## EDA is not a formal process with a strict set of rules. More than anything, EDA is a state of mind.
## Data cleaning is just one application of EDA: you ask questions about whether your data meets your expectations or not. 
## To do data cleaning, you’ll need to deploy all the tools of EDA: visualisation, transformation, and modelling.

# 7.1.1 Prerequisites
## In this chapter we’ll combine what you’ve learned about dplyr and ggplot2 to interactively ask questions, 
## answer them with data, and then ask new questions.
library(tidyverse)

# 7.2 Questions
## Your goal during EDA is to develop an understanding of your data.
## EDA is fundamentally a creative process. And like most creative processes, 
## the key to asking quality questions is to generate a large quantity of questions.

## There two types of questions will always be useful for making discoveries within your data:
## (1) What type of variation occurs within my variables?
## (2) What type of covariation occurs between my variables?

## To make the discussion easier, let’s define some terms:
## (1) A variable is a quantity, quality, or property that you can measure.
## (2) A value is the state of a variable when you measure it.
##     The value of a variable may change from measurement to measurement.
## (3) A observation is a set of measurements made under similiar conditions
##     (you usually make all of the measurements in an observation at the same time and on the same object).
##     An observation will contain several values, each associated with a different variable.
## (4) Tabular data is a set of values, each associated with a variable and an observation.
##     Tabular data is tidy if each value is placed in its own 'cell', each variable in its own column, 
##     and each obsevation in its own row.

# 7.3 Variation
## Variation is the tendency of the values of a variable to change from measurement to measurement. 

# 7.3.1 Visualising distributions
## A variable is categorical if it can only take one of a small set of values. 
## In R, categorical variables are usually saved as factors or character vectors.
## To examine the distribution of a categorical variable, use a bar chart:
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

## The height of the bars displays how many observations occurred with each x value. 
## You can compute these values manually with dplyr::count():
diamonds %>% count(cut)

## A variable is continuous if it can take any of an infinite set of ordered values. 
## Numbers and date-times are two examples of continuous variables.
## To examine the distribution of a continuous variable, use a histogram:
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = carat), binwidth = 0.5)

diamonds %>% count(cut_width(carat, 0.5))
## A histogram divides the x-axis into equally spaced bins and then uses the height of 
## a bar to display the number of observations that fall in each bin. 

smaller <- diamonds %>% filter(carat < 3)
ggplot(data = smaller, mapping = aes(x = carat)) + 
  geom_histogram(binwidth = 0.1)

## If you wish to overlay multiple histograms in the same plot, 
## I recommend using geom_freqpoly() instead of geom_histogram()
## It’s much easier to understand overlapping lines than bars.
ggplot(data = smaller, mapping = aes(x = carat, color = cut)) + 
  geom_freqpoly(binwidth = 0.1)

# 7.3.2 Typical values
## 1. Which values are the most common? Why?
## 2. Which values are rare? Why? Does that match your expectations?
## 3. Can you see any unusual patterns? What might explain them?

# 7.3.3 Unusual values
## Outliers are observations that are unusual; data points that don’t seem to fit the pattern. 
## Sometimes outliers are data entry errors; other times outliers suggest important new science. 
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

## To make it easy to see the unusual values, 
## we need to zoom to small values of the y-axis with coord_cartesian():
ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

unusual <- diamonds %>% 
  filter(y < 3 | y > 20) %>% 
  select(price, x, y, z) %>% 
  arrange(x)

unusual
## The y variable measures one of the three dimensions of these diamonds, in mm. 
## We know that diamonds can’t have a width of 0mm, so these values must be incorrect. 
## We might also suspect that measurements of 32mm and 59mm are implausible: 
## those diamonds are over an inch long, but don’t cost hundreds of thousands of dollars!

# 7.3.4 Exercises
# 1. Explore the distribution of each of the x, y, and z variables in diamonds. What do you learn? 
#    Think about a diamond and how you might decide which dimension is the length, width, and depth.
?diamonds
## x: length
## y: width
## z: depth
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = x), binwidth = .1)

ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = y), binwidth = .1)

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = z), binwidth = .1)

# 2. Explore the distribution of price. Do you discover anything unusual or surprising? 
#    (Hint: Carefully think about the binwidth and make sure you try a wide range of values.)
diamonds %>% select(price) %>% range()

ggplot(data = diamonds, mapping = aes(x = price)) + 
  geom_histogram(binwidth = 20) + 
  scale_x_continuous(breaks = c(500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000))

# 3. How many diamonds are 0.99 carat? How many are 1 carat? What do you think is the cause of the difference?
diamonds %>% 
  filter(between(carat, 0.97, 1.03)) %>% 
  group_by(carat) %>% 
  summarise(count = n()) %>% 
  ggplot(mapping = aes(x = carat, y = count, fill = carat)) +
  stat_identity(geom = 'bar') # == geom_bar(stat = "identity")
## the count of 0.99 carat is 23 and 1 carat is 1558, the different maybe is seller or buyer just want 1 carat.

# 4. Compare and contrast coord_cartesian() vs xlim() or ylim() when zooming in on a histogram. 
#    What happens if you leave binwidth unset? What happens if you try and zoom so only half a bar shows?
## step 1:
?coord_cartesian
## step 2:
args(coord_cartesian)

## original
ggplot(data = diamonds, mapping = aes(x = price)) + 
  geom_histogram(binwidth = 20)

## use coord_cartesian()
### some data beyond those limits are still being shown. 
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_histogram(binwidth = 20) +
  coord_cartesian(xlim = c(500, 5000))

## unset binwidth
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_histogram() +
  coord_cartesian(xlim = c(500, 5000))

## use xlim() or ylim()
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = price), binwidth = 20) +
  xlim(c(500, 5000))

# 7.4 Missing value
## If you’ve encountered unusual values in your dataset, 
## and simply want to move on to the rest of your analysis, you have two options.

## 1. Drop the entire row with the strange values: ******* not recommand ********
diamonds2 <- diamonds %>% 
  filter(between(y, 3, 20))

## 2. Replacing the unusual values with missing values.
## The easiest way to do this is to use mutate() to replace the variable with a modified copy. 
## You can use the ifelse() function to replace unusual values with NA:
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

## ggplot2 subscribes to the philosophy that missing values should never silently go missing.
## ggplot2 doesn’t include them in the plot, but it does warn that they’ve been removed:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point()
### Warning message: Removed 9 rows containing missing values (geom_point). 
## To suppress that warning, set na.rm = TRUE:
ggplot(data = diamonds2, mapping = aes(x = x, y = y)) + 
  geom_point(na.rm = TRUE)

## Other times you want to understand what makes observations with missing values 
## different to observations with recorded values.
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time)) + 
  geom_freqpoly(mapping = aes(color = cancelled), binwidth = 1/4)

# 7.4.1 Exercises
# 1. What happens to missing values in a histogram? 
#    What happens to missing values in a bar chart? Why is there a difference?
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

ggplot(data = diamonds2) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.1)
## Warning message: Removed 9 rows containing non-finite values (stat_bin). 

ggplot(data = data.frame(type = c('A', 'A', 'B', 'B', 'B', NA))) + 
  geom_bar(mapping = aes(x = type))
## In geom_bar(), the missing values are counted and treated as a category.

## I think the different between geom_histogram and geom_bar is one plot is 
## for continuour variable and the other is for categorical variable, 
## so in geom_bar, NA value is one kind of category.

# 2. What does na.rm = TRUE do in mean() and sum()?
test_na <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, NA, NA)

sum(test_na)
sum(test_na, na.rm = TRUE)

mean(test_na)
mean(test_na, na.rm = TRUE)
## na.rm = TRUE: will do logical test, if the value is NA, then it will be removed 
## when do sum or mean compution.

# 7.5 Covariation
## If variation describes the behavior within a variable, 
## covariation describes the behavior between variables.

## Covariation is the tendency for the values of two or 
## more variables to vary together in a related way

# A categorical and continuous variable

ggplot(data = diamonds, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(color = cut), binwith = 500)
## It’s hard to see the difference in distribution 
## because the overall counts differ so much

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

## Instead of displaying count, we’ll display density, 
## which is the count standardised so that the area under each frequency polygon is one.
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# Another alternative to display the distribution of a continuous variable broken down by a categorical variable is the boxplot. 
# A boxplot is a type of visual shorthand for a distribution of values that is popular among statisticians. 

# Each boxplot consists of:
# 1. A box that stretches from the 25th percentile of the distribution to the 75th percentile, a distance known as the interquartile range (IQR). 
#    In the middle of the box is a line that displays the median
# 2. Visual points that display observations that fall more than 1.5 times the IQR from either edge of the box. 
#    These outlying points are unusual so are plotted individually.
# 3. A line (or whisker) that extends from each end of the box and goes to 
#    the farthest non-outlier point in the distribution.

## the distribution of price by cut using geom_boxplot()
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) + 
  geom_boxplot()

## Many categorical variables don’t have such an intrinsic order, 
## so you might want to reorder them to make a more informative display. 
## One way to do that is with the reorder() function.
?reorder

## For example, take the class variable in the mpg dataset. 
## You might be interested to know how highway mileage varies across classes:
### oringin
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

### reorder()
ggplot(data = mpg, mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  geom_boxplot()

## If you have long variable names, geom_boxplot() will work better 
## if you flip it 90°. You can do that with coord_flip().
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) + 
  coord_flip()

# 7.5.1.1 Exercises
# 1. Use what you’ve learned to improve the visualisation of 
#    the departure times of cancelled vs. non-cancelled flights.
## original
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time)) +
  geom_freqpoly(mapping = aes(color = cancelled), binwidth = .25)

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time, y = ..density..)) +
  geom_freqpoly(mapping = aes(color = cancelled), binwidth = .25)

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time, y = ..density..)) +
  geom_density(mapping = aes(color = cancelled))

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100, 
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = cancelled, y = sched_dep_time)) +
  geom_boxplot()

# 2. What variable in the diamonds dataset is most important for predicting 
#    the price of a diamond? How is that variable correlated with cut? 
#    Why does the combination of those two relationships lead to lower 
#    quality diamonds being more expensive?
ggplot(data = diamonds, mapping = aes(x = carat, y = price)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = reorder(cut, price, FUN = median), y = price, color = cut))

ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = reorder(clarity, price, FUN = median), y = price, color = clarity))

ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = reorder(color, price, FUN = median), y = price, color = color))


## reference: https://lokhc.wordpress.com/r-for-data-science-solutions/chapter-7-exploratory-data-analysis/
diamonds %>% 
  mutate(
    color = as.numeric(color),
    clarity = as.numeric(clarity),
    cut = as.numeric(cut)
  ) %>% 
  select(price, everything()) %>% 
  cor()
## (1) carat is the most correlated variable with price, so it is the most important variable in predicting price of diamonds.
## (2) carat and cut are slightly negatively correlated, meaning diamonds of higher weights tend to have a lower cut rating.

# 3. Install the ggstance package, and create a horizontal boxplot. How does this compare to using coord_flip()?
if(!require(ggstance)) install.packages('ggstance')
library(ggstance)

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100, 
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = cancelled, y = sched_dep_time)) +
  geom_boxplot() +
  coord_flip()

nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100, 
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot(mapping = aes(x = sched_dep_time, y = cancelled)) +
  geom_boxploth()

# 4. One problem with boxplots is that they were developed in an era of much smaller datasets and tend to 
#    display a prohibitively large number of “outlying values”. One approach to remedy this problem is the letter value plot. 
#    Install the lvplot package, and try using geom_lv() to display the distribution of price vs cut. What do you learn? 
#    How do you interpret the plots?
ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = cut, y = price))

if(!require(lvplot)) install.packages('lvplot')
library(lvplot)

ggplot(data = diamonds, mapping = aes(x = cut, y = price)) + 
  geom_lv()
## Reference: letter value boxplot
## https://www.r-project.org/conferences/useR-2006/Slides/HofmannEtAl.pdf

# 5. Compare and contrast geom_violin() with a facetted geom_histogram(), or a coloured geom_freqpoly(). 
#    What are the pros and cons of each method?
## geom_violin()
ggplot(data = diamonds) + 
  geom_violin(mapping = aes(x = cut, y = price)) + 
  coord_flip()

## geom_histogram() with faceted
ggplot(data = diamonds) + 
  geom_histogram(mapping = aes(x = price, fill = cut), show.legend = FALSE, binwidth = 20) + 
  facet_grid(cut ~ .)

## coloured geom_freqpoly()
ggplot(data = diamonds) + 
  geom_freqpoly(mapping = aes(x = price, color = cut))

## referenct: https://lokhc.wordpress.com/r-for-data-science-solutions/chapter-7-exploratory-data-analysis/

# 6. If you have a small dataset, it’s sometimes useful to use geom_jitter() to see the relationship between a continuous 
#    and categorical variable. The ggbeeswarm package provides a number of methods similar to geom_jitter().
#    List them and briefly describe what each one does.
if(!require(ggbeeswarm)) install.packages('ggbeeswarm')
library(ggbeeswarm)
## original
ggplot(data = mpg, mapping = aes(x = cyl, y = hwy)) +
  geom_point()

## same as original
ggplot(data = mpg, mapping = aes(x = cyl, y = hwy)) + 
  geom_jitter()

## (1) geom_quasirandom
## (2) geom_beeswarm
ggplot(data = mpg, mapping = aes(x = cyl, y = hwy)) + 
  geom_beeswarm()

ggplot(data = mpg, mapping = aes(x = cyl, y = hwy)) + 
  geom_quasirandom()


# 7.5.2 Two categorical variables
## To visualise the covariation between categorical variables, 
## you’ll need to count the number of observations for each combination. 

## geom_count()
ggplot(data = diamonds) + 
  geom_count(mapping = aes(x = cut, y = color))

## compute the count with dplyr
diamonds %>% 
  count(color, cut)

## visualise with geom_tile() and the fill aesthetic
diamonds %>% 
  count(color, cut) %>% 
  ggplot(mapping = aes(x = color, y = cut)) + 
  geom_tile(mapping = aes(fill = n))

## For larger plots, you might want to try the d3heatmap or heatmaply packages, which create interactive plots.
## https://github.com/rstudio/d3heatmap
if (!require("devtools")) install.packages("devtools")
devtools::install_github("rstudio/d3heatmap")
library(d3heatmap)
d3heatmap(mtcars, scale = "column", colors = "Spectral")

## https://github.com/talgalili/heatmaply
if(!require('heatmaply')) install.packages('heatmaply')
library(heatmaply)
heatmaply(mtcars, k_row = 3, k_col = 2)

# 7.5.2.1 Exercises
# 1. How could you rescale the count dataset above to more clearly 
#    show the distribution of cut within colour, or colour within cut?
## original
ggplot(data = diamonds) + 
  geom_count(mapping = aes(x = color, y = cut))
## change the scale
diamonds %>% 
  count(color, cut) %>% 
  group_by(color) %>% 
  mutate(prop = n / sum(n)) %>% 
  ggplot(mapping = aes(x = color, y = cut, fill = prop)) + 
  geom_tile()

# 2. Use geom_tile() together with dplyr to explore how average flight 
#    delays vary by destination and month of year. 
#    What makes the plot difficult to read? How could you improve it?

## (1) how average flight delays vary by destination and month of year. 
nycflights13::flights %>% 
  group_by(dest, month) %>% 
  summarise(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ggplot(mapping = aes(x = factor(month), y = dest, fill = avg_dep_delay)) + 
  geom_tile()

## (2) How could you improve it?
nycflights13::flights %>% 
  group_by(dest, month) %>% 
  summarise(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) %>% 
  ungroup() %>% 
  group_by(dest) %>% 
  mutate(n_month = n()) %>% 
  ggplot(mapping = aes(x = factor(month), 
                       y = reorder(dest, n_month), 
                       fill = avg_dep_delay)) + 
  geom_tile() + 
  scale_fill_gradient2(low = 'yellow', mid = 'orange', high = 'red', midpoint = 35)

# 3. Why is it slightly better to use aes(x = color, y = cut) rather than 
#    aes(x = cut, y = color) in the example above?
diamonds %>% 
  count(color, cut) %>% 
  ggplot() + 
  geom_tile(mapping = aes(x = color, y = cut, fill = n))

# 7.5.3 Two continuous variables
# geom_point(): relationship between the carat size and price of a diamond.
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

# Scatterplots become less useful as the size of your dataset grows, because points begin to overplot, 
# and pile up into areas of uniform black (as above). You’ve already seen one way to fix the problem:
# using the alpha aesthetic to add transparency.
ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price), alpha = .01)

# But using transparency can be challenging for very large datasets. Another solution is to use bin.
# Previously you used geom_histogram() and geom_freqpoly() to bin in one dimension. 
# Now you’ll learn how to use geom_bin2d() and geom_hex() to bin in two dimensions.
ggplot(data = smaller) + 
  geom_bin2d(mapping = aes(x = carat, y = price))

ggplot(data = smaller) + 
  geom_hex(mapping = aes(x = carat, y = price))

# Another option is to bin one continuous variable so it acts like a categorical variable.
ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

## cut_width(x, width), as used above, divides x into bins of width width.
## it’s difficult to tell that each boxplot summarises a different number of points. 
## One way to show that is to make the width of the boxplot proportional to the number of points with varwidth = TRUE.

ggplot(data = smaller, mapping = aes(x = carat, y = price)) + 
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)), varwidth = TRUE)

# Another approach is to display approximately the same number of points in each bin. That’s the job of cut_number():
ggplot(data = smaller) + 
  geom_boxplot(mapping = aes(x = carat, y = price, group = cut_number(carat, 20)))

# 7.5.3.1 Exercises
# 1. Instead of summarising the conditional distribution with a boxplot,
#    you could use a frequency polygon. What do you need to consider when using cut_width() vs cut_number()? 
#    How does that impact a visualisation of the 2d distribution of carat and price?
ggplot(data = smaller, mapping = aes(x = price)) + 
  geom_freqpoly(mapping = aes(color = cut_width(carat, .2)), bins = 20)

ggplot(data = smaller) + 
  geom_freqpoly(mapping = aes(x = price, color = cut_number(carat, 10)), bins = 20)

?cut_number
## cut_number makes n groups with (approximately) equal numbers of observations; 
## cut_width makes groups of width width.

ggplot(data = diamonds) + 
  geom_bin2d(mapping = aes(x = price, y = carat, fill = cut_width(carat, .4)))

ggplot(data = diamonds) + 
  geom_bin2d(mapping = aes(x = price, y = carat, fill = cut_number(carat, 12)))

# 2. Visualise the distribution of carat, partitioned by price.
ggplot(data = diamonds, y = ..density..) + 
  geom_freqpoly(mapping = aes(x = carat, color = cut_number(price, 5)), bins = 30)

# 3. How does the price distribution of very large diamonds compare to small diamonds? 
#    Is it as you expect, or does it surprise you?
ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = price, y = carat, color = cut_number(price, 10)))
## The price distribytion of large diamonds are much more variable the small diamonds.

# 4. Combine two of the techniques you’ve learned to visualise the combined distribution of cut, carat, and price.
ggplot(data = diamonds) + 
  geom_point(mapping = aes(x = carat, y = price, color = cut), alpha = .25)

ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = cut, y = price, color = cut_number(carat, 5)))

ggplot(data = diamonds) + 
  geom_bin2d(mapping = aes(x = price, y = cut, fill = cut_number(carat, 5)))


# 5. Two dimensional plots reveal outliers that are not visible in one dimensional plots. 
#    For example, some points in the plot below have an unusual combination of x and y values, 
#    which makes the points outliers even though their x and y values appear normal when examined separately.
ggplot(data = diamonds) +
  geom_point(mapping = aes(x = x, y = y)) +
  coord_cartesian(xlim = c(4, 11), ylim = c(4, 11))

# 7.6 Patterns and models
## Patterns in your data provide clues about relationships. If a systematic relationship exists between two variables 
## it will appear as a pattern in the data. If you spot a pattern, ask yourself:

## 1. Could this pattern be due to coincidence (i.e. random chance)?
## 2. How can you describe the relationship implied by the pattern?
## 3. How strong is the relationship implied by the pattern?
## 4. What other variables might affect the relationship?
## 5. Does the relationship change if you look at individual subgroups of the data?

ggplot(data = faithful) + 
  geom_point(mapping = aes(x = eruptions, y = waiting))
## Patterns provide one of the most useful tools for data scientists because they reveal covariation. 
## If you think of variation as a phenomenon that creates uncertainty, covariation is a phenomenon that reduces it. 
## If two variables covary, you can use the values of one variable to make better predictions about the values of the second.
## If the covariation is due to a causal relationship (a special case), 
## then you can use the value of one variable to control the value of the second.

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

ggplot(data = diamonds) + 
  geom_boxplot(mapping = aes(x = cut, y = price)) + 
  facet_grid(. ~ carat)

## The following code fits a model that predicts price from carat and then computes 
## the residuals (the difference between the predicted value and the actual value). 
## The residuals give us a view of the price of the diamond, once the effect of 
## carat has been removed.
library(modelr)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>% 
  add_residuals(mod) %>% 
  mutate(resid = exp(resid))

ggplot(data = diamonds2) + 
  geom_point(mapping = aes(x = carat, y = resid))

## Once you’ve removed the strong relationship between carat and price, 
## you can see what you expect in the relationship between cut and price: 
## relative to their size, better quality diamonds are more expensive.
ggplot(data = diamonds2) + 
  geom_boxplot(mapping = aes(x = cut, y = resid))

# 7.7 ggplot2 

ggplot(data = faithful, mapping = aes(x = eruptions)) + 
  geom_freqpoly(binwidth = .25)

# saves typing, and, by reducing the amount of boilerplate, makes it easier to see 
# what’s different between plots.

# Rewriting the previous plot more concisely yields:
ggplot(faithful, aes(eruptions)) + 
  geom_freqpoly(binwidth = .25)

# Sometimes we’ll turn the end of a pipeline of data transformation into a plot. Watch for the transition from %>% to +. 
diamonds %>% 
  count(cut, clarity) %>% 
  ggplot(aes(clarity, cut, fill = n)) + 
  geom_tile()

# 7.8 Learning more
#  https://amzn.com/331924275X
# https://amzn.com/1449316956
# http://www.cookbook-r.com/Graphs/
# https://amzn.com/1498715230
