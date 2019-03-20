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