
library(broom)
library(tidyverse)

# Load the simulated data
dat <- read_csv("calc_curve_sim_data.csv")

# Review the structure
head(dat)
dat %>% count(analyte)
dat %>% count(analyte, conc)
# Pipe into as.data.frame to get all the columns
dat %>% count(analyte, conc) %>% as.data.frame


# Plot the data
ggplot(dat, aes(conc, response)) +
  geom_point() +
  facet_wrap(~analyte, scales = "free_y")


# Compute summary stats for each analyte & concentration level
sum_stats <- dat %>%
  group_by(analyte, conc) %>%
  summarize(n = length(response),
            mean_resp = mean(response),
            sd_resp = sd(response),
            cv_resp = sd_resp / mean_resp)
sum_stats


# Fit a linear regression for each analyte
# First need to nest the data by analyte
dat %>%
  group_by(analyte) %>%
  nest()

fit_data <- dat %>%
  group_by(analyte) %>%
  nest() %>%
  mutate(
    # build the model
    model = map(data, function(d) lm(response ~ conc, data = d)),
    # Use the broom::tidy function to get the model summary parameters
    model_summary = map(model, tidy),
    # Get the slope and intercept row of the summary
    intr_summary = map(model_summary, function(d) d %>% filter(term == "(Intercept)")),
    slope_summary = map(model_summary, function(d) d %>% filter(term == "conc")),
    # Get the slope and intercept estimates
    intercept = map_dbl(intr_summary, "estimate"),
    slope = map_dbl(slope_summary, "estimate"),
    slope_pval = map_dbl(slope_summary, "p.value"))

# Get a data frame for plotting
plot_df <- fit_data %>%
  select(analyte, data, slope, intercept) %>%
  unnest()

# Plot the data and fit results
ggplot(plot_df, aes(conc, response)) + 
  geom_point() + 
  facet_wrap(~analyte, scales = "free_y") + 
  geom_abline(aes(slope = slope, intercept = intercept))

# Compare with geom_smooth(method = "lm)
ggplot(plot_df, aes(conc, response)) + 
  geom_point() + 
  facet_wrap(~analyte, scales = "free_y") + 
  geom_abline(aes(slope = slope, intercept = intercept)) +
  geom_smooth(method = "lm")
