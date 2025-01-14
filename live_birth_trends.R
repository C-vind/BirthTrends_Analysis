# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)

# Load data from file 2023birthregistrations.xlsx from tab "Table_12" and start read the data from the sixth row
dailyLiveBirths <- read_excel("2023birthregistrations.xlsx", sheet = "Table_12", skip = 5)

# ======================================= Data Pre-Processing =======================================

# Remove the column for years before 10 years ago
dailyLiveBirths <- dailyLiveBirths %>% select(3:12)

# Handle missing values by replacing all value of "[z]" with "0"
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(everything(), ~str_replace(., "\\[z\\]", "0")))

# Convert all data to numeric class
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(everything(), as.numeric))

# Calculate the total number of live births for each year
yearlyLiveBirths <- dailyLiveBirths %>% summarise(across(everything(), sum))

# Reorder the column name descendingly from 2023 to 2014
yearlyLiveBirths <- yearlyLiveBirths[, order(colnames(yearlyLiveBirths), decreasing = TRUE)]

# Create new table to store the data of 2014 and 2023
# The data will be used later on to draw an arrow from 2014 to 2023
x <- c(colnames(yearlyLiveBirths)[10], colnames(yearlyLiveBirths)[1])
y <- c(yearlyLiveBirths[[10]], yearlyLiveBirths[[1]])
slopeChartData <- data.frame(Year = x, LiveBirths = y)

# Transform the structure to table with two columns: Year and LiveBirths
yearlyLiveBirths <- yearlyLiveBirths %>%
	pivot_longer(cols = everything(), names_to = "Year", values_to = "LiveBirths")

# ======================================= Data Visualisation =======================================

# Generate line chart and show the trends with red arrow
yearlyLiveBirths %>%
	ggplot(aes(x = Year, y = LiveBirths, group = 1)) +
	geom_line(color = "black", linetype = 5) +
	geom_point(shape = 21, colour = "black", fill = "white", size = 4.5, stroke = 1) +
	geom_segment(data = slopeChartData,
		aes(
			xend = ifelse(is.na(lead(Year)), Year, lead(Year)),
			yend = lead(LiveBirths)
		),
		arrow = arrow(type = "closed", length = unit(0.6, "cm")),
		color = "#f8766d", linetype = 1, linewidth = 1.7,
	) +
	labs(
		title = "Yearly number of live births in England and Wales",
		x = "Year",
		y = "Number of Live Births"
	) +
	theme_minimal() +
	theme(
		panel.grid.major.x = element_line(color = "grey95"),
		panel.grid.major.y = element_line(color = "grey90"),
		panel.grid.minor.y = element_line(linetype = 3, color = "grey55"),
		plot.title = element_text(face = "bold", size = 30, hjust = 0.5, margin = margin(b = 15)),
		axis.title.x = element_text(size = 24, margin = margin(t = 15)),
		axis.text.x = element_text(face = "bold", size = 18),
		axis.title.y = element_text(size = 24, margin = margin(r = 20)),
		axis.text.y = element_text(face = "bold", size = 18),
		plot.margin = margin(l = 20, r = 10, b = 15, t = 30)
	)
