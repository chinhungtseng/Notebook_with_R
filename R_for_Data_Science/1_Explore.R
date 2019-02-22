setwd('/Users/peter/Documents/Project/Notebook_with_R/R_for_Data_Science/')
getwd()
# This is the note with book: R for Data Science
# https://r4ds.had.co.nz/explore-intro.html

# 2 Introduction
## Data Exploration Program Flow
## Import -> Tidy -> Explore{ Tramsform <-> Visualise <-> Model } -> Communicate
library(tidyverse)

# 3 Data visualization
## 3.1
library(tidyverse)

## 3.2 First steps
mpg
## displ, a car’s engine size, in litres
## hwy, a car’s fuel efficiency on the highway, in miles per gallon (mpg)
## Creating a ggplot
ggplot(data = mpg) + # creates a coordinate system, empty graph
  geom_point(mapping = aes(x = displ, y = hwy)) # adds a layer of points to your plot

## 3.2.4 Exercises
### 1. Run ggplot(data = mpg). What do you see? empty graph
ggplot(data = mpg)

### 2. How many rows are in mpg? How many columns?
dim(mpg) # rows: 234, columns: 11

### 3. What does the drv variable describe? Read the help for ?mpg to find out.
?mpg # drv: f = front-wheel drive, r = rear wheel drive, 4 = 4wd

### 4. Make a scatterplot of hwy vs cyl.
ggplot(data = mpg) + geom_point(mapping = aes(x = hwy, y = cyl))

### 5. What happens if you make a scatterplot of class vs drv? Why is the plot not useful?
ggplot(data = mpg) + geom_point(mapping = aes(x = class, y = drv)) # (class vs drv)

## 3.3 Aesthetic mappings

?aes
## Aesthetic mappings describe how variables in the data are mapped 
## to visual properties (aesthetics) of geoms. Aesthetic mappings can 
## be set in ggplot2() and in individual layers.

###You can add a third variable, like class, 
###to a two dimensional scatterplot by mapping it to an aesthetic

### diffenent display by change aesthetic
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = class))
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, size = class))
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, alpha = class))
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, shape = class))

## 3.3.1 Exercises
### 1. What’s gone wrong with this code? Why are the points not blue?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))
#### Need to put color attribute outside the aes()
### Because the color argument was set within aes(), not geom_point()
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

### 2. Which variables in mpg are categorical? Which variables are continuous?
### (Hint: type ?mpg to read the documentation for the dataset). 
### How can you see this information when you run mpg?
str(mpg)
#### Categorical: manufacturer, model, trans, drv, fl, class
#### Continuous: displ, cyl, cty, hwy

### 3. Map a continuous variable to color, size, and shape. 
### How do these aesthetics behave differently for categorical vs. continuous variables?
#### color:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = cty))

#### shape:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = cty))
#### Error: A continuous variable can not be mapped to shape

#### size: 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = cty))

### 4. What happens if you map the same variable to multiple aesthetics?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = manufacturer, size = manufacturer))

### 5. What does the stroke aesthetic do? What shapes does it work with? 
### (Hint: use ?geom_point)
#### To modify the width of the border
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class, stroke = 5))

### 6. What happens if you map an aesthetic to something other than a variable name,
### like aes(colour = displ < 5)? Note, you’ll also need to specify x and y.
#### If use aes(color = displ < 5), then aesthesic will do the logical test
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))

## 3.4 Common problems

### step 1: Find and check syntex error
### step 2: Use ?<function_name>
### step 3: Read the error message
### step 4: Googling the error message

## 3.5 Facets
### One way to add additional variables is with aesthetics. 
### Another way, particularly useful for categorical variables, 
### is to split your plot into facets, subplots that each display one subset of the data.

### To facet your plot by a single variable, use facet_wrap()
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

### To facet your plot on the combination of two variables, use facet_grid()
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_grid(drv ~ cyl)

# 3.5.1 Exercises
## 1. What happens if you facet on a continuous variable?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl)) + 
  facet_wrap(~ displ)
### Your graph will not make much sense. R will try to draw a separate facet 
### for each unique value of the continuous variable. If you have too many unique values, 
### you may crash R.

## 2. What do the empty cells in plot with facet_grid(drv ~ cyl) mean? How do they relate to this plot?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl)) + 
  facet_grid(drv ~ cyl)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = drv, y = cyl, color = drv)) 
### empty cells mean that there are no relation between drv and cyl. no 4 cylinders with rear wheel drive

## 3. What plots does the following code make? What does . do?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
### display the plot on the horizontal and/or vertical direction
### . acts a placeholder for no variable


## 4. Take the first faceted plot in this section:
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)
  
## What are the advantages to using faceting instead of the colour aesthetic? 
### Faceting splits the data into separate grids and better visualizes 
### trends within each individual facet.

## What are the disadvantages? 
### disadvantage is that by doing so, it is harder to visualize the overall relationship across facets. 

## How might the balance change if you had a larger dataset?
### The color aesthetic is fine when your dataset is small, 
### but with larger datasets points may begin to overlap with one another. 
### In this situation with a colored plot, jittering may not be sufficient 
### because of the additional color aesthetic.

## 5. Read ?facet_wrap. 
## What does nrow do? What does ncol do? 
### nrow and ncol will show the row numbers and column numbers in the split plot

## What other options control the layout of the individual panels? 
### as.table determines the starting facet to begin filling the plot, and dir determines the 
### starting direction for filling in the plot (horizontal or vertical).

## Why doesn’t facet_grid() have nrow and ncol arguments?


## 6. When using facet_grid() you should usually put the variable with 
## more unique levels in the columns. Why?
### This will extend the plot vertically, where you typically have more viewing space. 
### If you extend it horizontally, the plot will be compressed and harder to view.

# 3.6 Geometric objects
## A geom is the geometrical object that a plot uses to represent data. 
## left
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

## right 
ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv, color = drv)) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = drv))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

ggplot(data = mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv), show.legend = FALSE)

## display multiple geoms in the same plot
### local mappings for the each layer
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(mapping = aes(x = displ, y = hwy))

## passing a set of mappings to ggplot()
### global mappings that apply to each geom in the graph
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

## display different aesthetics in different layers
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth()

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = class)) + 
  geom_smooth(data = filter(mpg, class == 'subcompact'), se = FALSE) 

# 3.6.1 Exercises
## 1. What geom would you use to draw a line chart? 
## A boxplot? A histogram? An area chart?
### line chart -> geom_line()
### boxplot -> geom_boxplot()
### histrogram -> geom_histogram()
### area chart -> geom_area()

## 2. Run this code in your head and predict what the output will look like. 
## Then, run the code in R and check your predictions.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

## 3. What does show.legend = FALSE do? What happens if you remove it?
## Why do you think I used it earlier in the chapter?
### show.legend = FALSE, it will set the legend graph unable to see
### If remove it, then the plot will show the legend
  
## 4. What does the se argument to geom_smooth() do?
### Display confidence interval around smooth
  
## 5. Will these two graphs look different? Why/why not?
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth()

ggplot() + 
  geom_point(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_smooth(data = mpg, mapping = aes(x = displ, y = hwy))
### No because they use the same data and mapping settings. 
### The only difference is that by storing it in the ggplot() function, 
### it is automatically reused for each layer.

## 6. Recreate the R code necessary to generate the following graphs.
### (1)
ggplot(data = mpg, mapping = aes(x = displ,  y = hwy)) +
  geom_point() + 
  geom_smooth(se = FALSE)
### (2)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_smooth(mapping = aes(group = drv), se = FALSE)
### (3)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth(se = FALSE)
### (4)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = drv)) + 
  geom_smooth(se = FALSE)
### (5)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(mapping = aes(color = drv)) + 
  geom_smooth(mapping = aes(linetype = drv), se = FALSE)
### (6)
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(color = 'white', size =4) + 
  geom_point(mapping = aes(color = drv))

## 3.7 Statistical transformations
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut))

## bar charts, histograms, and frequency polygons bin your data and 
## then plot bin counts, the number of points that fall in each bin.

## smoothers fit a model to your data and then plot predictions from the model.

## boxplots compute a robust summary of the distribution 
## and then display a specially formatted box.

ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut))

demo <- tribble(
  ~cut,         ~freq,
  "Fair",       1610,
  "Good",       4906,
  "Very Good",  12082,
  "Premium",    13791,
  "Ideal",      21551
)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")

## display a bar chart of proportion, rather than count
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = stat(prop), group = 1))

## use stat_summary(), which summarises the y values for each unique x value
ggplot(data = diamonds) + 
  stat_summary(
    mapping = aes(x = cut, y = depth), 
    fun.ymin = min, 
    fun.ymax = max, 
    fun.y = median
  )

ggplot(data = diamonds, mapping = aes(x = cut, y = depth)) + geom_violin()

# 3.7.1 Exercises
## 1. What is the default geom associated with stat_summary()? 
## How could you rewrite the previous plot to use that geom function 
## instead of the stat function?
### Use "?stat_summary()", you'll find the poperty of default geom is geom_pointrange()
ggplot(data = diamonds) + 
  geom_pointrange (
    mapping = aes(x = cut, y = depth), 
    stat = 'summary', 
    fun.ymin = min, 
    fun.ymax = max, 
    fun.y = median
  )

## 2. What does geom_col() do? How is it different to geom_bar()?
### There are two types of bar charts: geom_bar() and geom_col(). 
### geom_bar() makes the height of the bar proportional to the number of cases 
### in each group (or if the weight aesthetic is supplied, the sum of the weights).
### If you want the heights of the bars to represent values in the data, 
### use geom_col() instead. geom_bar() uses stat_count() by default:
### it counts the number of cases at each x position. 

## 3.  Most geoms and stats come in pairs that are almost always used in concert. 
## Read through the documentation and make a list of all the pairs. 
## What do they have in common?

## 4. What variables does stat_smooth() compute? 
## What parameters control its behaviour?
### by '?stat_smooth' -> find computed variables
### (1) y: predicted value
### (2) ymin: lower pointwise confidence interval around the mean
### (3) ymax: upper pointwise confidence interval around the mean
### (4) se: standard errorS
  
## 5. In our proportion bar chart, we need to set group = 1. Why? 
## In other words what is the problem with these two graphs?
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop..))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop..))
ggplot(data = diamonds) + 

### If we fail to set group = 1, the proportions for each cut are calculated 
### using the complete dataset, rather than each subset of cut.
ggplot(data = diamonds) + 
 geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop.., group = 1))

# 3.8 Position adjustments
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, color = cut))

ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = cut))

## The stacking is performed automatically by the position adjustment 
## specified by the position argument. 
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity))

## position = "identity"
ggplot(data = diamonds, mapping = aes(x = cut, fill = clarity)) + 
  geom_bar(alpha = 1/5, position = 'identity')

ggplot(data = diamonds, mapping = aes(x = cut, color = clarity)) +
  geom_bar(fill = NA, position = 'identity')
## The identity position adjustment is more useful for 2d geoms, l
## ike points, where it is the default

## position = "fill"
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = clarity), position = 'fill')

## position = "dodge"
ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut ,fill = clarity), position = 'dodge')

## position = "jitter"
### It adds a small amount of random variation to the location of each point, 
### and is a useful way of handling overplotting caused by discreteness in smaller datasets.
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), position = 'jitter')
## To learn more about a position adjustment, 
## look up the help page associated with each adjustment: 
?position_dodge
?position_fill
?position_identity
?position_jitter
?position_stack

# 3.8.1 Exercises
## 1. What is the problem with this plot? How could you improve it?
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point()

### Many of the data points overlap
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_point(position = 'jitter')

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()

## 2. What parameters to geom_jitter() control the amount of jittering?
### width and height

## 3. Compare and contrast geom_jitter() with geom_count().
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_jitter()

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) + 
  geom_count()
### This is a variant geom_point() that counts the number of observations at each location,
### then maps the count to point area. It useful when you have discrete data and overplotting.

## 4. What’s the default position adjustment for geom_boxplot()? 
## Create a visualisation of the mpg dataset that demonstrates it.
?geom_boxplot
### The default position is 'dodge2'
ggplot(data = mpg, mapping = aes(x = class, y = hwy, color = drv)) + 
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = manufacturer, y = hwy, color = manufacturer)) + 
  geom_boxplot()

# Coordernate systems
## coord_flip(): switches the x and y axes.
##  if you want horizontal boxplots. It’s also useful for long labels: 
## it’s hard to get them to fit without overlapping on the x-axis.
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip() # switch the x and y axes

## coord_quickmap(): sets the aspect ratio correctly for maps
if(!require(maps)) install.packages('maps')
library(maps)

nz <- map_data("nz")

ggplot(data = nz, mapping = aes(x = long, y = lat, group = group)) + 
  geom_polygon(fill = 'white', color = 'black')

ggplot(data = nz) + 
  geom_polygon(mapping = aes(x = long, y = lat, group = group), fill = 'white', color = 'black')

ggplot(data = nz, mapping = aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = 'white', color = 'black') +
  coord_quickmap()

## coord_polar(): uses polar coordinates. Polar coordinates reveal an interesting 
## connection between a bar chart and a Coxcomb chart.
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE, 
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()

# 3.9.1 Exercises
## 1. Turn a stacked bar chart into a pie chart using coord_polar().
ggplot(data = mpg) + 
  geom_bar(mapping = aes(x = class, y = stat(count), fill = model)) + 
  coord_polar()

ggplot(data = mpg, mapping = aes(x = factor(1), fill = class)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y")

## 2. What does labs() do? Read the documentation.
?labs() 
### adds labels to the graph. You can add a title, subtitle, 
### and a label for the xand y axes, as well as a caption.

## 3. What’s the difference between coord_quickmap() and coord_map()?
?coord_map
?coord_quickmap
### coord_map projects a portion of the earth, which is approximately 
### spherical, onto a flat 2D plane using any projection defined 
### by the mapproj package. Map projections do not, in general, 
### preserve straight lines, so this requires considerable computation.
### coord_quickmap is a quick approximation that does preserve straight lines. 
### It works best for smaller areas closer to the equator.
  
## 4. What does the plot below tell you about the relationship between city and highway mpg? 
## Why is coord_fixed() important? What does geom_abline() do?
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

?coord_fixed
?geom_abline

### The relationships is approximately linear, though overall cars have slightly better 
### highway mileage than city mileage. But using coord_fixed(), the plot draws equal 
### intervals on the x and y axes so they are directly comparable. 
### geom_abline() draws a line that, by default, has an intercept of 0 and slope of 1. 
### This aids us in our discovery that automobile gas efficiency is on average slightly
### higher for highways than city driving, though the slope of the relationship
### is still roughly 1-to-1.

# 3.10 The layered grammar of graphics

## ggplot(data = <DATA>) + 
##    <GEOM_FUNCTION>(
##      mapping = aes(<MAPPINGS>),
##      stat = <STAT>, 
##      position = <POSITION>
##    ) +
##    <COORDINATE_FUNCTION> +
##    <FACET_FUNCTION>

## 1. Begin with the diamonds data set.
## 2. Compute counts for each cut value with stat_count().
## 3. Repressent each observation with a bar.
## 4. Map the fill of each bar to the ..count.. variable.
## 5. Place geoms in cartesian coordinate systems.
## 6. Map the y value to ..count.. and the x value to cut.


ggplot(data = diamonds) + 
  stat_count(mapping = aes(x = cut, fill = cut))

# ---------------------------------------------------------------------------------
# 4 Workfolw: basics
# https://r4ds.had.co.nz/workflow-basics.html

# 4.1 Coding basics
## calculator
1 / 200 * 30

(59 + 73 + 2) / 3

sin(pi / 2)

## Create new objects with <-:
## object_name <- value
## assignment operator's short cut: " Alt + - "
x <- 3 * 4

# 4.2 What's in a name?
## Object names must start with a letter, 
## and can only contain letters, numbers, _ and .
## If you want to have a descriptive variable's name, 
## this book recommand separate lowercase words with _ .
## e.g: i_use_snake_case, And_aFew.People_RENOUNCEconvention

this_is_a_really_long_name <- 2.5

# 4.3 Calling functions
## function_name(arg1 = val1, arg2 = val2, ...)
seq(1, 10)

y <- seq(1, 10, length.out = 5)
## This common action can be shortened by surrounding the assignment with parentheses, 
## which causes assignment and “print to screen” to happen.
(y <- seq(1, 10, length.out = 5))

# 4.4 Practice
# 1. Why does this code not work?
my_variable <- 10
my_varıable
#> Error in eval(expr, envir, enclos): object 'my_varıable' not found

## not my_var ı able, instead is my_var i able.

# 2. Tweak each of the following R commands so that they run correctly:
library(tidyverse)

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

fliter(mpg, cyl = 8)
filter(diamond, carat > 3)

## filter(mpg, cyl == 8)
## filter(diamonds, carat > 3)

# 3. Press Alt + Shift + K. What happens? 
# How can you get to the same place using the menus?
## In the tool bar, help > keyboard shortcuts help

# ---------------------------------------------------------------------------------
# 5 Data transformation
## 5.1 Introduction
### in this chapter, which will teach you how to transform your data using 
### the dplyr package and a new dataset on flights departing New York City in 2013.

# 5.1.1 Prerequisites
library(nycflights13)
library(tidyverse)
## Take careful note of the conflicts message that’s printed when you load the tidyverse. 
## It tells you that dplyr overwrites some functions in base R

# 5.1.2 nycflights13
flights
?flights

## noticed the row of three (or four) letter abbreviations under the column names. 
## int stands for integers
## dbl stands for doubles, or real numbers
## chr stands for character vectors, or strings
## dttm stands for date-times(a date + a time)
## lgl stands for logical, vectors that contain only TRUE or FALSE
## fctr stands for factors, which R uses to represent categorical variables with fixed possible values
## date stands for dates

## 5.1.3 dplyr basics
## Pick observations by their values( filter() )
## Reorder the rows( arrange() )
## Pick variables by their names( select() )
## Create new variables with functions of existing variables( mutate() )
## Collapse many values down to a single summary( summaries() )

## These can all be used in conjunction with group_by() which changes the scope of 
## each function from operating on the entire dataset to operating on it group-by-group

## 1. The first argument is a data frame.
## 2. he subsequent arguments describe what to do with the data frame, 
##    using the variable names (without quotes).
## 3. The result is a new data frame.

# 5.2 Filter rows with filter()
## select all flights on January 1st
filter(flights, month == 1, day == 1)

jan1 <- filter(flights, month == 1, day == 1)

## prints out the results and saves them to a variable by wrap the assignment in paratheses
(dec25 <- filter(flights, month == 12, day == 25))

# 5.2.1 Comparisons
## R provides the standard suite: >, >=, <, <=, != (not equal), and == (equal).

filter(flights, month = 1)
### Error: `month` (`month = 1`) must not be named, do you need `==`?

sqrt(2) ^ 2 == 2 # FALSE
1 / 49 * 49 == 1 # FALSE

## Computers use finite precision arithmetic
near(sqrt(2) ^ 2, 2)
near(1 / 49 * 49, 1)

# 5.2.2 Logical operators
## Boolean operators: 
## & is “and”
## | is “or”
## ! is “not”. 

filter(flights, month == 11 | month == 12)
## short-hand
(nov_dec <- filter(flights, month %in% c(11, 12)))

## De Morgan’s law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y. 
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120 | dep_delay <= 120)

# 5.2.3 Missing values
## NA: not availables
## NA represents an unknown value so missing values are “contagious”: 
## almost any operation involving an unknown value will also be unknown.

NA > 5
## 10 == NA
NA + 10
NA / 2
## NA == NA 

# # Let x be Mary's age. We don't know how old she is.
# x <- NA
# 
# # Let y be John's age. We don't know how old he is.
# y <- NA
# 
# # Are John and Mary the same age?
# x == y
# #> [1] NA
# # We don't know!

## If you want to determine if a value is missing, use is.na():
is.na(x)

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)

filter(df, is.na(x) | x > 1)

# 5.2.4 Exercises
## 1. Find all flights that
## (1) Had an arrival delay of two or more hours
## (2) Flew to Houston (IAH or HOU)
## (3) Were operated by United, American, or Delta
## (4) Departed in summer (July, August, and September)
## (5) Arrived more than two hours late, but didn’t leave late
## (6) Were delayed by at least an hour, but made up over 30 minutes in flight
## (7) Departed between midnight and 6am (inclusive)

### (1) 
filter(flights, arr_delay >= 120)

### (2)
filter(flights, dest %in% c('IAH', 'HOU')) 
filter(flights, dest == 'IAH' | dest == 'HOU')

### (3)
filter(flights, carrier %in% c('UA', 'AA', 'DL'))
filter(flights, carrier == 'UA' | carrier == 'AA' | carrier == 'DL')

### (4)
filter(flights, month %in% 7:9)
filter(flights, month == 7 | month == 8 | month == 9)
filter(flights, month >= 7 & month <= 9)

### (5)
filter(flights, arr_delay >= 120 & dep_delay <= 0) 
filter(flights, arr_delay >= 120, dep_delay <= 0)
### (6)
filter(flights, arr_delay >= 60, dep_delay - arr_delay >= 30)

### (7)
filter(flights, dep_time %in% 0:600)
filter(flights, dep_time >= 0, dep_time <= 600)

## 2. Another useful dplyr filtering helper is between(). 
## What does it do? Can you use it to simplify the code needed to 
## answer the previous challenges?
?between
### It is a shortcut for finding observation between two values
filter(flights, month >= 7, month <= 9)
filter(flights, between(month, 7, 9))

## 3. How many flights have a missing dep_time? What other variables are missing? 
## What might these rows represent?
filter(flights, is.na(dep_time))
### They are also missing values for arrival time and departure/arrival delay. 
### Most likely these are scheduled flights that never flew.

## 4. Why is NA ^ 0 not missing? Why is NA | TRUE not missing? 
## Why is FALSE & NA not missing? Can you figure out the general rule?
## (NA * 0 is a tricky counterexample!)
### (1) NA ^ 0 - by definition anything to the 0th power is 1.
### (2) NA | TRUE - as long as one condition is TRUE, the result is TRUE. By definition, TRUE is TRUE.
### (3) FALSE & NA - NA indicates the absence of a value, so the conditional expression ignores it.
### (4) In general any operation on a missing value becomes a missing value. 
### Hence NA * 0 is NA. In conditional expressions, missing values are simply ignored.

# Arrange rows with arrange()
## arrange() works similarly to filter() except that instead of selecting rows, it changes their order. 
arrange(flights, year, month, day)

## Use desc() to re-order by a column in descending order:
arrange(flights, desc(dep_delay))

## Missing values are always sorted at the end:
df <- tibble(x = c(5, 2, 5, 6, 3, NA))
arrange(df, x);arrange(df, desc(x))

# 5.3.1 Exercises
## 1. How could you use arrange() to sort all missing values to the start? 
## (Hint: use is.na()).
arrange(flights, !is.na(dep_delay))

## 2. Sort flights to find the most delayed flights. 
## Find the flights that left earliest.
arrange(flights, desc(arr_delay))
arrange(flights, dep_delay)

## 3. Sort flights to find the fastest flights.
arrange(flights, desc(distance / air_time))

## 4. Which flights travelled the longest? Which travelled the shortest?
arrange(flights, desc(distance))

arrange(flights, distance)

# 5.4 Select columns with select()
## select() allows you to rapidly zoom in on a useful subset using operations 
## based on the names of the variables.

### select columns by name
select(flights, year, month, day)

### select columns between year and day (inclusive)
select(flights, year:day)

### select all columns except those from year to day(inclusive)
select(flights, -(year:day))

## There are a number of helper functions you can use within select():
### 1. starts_with('abc'): matches names that begin with 'abc'.
### 2. ends_with("xyz"): matches names that end with “xyz”.
### 3. contains("ijk"): matches names that contain “ijk”. Contains a literal string
### 4. matches("(.)\\1"): selects variables that match a regular expression. 
###    This one matches any variables that contain repeated characters. 
### 5. num_range("x", 1:3): matches x1, x2 and x3

## select() can be used to rename variables, but it’s rarely useful 
## because it drops all of the variables not explicitly mentioned. 
## Instead, use rename(), which is a variant of select() that keeps 
## all the variables that aren’t explicitly mentioned:
rename(flights, tail_num = tailnum)

## everything() is useful if you have a handful of variables you’d like to 
## move to the start of the data frame.
select(flights, time_hour, air_time, everything())

# 5.4.1 Exercises
## 1. Brainstorm as many ways as possible to select dep_time, dep_delay, 
##    arr_time, and arr_delay from flights.

select(flights, dep_time, dep_delay, arr_time, arr_delay)

time_delay <- c('dep_time', 'dep_delay', 'arr_time', 'arr_delay')
select(flights, time_delay)

select(flights, starts_with('dep'), starts_with('arr'))

## 2. What happens if you include the name of a variable multiple times 
##    in a select() call?

select(flights, dep_time, dep_time)
### It's included only a single time in the new data frame

## 3. What does the one_of() function do? Why might it be helpful 
##    in conjunction with this vector?
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
  
select(flights, one_of(vars))
### one_of(): Matches variable names in a character vector.
### If you use this helper to select the variables that do not exist, 
### you'll get a warning message tell you no this variable, 
### but the other variables will still create a new data frame without error!

### contrast
test_var <- c('abc', 'month', 'day')
select(flights, test_var) # Error: Unknown column `abc` 
select(flights, one_of(test_var)) # Warning message: Unknown columns: `abc` 

## 4. Does the result of running the following code surprise you? 
## How do the select helpers deal with case by default? How can you 
## change that default?
select(flights, contains("TIME", ignore.case = FALSE))

# 5.5 Add new variables with mutate()
## mutate(): add new columns that are functions of existing columns

flights_sml <- select(flights, 
                      year:day, 
                      ends_with('delay'),
                      distance, 
                      air_time
                      )

mutate(flights_sml, 
       gain = dep_delay - arr_delay,
       speed = distance / air_time * 60
       )

## you can refer to columns that you’ve just created:
mutate(flights_sml,
       gain = dep_delay - arr_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
       )

## If you only want to keep the new variables, use transmute(): 
transmute(flights, 
          gain = dep_delay - arr_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours
          )

# 5.5.1 Useful creation functions
## mutate(): The key property is that the function must be vectorised: 
## it must take a vector of values as input, 
## return a vector with the same number of values as output. 

## 1. Arithmetic operators: +, -, *, /, ^
## 2. Modular arithmetic: %/% (integer division) and %% (remainder), 
##    where x == y * (x %/% y) + (x %% y).
##    Modular arithmetic is a handy tool because it allows you to break integers up into pieces. 
transmute(flights, 
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100
          )
## 3. Logs: log(), log2(), log10(). Logarithms are an incredibly useful transformation for 
##    dealing with data that ranges across multiple orders of magnitude.
## 4. Offsets: lead() and lag() allow you to refer to leading or lagging values. 
##    This allows you to compute running differences (e.g. x - lag(x)) or 
##    find when values change (x != lag(x)). They are most useful in conjunction with group_by(), 
##    which you’ll learn about shortly.
(x <- 1:10)

lag(x)
lead(x)

x - lag(x)
x != lag(x)
## 5. Cumulative and rolling aggregates: 
##    R provides functions for running sums, products, mins and maxes: 
##    cumsum(), cumprod(), cummin(), cummax(); and dplyr provides cummean() for 
##    cumulative means. If you need rolling aggregates 
##    (i.e. a sum computed over a rolling window), try the RcppRoll package.
x
cumsum(x)
cummean(x)

## 6. Logical comparisons, <, <=, >, >=, !=, and ==.
## 7. Ranking: there are a number of ranking functions, 
##    but you should start with min_rank().
##    The default gives smallest values the small ranks; 
##    use desc(x) to give the largest values the smallest ranks.
y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))

row_number(y)
dense_rank(y)
percent_rank(y)
cume_dist(y)
### https://stats.stackexchange.com/questions/34008/how-does-ties-method-argument-of-rs-rank-function-work

# 5.5.2 Exercises

## 1. Currently dep_time and sched_dep_time are convenient to look at, 
##    but hard to compute with because they’re not really continuous numbers. 
##    Convert them to a more convenient representation of number of minutes since midnight.
### (1)
transmute(flights, 
          dep_time = (dep_time %/% 100 * 60) + dep_time %% 100,
          sched_dep_time = (sched_dep_time %/% 100 * 60) + sched_dep_time %% 100
          )
### (2)
trans_time <- function(x) {
  return((x %/% 100 * 60) + x %% 100)
}
transmute(flights, 
          dep_time = trans_time(dep_time),
          sched_dep_time = trans_time(sched_dep_time)
          )

## 2. Compare air_time with arr_time - dep_time. What do you expect to see? 
## What do you see? What do you need to do to fix it?
(flight2 <- select(flights, air_time, arr_time, dep_time))
mutate(flight2, air_time_new = arr_time - dep_time)

## 3. Compare dep_time, sched_dep_time, and dep_delay. 
## How would you expect those three numbers to be related?
select(flights, dep_time, sched_dep_time, dep_delay)  
### dep_delay = dep_time - sched_dep_time

## 4. Find the 10 most delayed flights using a ranking function. 
## How do you want to handle ties? Carefully read the documentation for min_rank().
mutate(flights, most_delay = min_rank(desc(arr_delay))) %>% 
  arrange(most_delay)

## 5. What does 1:3 + 1:10 return? Why?
1:3 + 1:10
### 2  4  6  5  7  9  8 10 12 11
### element_wise
### If one parameter is shorter than the other, 
### it will be automatically extended to be the same length.


## 6. What trigonometric functions does R provide?
??trigonometric
cos(x)
sin(x)
tan(x)

acos(x)
asin(x)
atan(x)
atan2(y, x)

cospi(x)
sinpi(x)
tanpi(x)

# 5.6 Grouped summaries with summaries()
## summarise(): It collapses a data frame to a single row:
summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
mean(flights$dep_delay, na.rm = TRUE)

## summarise() is not terribly useful unless we pair it with group_by()
## This changes the unit of analysis from the complete dataset to individual groups. 
## Then, when you use the dplyr verbs on a grouped data frame they’ll be automatically applied “by group”. 
by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

## Together group_by() and summarise() provide one of the tools that 
## you’ll use most commonly when working with dplyr: grouped summaries.

## 5.6.1 Combining multiple operations with the pip

### explore the relationship between the distance and average delay for each location
by_dest <- group_by(flights, dest)
delay <- summarise(by_dest, 
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE)
                   )
delay <- filter(delay, count > 20, dest != 'HNL')

ggplot(data = delay, mapping = aes(x = dist, y = delay)) + 
  geom_point(aes(size = count), alpha = 1/3) + 
  geom_smooth(se = FALSE)

### There are three steps to prepare this data:
#### 1. Group flights by destinations.
#### 2. Summarise to compute distance, average delay, and number of flights.
#### 3. Filter to remove noisy points and Honolulu airport, which is almost 
####    twice as far away as the next closest airport.

## This code is a little frustrating to write because we have to give 
## each intermediate data frame a name, even though we don’t care about it. 
## Naming things is hard, so this slows down our analysis.
## There’s another way to tackle the same problem with the pipe, %>%:

delay <- flights %>% 
  group_by(dest) %>% 
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>% 
  filter(count > 20, dest != 'HNL')

# 5.6.2 Missing values
## If we don't set na.rm = TRUE, then we'll get a lot of missing values.
## Because of aggregation functions obey the ususal rule of missing values.

### contrast
flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

flights %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay, na.rm = TRUE))

## In this case, where missing values represent cancelled flights
not_cancelled <- flights %>% 
  filter(!is.na(dep_delay), !is.na(arr_delay))

### not_cancalled2 <- flights %>% filter(!(is.na(dep_delay) | is.na(arr_delay)))

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(mean = mean(dep_delay))

# 5.6.3 Counts
## Whenever you do any aggregation, it’s always a good idea to include either 
## a count (n()), or a count of non-missing values (sum(!is.na(x)))
delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay)
  )
ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

delays <- not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(
    delay = mean(arr_delay, na.rm = TRUE), 
    n = n()
  )

ggplot(data = delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

delays %>% 
  filter(n > 25) %>% 
  ggplot(mapping = aes(x = n, y = delay)) + 
  geom_point(alpha = 1/10)

## Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

batters <- batting %>% 
  group_by(playerID) %>% 
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )

batters %>% 
  filter(ab > 100) %>% 
  ggplot(mapping = aes(x = ab, y = ba)) + 
  geom_point() + 
  geom_smooth(se = FALSE)

batters %>% 
  arrange(desc(ba))

# 5.6.4 Useful summary functions
## 1. Measures of location: we’ve used mean(x), but median(x) is also useful.

not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0]) # the average positive delay
  )

## 2. Measures of spread: sd(x), IQR(x), mad(x)
### # Why is distance to some destinations more variable than to others?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(distance_sd = sd(distance)) %>% 
  arrange(desc(distance_sd))

## 3. Measures of rank: min(x), quantile(x, 0.25), max(x)
### # When do the first and last flights leave each day?
not_cancelled %>% 
  group_by(year ,month, day) %>% 
  summarise(
    first = min(dep_time), 
    last = max(dep_time)
  )

## 4. Measures of position: first(x), nth(x, 2), last(x)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )

### complementary to filtering on ranks
not_cancelled %>% 
  group_by(year, month, day) %>% 
  mutate(r = min_rank(desc(dep_time))) %>% 
  filter(r %in% range(r))

## 5. Counts: You’ve seen n(), which takes no arguments, and returns the size of the current group. 
##    To count the number of non-missing values, use sum(!is.na(x)).
##    To count the number of distinct (unique) values, use n_distinct(x).
### Which destinations have the most carriers?
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(carriers = n_distinct(carrier)) %>% 
  arrange(desc(carriers))

### Counts are so useful that dplyr provides a simple helper if all you want is a count:
not_cancelled %>% 
  count(dest)

not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n = n())

### You can optionally provide a weight variable. For example, 
### you could use this to “count” (sum) the total number of miles a plane flew:
not_cancelled %>% 
  count(tailnum, wt = distance)

## 6. Counts and proportions of logical values: sum(x > 10), mean(y == 0)
### When used with numeric functions, TRUE is converted to 1 and FALSE to 0. 
### This makes sum() and mean() very useful: sum(x) gives the number of TRUEs in x, 
### and mean(x) gives the proportion.

### How many flights left before 5am? (these usually indicate delayed
### flights from the previous day)
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(n_early = sum(dep_time < 500))

### What proportion of flights are delayed by more than an hour?
not_cancelled %>% 
  group_by(year, month, day) %>% 
  summarise(hour_perc = mean(arr_delay > 60)) %>% 
  arrange(desc(hour_perc))

# 5.6.5 Grouping by multiple variables
## When you group by multiple variables, each summary peels off one level of the grouping. 
## That makes it easy to progressively roll up a dataset:
daily <- group_by(flights, year, month, day)
(per_day <- summarise(daily, flights = n()))

(per_month <- summarise(per_day ,flights = sum(flights)))

(per_year <- summarise(per_month, flights = sum(flights)))

# 5.6.6 Ungrouping
## If you need to remove grouping, and return to operations on ungrouped data, use ungroup()
daily %>% 
  ungroup() %>% # no longer grouped by date
  summarise(flights = n()) # all flights

# 5.6.7 Exercises
## 1. Brainstorm at least 5 different ways to assess the typical delay characteristics of 
##    a group of flights. Consider the following scenarios:
### (1) A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
### (2) A flight is always 10 minutes late.
### (3) A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.
### (4) 99% of the time a flight is on time. 1% of the time it’s 2 hours late.
## (5) Which is more important: arrival delay or departure delay?

### (1)
flights %>% 
  group_by(flight) %>% 
  summarise(
    early_15_min = sum(arr_delay <= -15, na.rm = TRUE) / n(),
    late_15_min = sum(dep_delay >= 15, na.rm = TRUE) / n()
    ) %>% 
  filter(early_15_min == 0.5, late_15_min == 0.5)
### (2)
flights %>% 
  group_by(flight) %>% 
  summarise(
   late_10_min = sum(arr_delay == 10, na.rm = TRUE) / n()
  ) %>% 
  filter(late_10_min == 1)
### (3)
flights %>% 
  group_by(flight) %>% 
  summarise(
    early_30_min = sum(arr_delay <= -30, na.rm = TRUE) / n(),
    late_30_min = sum(dep_delay >= 30, na.rm = TRUE) / n()
  ) %>% 
  filter(early_30_min == 0.5, late_30_min == 0.5)
### (4)
flights %>% 
  group_by(flight) %>% 
  summarise(
    on_time = sum(arr_delay == 0, na.rm = TRUE) / n(),
    late_two_hour = sum(arr_delay >= 120, na.rm = TRUE) / n()
  ) %>% 
  filter(on_time == .99, late_two_hour == .01)
### (5)
### It's depends on the customer.
flights %>% 
  group_by(year) %>% 
  summarise(
    mean_arr_delay = mean(arr_delay, na.rm = TRUE),
    mean_dep_delay = mean(dep_delay, na.rm = TRUE)
  )
### But the average of arrival delay and departure delay is 6.9 and 12.6,
### maybe we can find solution to reduce the rate of departure delay.

## 2. Come up with another approach that will give you the same output as not_cancelled %>% 
##    count(dest) and not_cancelled %>% count(tailnum, wt = distance) (without using count()).

not_cancelled <- flights %>% 
  filter(!is.na(arr_delay) & !is.na(dep_delay))

### (1)
### original
not_cancelled %>% 
  count(dest)
### new
not_cancelled %>% 
  group_by(dest) %>% 
  summarise(n = n() )

### (2)
### original
not_cancelled %>% 
  count(tailnum, wt = distance)
### new
not_cancelled %>% 
  group_by(tailnum) %>% 
  summarise(n = sum(distance, na.rm = TRUE))

## 3. Our definition of cancelled flights (is.na(dep_delay) | is.na(arr_delay) ) is slightly 
##    suboptimal. Why? Which is the most important column?
### There are no flights which arrived but did not depart, so we can just use !is.na(dep_delay).
flights %>% 
  filter(!is.na(dep_delay) & !is.na(arr_delay)) %>% 
  summarise(n = n())

flights %>% 
  filter(!is.na(arr_delay)) %>% 
  summarise(n = n())

## 4. Look at the number of cancelled flights per day. Is there a pattern? 
##    Is the proportion of cancelled flights related to the average delay?
flights %>% 
  group_by(year, month, day) %>% 
  summarise(cancelled = sum(is.na(arr_delay)))
flights %>% 
  group_by(year, month, day) %>% 
  filter(is.na(arr_delay)) %>% 
  count()

flights %>% 
  group_by(year, month, day) %>% 
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE), 
    prop_cancell = sum(is.na(arr_delay)) / n()
  )

## 5. Which carrier has the worst delays? Challenge: can you disentangle the effects of 
##    bad airports vs. bad carriers? Why/why not? (Hint: think about flights %>% 
##    group_by(carrier, dest) %>% summarise(n()))
### the worst delay
flights %>% 
  group_by(carrier) %>% 
  summarise(mean_delay = sum(arr_delay, na.rm = TRUE) / n()) %>% 
  arrange(desc(mean_delay))

flights %>% 
  group_by(carrier) %>% 
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>% 
  arrange(desc(mean_delay))

### Challenge





## 6. What does the sort argument to count() do. When might you use it?











# ---------------------------------------------------------------------------------
# 6 Workflow: scripts





# ---------------------------------------------------------------------------------
# 7 Exploratory Data Analysis





# ---------------------------------------------------------------------------------
# Workflow: projects





