# ANLY 3341 - Assignment 2 (revised)
# Name: Jesse Velasquez
# Save as Lastname_Firstname_Assignment2.R
# Place mbta.xlsx in your working directory. Run from a fresh R session.

library(tidyverse)
library(completejourney)
library(readxl)

# Part 1A / N01: Keep weeks 1-26 and create the three price variables.
transactions <- transactions_sample %>%
  filter(week >= 1 & week <= 26)

transactions <- transactions %>%
  mutate(
    regular_price = (sales_value + retail_disc + coupon_match_disc)/quantity,
    loyalty_price = (sales_value + coupon_match_disc) / quantity,
    coupon_price = (sales_value - coupon_disc) / quantity
  )

n01 <- nrow(transactions)
cat("N01 - Rows in weeks 1-26 before filtering zero quantities:", n01, "\n")

# Part 1B / N02: Inspect non-finite loyalty prices before filtering quantity.
n02 <- sum(!is.finite(transactions$loyalty_price))

# Written answer: identify household(s) and explain the unusual price.

non_finite_households <- transactions %>%
  filter(!is.finite(loyalty_price)) %>%
  select(household_id, quantity, sales_value, loyalty_price)
print("Household(s) with non-finite loyalty_price:")
print(non_finite_households)

#The unusual prices are caused by the rows showing NaN and being considered as returns
#rather than actual item purchases.

# Part 1B / N03: Keep quantity > 0. Find the largest regular price and all ties.
transactions_pos <- transactions %>%
  filter(quantity > 0)

max_reg_price <- max(transactions_pos$regular_price, na.rm = TRUE)

largest_reg_households <- transactions_pos %>%
  filter(regular_price == max_reg_price) %>%
  select(household_id, regular_price, quantity, sales_value)
print("Household(s) with the largest regular_price:")
print(largest_reg_households)

n03 <- max_reg_price
cat("N03 - Largest regular_price after filtering:", sprintf("%.2f", n03), "\n")
# Written answer: identify household(s).
# Household with the largest price after filtering was #1246

# Part 1C / N04-N06: Count distinct products at the $1.50 cutoffs.
n04 <- transactions_pos %>%
  filter(regular_price <= 1.50) %>%
  summarise(n = n_distinct(product_id)) %>%
  pull(n)
cat("N04 - Distinct products with regular_price <= 1.50:", n04, "\n")

n05 <- transactions_pos %>%
  filter(loyalty_price <= 1.50) %>%
  summarise(n = n_distinct(product_id)) %>%
  pull(n)
cat("N05 - Distinct products with loyalty_price <= 1.50:", n05, "\n")

n06 <- transactions_pos %>%
  filter(coupon_price <= 1.50) %>%
  summarise(n = n_distinct(product_id)) %>%
  pull(n)
cat("N06 - Distinct products with coupon_price <= 1.50:", n06, "\n")

# Part 1D / N07-N09: Sum sample baskets, round totals to cents, then compare.
basket_summary <- transactions_pos %>%
  group_by(basket_id) %>%
  summarise(total_sales = round(sum(sales_value, na.rm = TRUE), 2)) %>%
  ungroup()

n07 <- nrow(basket_summary)
cat("N07 - Total baskets in summary:", n07, "\n")

n08 <- mean(basket_summary$total_sales > 15.00)
cat("N08 - Proportion of baskets > $15:", sprintf("%.4f", n08), "\n")

n09 <- mean(basket_summary$total_sales > 25.00)
cat("N09 - Proportion of baskets > $25:", sprintf("%.4f", n09), "\n")
# Written answer: explain the denominator,
# The denominator is the total number of baskets rather than transactions

# Part 2A / N10: List sheets, import data, inspect, count missing values.
sheet_names <- excel_sheets("mbta-1.xlsx")
mbta_raw <- read_excel("mbta-1.xlsx", skip = 1, na = "NA")
print(sheet_names)
str(mbta_raw)
head(mbta_raw, 6)
summary(mbta_raw)
colSums(is.na(mbta_raw))
n10 <- sum(is.na(mbta_raw))
cat("N10 - Missing values in imported table:", n10, "\n")
# Written answer: worksheet name(s).
# Sheet 1

# Part 2B / N11-N12: Remove summaries and row numbers; show dimensions.
mbta_clean <- mbta_raw %>%
  filter(!mode %in% c("All Modes by Qtr", "Pct Chg / Yr", "TOTAL")) %>%
  select(-1)

n11 <- nrow(mbta_clean)
cat("N11 - Rows remaining before pivoting:", n11, "\n")

n12 <- ncol(mbta_clean)
cat("N12 - Columns remaining before pivoting:", n12, "\n")
# Written answer: explain why the three summary rows are removed.
# The three columns were removed to keep them from causing double-counting
# and inaccurate model-level summary statistics 

# Part 2C / N13-N14: Pivot to long form and record dimensions BEFORE splitting.
# Split YYYY-MM into year and month as integers; show the first six rows.
mbta_long <- mbta_clean %>%
  pivot_longer(
    cols = -mode,
    names_to = "date",
    values_to = "thou_riders"
  ) %>%
  separate(date, into = c("year", "month"), sep = "-") %>%
  mutate(
    year = as.integer(year),
    month = as.integer(month),
    thou_riders = as.numeric(thou_riders)
  )

n13 <- nrow(mbta_long)
cat("N13 - Rows in long table:", n13, "\n")

n14 <- ncol(mbta_long)
cat("N14 - Columns in long table:", n14, "\n")

head(mbta_long, 6)
# Part 2D: Locate and correct the confirmed Boat entry error in R.
mbta_long <- mbta_long %>%
  mutate(
    thou_riders = if_else(
      mode == "Boat" & year == 2007 & month == 3 & thou_riders == 40,
      4,
      thou_riders
    )
  )
# Written answer: year, month, original value, and corrected value.
# Confirmed entry error at year = 2007, month = 3 
# Original value = 40
# Corrected value = 4

# Part 2E / N15: Display means for every mode across all available months.
all_month_summary <- mbta_long %>%
  group_by(mode) %>%
  summarise(mean_riders = mean(thou_riders, na.rm = TRUE))
print("All-Month Means by Mode:")
print(all_month_summary)

n15 <- all_month_summary %>% filter(mode == "Bus") %>% pull(mean_riders)
cat("N15 - All-month mean for Bus:", sprintf("%.3f", n15), "\n")

# Part 2E / N16: Display February means for every mode.
february_summary <- mbta_long %>%
  filter(month == 2) %>%
  group_by(mode) %>%
  summarise(mean_riders = mean(thou_riders, na.rm = TRUE))
print("February Means by Mode:")
print(february_summary)

n16 <- february_summary %>% filter(mode == "Heavy Rail") %>% pull(mean_riders)
cat("N16 - February mean for Heavy Rail:", sprintf("%.3f", n16), "\n")
# Part 2E / N17: Compare Boat means using January-October in each year.
boat_year_summary <- mbta_long %>%
  filter(mode == "Boat", month >= 1 & month <= 10, year >= 2007 & year <= 2011) %>%
  group_by(year) %>%
  summarise(mean_riders = mean(thou_riders, na.rm = TRUE)) %>%
  arrange(desc(mean_riders))
print("Boat Jan-Oct Means by Year (2007-2011):")
print(boat_year_summary)

n17 <- boat_year_summary %>% slice_max(mean_riders, n = 1) %>% pull(year)
cat("N17 - Year with largest Jan-Oct Boat mean:", n17, "\n")
# Part 2E / N18-N19: Display Light Rail means for all twelve calendar months.
light_rail_summary <- mbta_long %>%
  filter(mode == "Light Rail") %>%
  group_by(month) %>%
  summarise(mean_riders = mean(thou_riders, na.rm = TRUE)) %>%
  arrange(desc(mean_riders))
print("Light Rail Means by Calendar Month:")
print(light_rail_summary)

n18 <- light_rail_summary %>% slice_max(mean_riders, n = 1) %>% pull(month)
cat("N18 - Calendar month with largest Light Rail mean:", n18, "\n")

n19 <- light_rail_summary %>% slice_max(mean_riders, n = 1) %>% pull(mean_riders)
cat("N19 - Largest calendar-month Light Rail mean:", sprintf("%.3f", n19), "\n")
# Part 2E / N20: Compute the Boat mean for all twelve months of 2009.
n20 <- mbta_long %>%
  filter(mode == "Boat", year == 2009) %>%
  summarise(mean_riders = mean(thou_riders, na.rm = TRUE)) %>%
  pull(mean_riders)
cat("N20 - Mean for Boat across all 12 months of 2009:", sprintf("%.3f", n20), "\n")
# Print answers N01-N20. Apart from basket totals, round final entries only.
(sprintf("N01: %d\n", n01))
cat(sprintf("N02: %d\n", n02))
cat(sprintf("N03: %.2f\n", round(n03, 2)))
cat(sprintf("N04: %d\n", n04))
cat(sprintf("N05: %d\n", n05))
cat(sprintf("N06: %d\n", n06))
cat(sprintf("N07: %d\n", n07))
cat(sprintf("N08: %.4f\n", round(n08, 4)))
cat(sprintf("N09: %.4f\n", round(n09, 4)))
cat(sprintf("N10: %d\n", n10))
cat(sprintf("N11: %d\n", n11))
cat(sprintf("N12: %d\n", n12))
cat(sprintf("N13: %d\n", n13))
cat(sprintf("N14: %d\n", n14))
cat(sprintf("N15: %.3f\n", round(n15, 3)))
cat(sprintf("N16: %.3f\n", round(n16, 3)))
cat(sprintf("N17: %d\n", n17))
cat(sprintf("N18: %d\n", n18))
cat(sprintf("N19: %.3f\n", round(n19, 3)))
cat(sprintf("N20: %.3f\n", round(n20, 3)))
