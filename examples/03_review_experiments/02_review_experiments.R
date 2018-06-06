
library(lubridate)
library(tidyverse)

# Read in the parsed data
dat <- readRDS("experiment_table.rds")
# Add run_no index
dat <- dat %>% mutate(run_no = 1:nrow(dat))
# Convert collection date & time into a Date object
dat <- dat %>% mutate(time_pt = mdy_hms(paste(collection_date, collection_time)))

#==== Basic data review
# How many rows and columns?
dim(dat)
# Look at the first few rows
head(dat)
# Look at the structure of the data
str(dat)

# How many runs per patient?
dat %>% count(patient)


# How many unique data files? barcodes?
# standard version
length(unique(dat$mzml_file))
# pipe'd version
dat$mzml_file %>% unique %>% length

length(unique(dat$barcode))
dat$barcode %>% unique %>% length


# Plot the scan counts, look for the expected & unexpected
ggplot(dat, aes(run_no, scan_count_tot)) + geom_col()
ggplot(dat, aes(run_no, scan_count_ms1)) + geom_col()
ggplot(dat, aes(run_no, scan_count_ms2)) + geom_col()


# Plot the collection times by patient
# IMPORTANT: mixes dplyr (%>%) & ggplot2 (+)
# prepare the data with dplyr
dat %>% 
  group_by(patient) %>% 
  arrange(time_pt) %>%
  mutate(patient_sample_no = 1:length(mzml_file)) %>% 
  # The plotting part, now use + instead of %>%
  ggplot(aes(time_pt, patient_sample_no, color = patient)) + 
  geom_line() +
  geom_point()

