# ======================================= Load Libraries and Data =======================================

# Import required libraries
library(tidyverse)
library(readxl)
library(forecast)
library(Metrics)
library(ggtext)

# Load data from file 2023birthregistrations.xlsx from tab "Table_12" and start read the data from the sixth row
dailyLiveBirths <- read_excel("2023birthregistrations.xlsx", sheet = "Table_12", skip = 5)

# ======================================= Data Pre-Processing =======================================

# Handle missing values by replacing all value of "[z]" with "0"
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(everything(), ~str_replace(., "\\[z\\]", "0")))

# Convert live births data across all years to numeric class
dailyLiveBirths <- dailyLiveBirths %>% mutate(across(3:31, as.numeric))

# Aggregate the data by month
monthlyLiveBirths <- dailyLiveBirths %>%
	group_by(Month) %>%
	summarise(across(2:30, sum))

# Sort the value in month column appropriately
monthlyLiveBirths$Month <- factor(monthlyLiveBirths$Month, levels = c(
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
))
monthlyLiveBirths <- monthlyLiveBirths[order(monthlyLiveBirths$Month),]

# Transpose the monthly data to matrix
monthlyLiveBirthsMatrix <- t(monthlyLiveBirths)

# Put the first row value as column name
colnames(monthlyLiveBirthsMatrix) <- monthlyLiveBirthsMatrix[1,]

# Remove first row
monthlyLiveBirthsMatrix <- monthlyLiveBirthsMatrix[-1,]

# Convert all values in the matrix to numeric
monthlyLiveBirthsMatrix <- apply(monthlyLiveBirthsMatrix, 2, as.numeric)

# Adjust the row names accordingly
rownames(monthlyLiveBirthsMatrix) <- colnames(monthlyLiveBirths[2:30])

# Sort the row names by year (ascendingly)
monthlyLiveBirthsMatrix <- monthlyLiveBirthsMatrix[order(row.names(monthlyLiveBirthsMatrix)),]

# Set the first 26 years as train data
monthlyLiveBirthsTrain <- monthlyLiveBirthsMatrix[1:26,]

# Set the last 3 years as test data
monthlyLiveBirthsTest <- monthlyLiveBirthsMatrix[27:29,]

# ======================================= Time-Series Forecasting =======================================

# Convert the train data to time series object
monthlyLiveBirthsTrainTS <- ts(monthlyLiveBirthsTrain, frequency = 12)
monthlyLiveBirthsTrainTS <- ts(as.vector(t(monthlyLiveBirthsTrainTS)), start = 1995, frequency = 12)

# Convert the test data to time series object
monthlyLiveBirthsTestTS <- ts(monthlyLiveBirthsTest, frequency = 12)
monthlyLiveBirthsTestTS <- ts(as.vector(t(monthlyLiveBirthsTestTS)), start = 2021, frequency = 12)

# Create model based on Triple Exponential Smoothing (TES) / Holt-Winters method
tesModel <- HoltWinters(monthlyLiveBirthsTrainTS)

# Create the forecast object to predict live births in 2021 to 2023
tesForecast <- forecast(tesModel, h = nrow(monthlyLiveBirthsTest) * ncol(monthlyLiveBirthsTest))

# Calculate Mean Absolute Percentage Error (MAPE) and Root Mean Squared Error (RMSE) to evaluate the model
data.frame(
	MAPE = mape(monthlyLiveBirthsTestTS, tesForecast$mean),
	RMSE = rmse(monthlyLiveBirthsTestTS, tesForecast$mean)
)

# Create the forecast object to predict live births from 2024 to 2034
tesFutureForecast <- forecast(tesModel, level = c(95), h = 13 * 12)

# Convert the time index to a numeric year
forecastYears <- as.numeric(time(tesFutureForecast$mean))

# Filter the forecasted values to include only those from 2024 onwards
tesFutureForecast$mean <- tesFutureForecast$mean[forecastYears >= 2024]
tesFutureForecast$lower <- tesFutureForecast$lower[forecastYears >= 2024,]
tesFutureForecast$upper <- tesFutureForecast$upper[forecastYears >= 2024,]

# Update the time index to include only those from 2024 onwards
tesFutureForecast$mean <- ts(tesFutureForecast$mean, start = 2024, frequency = 12)
tesFutureForecast$lower <- ts(tesFutureForecast$lower, start = 2024, frequency = 12)
tesFutureForecast$upper <- ts(tesFutureForecast$upper, start = 2024, frequency = 12)

# Create time series object based on the whole existing monthly live births data
monthlyLiveBirthsTS <- ts(monthlyLiveBirthsMatrix, frequency = 12)
monthlyLiveBirthsTS <- ts(as.vector(t(monthlyLiveBirthsTS)), start = 1995, frequency = 12)

# ======================================= Data Visualisation =======================================

# Generate line chart to compare the actual and predicted test data
plot(tesForecast, main = "", xaxt = "n")
title("Comparison between actual and predicted live births data", cex.main = 2.2)
axis(1, at = seq(1995, 2024, by = 1), las = 2)
lines(tesForecast$mean, col = "#BF2F24", lwd = 2)
lines(monthlyLiveBirthsTestTS, col = "#4a9edf", lwd = 3)
legend(
	"topright",
	cex = 1.2,
	legend = c("Train data", "Actual test data", "Predicted test data"),
	col = c("#000000", "#4a9edf", "#BF2F24"),
	lty = 1,
	lwd = c(2, 3, 3),
	x.intersp = 0.9,
	y.intersp = 0.8,
	text.font = 2,
	text.width = 3.4
)

# Generate line chart to visualize forecast for live birth trends over the next decade
tesFutureForecast %>% autoplot(PI = FALSE) +
	autolayer(tesFutureForecast$mean, series = "Forecast Data", color = "#BF2F24", size = 0.7) +
	autolayer(monthlyLiveBirthsTS, series = "Actual Data", color = "#000000", size = 0.7) +
	geom_point(
		aes(
			x = 2034,
			y = tail(tesFutureForecast$mean, 1),
		),
		shape = 21,
		fill = "#BF2F24",
		size = 4,
		color = "#fbf9f4",
		stroke = 1.5
	) +
	geom_text(
		aes(
			x = 2034,
			y = tail(tesFutureForecast$mean, 1),
			label = round(tail(tesFutureForecast$mean, 1))
		),
		color = "#BF2F24",
		fontface = "bold",
		hjust = -0.3,
		size = 5
	) +
	labs(
		title = "10 Years Forecast of Live Births in England and Wales",
		subtitle = "<b><span style='color:black'>Black line</span></b> indicates actual data.
		<b><span style='color:#BF2F24'>Red line</span></b> indicates predicted data.",
		x = "Year",
		y = "Number of Live Births"
	) +
	scale_x_continuous(
		breaks = seq(2014, 2034, 1),
		limits = c(2014, 2034)
	) +
	coord_cartesian(
		ylim = c(40000, 61000)
	) +
	theme_minimal() +
	theme(
		panel.grid.major.x = element_line(color = "grey95"),
		panel.grid.major.y = element_line(color = "grey90"),
		panel.grid.minor.y = element_line(linetype = 3, color = "grey55"),
		plot.title = element_text(face = "bold", size = 26, hjust = 0, margin = margin(b = 15)),
		plot.subtitle = element_markdown(size = 18, hjust = 0, margin = margin(b = 15), color = "grey32"),
		axis.title.x = element_text(size = 20, margin = margin(t = 20)),
		axis.text.x = element_text(face = "bold", size = 14, angle = 90, hjust = 1),
		axis.title.y = element_text(size = 20, margin = margin(r = 15)),
		axis.text.y = element_text(face = "bold", size = 14),
		plot.margin = margin(l = 20, r = 0, b = 15, t = 35)
	)