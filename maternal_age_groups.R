# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)
library(MetBrewer)

# Load data from file 2023birthregistrations.xlsx from sheet "Table_10" and start read the data from the sixth row
maternalAge <- readxl::read_excel("2023birthregistrations.xlsx", sheet = "Table_10", skip = 5)

# ======================================= Data Pre-Processing =======================================

# Select rows where country is "England, Wales and Elsewhere" and parent is "Mother"
# and year is greater than or equal to "2014"
maternalAge <- maternalAge %>% filter(Country == "England, Wales and Elsewhere" & Parent == "Mother" & Year >= 2014)

# Drop the columns for country, parent and age-specific fertility rate
maternalAge <- maternalAge %>% select(-Country, -Parent, -`Age-specific fertility rate`)

# Update data type for column "Number of live births" to numeric
maternalAge <- maternalAge %>% mutate(across(3, as.numeric))

# Sort the value in age group column from youngest to oldest
maternalAge$`Age group (years)` <- factor(maternalAge$`Age group (years)`, levels = c(
	"Under 20",
	"20 to 24",
	"25 to 29",
	"30 to 34",
	"35 to 39",
	"40 and over"
))
maternalAge <- maternalAge[order(maternalAge$`Age group (years)`, maternalAge$`Year`),]

# Calculate the mean number of live births for each age group
meanMaternalAge <- maternalAge %>%
	group_by(`Age group (years)`) %>%
	summarise(Mean = mean(`Number of live births`, na.rm = TRUE))

# ======================================= Data Visualisation =======================================

# Generate cycle plot and show the mean with green horizontal line
ggplot(maternalAge, aes(Year, `Number of live births`)) +
	geom_hline(
		data = meanMaternalAge,
		aes(yintercept = Mean),
		color = "#00ba38",
		size = 1.3,
		alpha = 0.7
	) +
	geom_line(
		aes(
			x = Year,
			y = `Number of live births`,
			color = `Age group (years)`
		),
		size = 1
	) +
	geom_point(
		data = maternalAge %>%
			group_by(`Age group (years)`) %>%
			slice_max(Year),
		aes(x = Year, y = `Number of live births`, color = `Age group (years)`),
		shape = 16, size = 3.5
	) +
	geom_area(
		aes(
			x = Year,
			y = `Number of live births`,
			fill = `Age group (years)`
		),
		alpha = 0.06
	) +
	facet_grid(~`Age group (years)`) +
	labs(
		title = "Number of live births (2014-2023) by age group of mothers",
		x = "Age Group (years)",
		y = "Number of Live Births"
	) +
	scale_x_continuous(breaks = seq(2014, 2023, 9)) +
	scale_color_met_d(name = "Troy") +
	scale_fill_met_d(name = "Troy") +
	theme_minimal() +
	theme(
		legend.position = "none",
		panel.spacing = unit(0.3, "lines"),
		panel.grid.major.x = element_line(color = "grey", size = 0.55),
		panel.grid.minor.y = element_blank(),
		plot.title = element_text(face = "bold", size = 20, hjust = 0.5, margin = margin(b = 20)),
		strip.text.x = element_text(face = "bold", size = 14),
		axis.title.x = element_text(size = 18, margin = margin(t = 15)),
		axis.text.x = element_text(face = "bold", size = 12, angle = 90, hjust = 1),
		axis.title.y = element_text(size = 19, margin = margin(r = 10)),
		axis.text.y = element_text(face = "bold", size = 12),
		plot.margin = margin(l = 20, r = 20, b = 10, t = 25)
	)
