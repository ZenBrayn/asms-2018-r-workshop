
library(mzR)
library(tidyverse)

cat("This example will not work without the underlying data used in the example
  (not distributed here due to file size).  The code is provided here for reference.\n")
stop("End user needs to supply a directory of mzML files; specify in data_dir below; further
  code modifications will need to be made depending on the structure of your data.")

# Directory where the mzML files are located
data_dir <- "/Users/rwbenz/Clients/SCBI/20171201_DBS_20Samples/mzML"
mzml_files <- list.files(data_dir, pattern = "\\.mzML$")
# External information related to the underlying samples
ext_info <- read_csv("external_info.csv")

# Data parsing function to be applied to each file
parse_experiment <- function(mzml_file_path) {
  # Extract the run number from the file name
  file_name <- basename(mzml_file_path)
  barcode_id <- str_match(file_name, pattern = "^.+-([0-9]+)\\.mzML")[,2] %>%
    as.numeric()
  
  # Extract the high-level run information
  msdat <- openMSfile(mzml_file_path, backend = "pwiz")
  run_info <- runInfo(msdat)
  
  # Extract scan header information
  hdr <- header(msdat)
  n_ms1 <- as.numeric(table(hdr$msLevel)["1"])
  n_ms2 <- as.numeric(table(hdr$msLevel)["2"])
  
  # convert to a tibble
  run_info <- tibble(barcode_id = barcode_id,
                     scan_count_tot = run_info$scanCount,
                     scan_count_ms1 = n_ms1,
                     scan_count_ms2 = n_ms2,
                     low_mz = run_info$lowMz,
                     high_mz = run_info$highMz,
                     start_time = run_info$dStartTime,
                     end_time = run_info$dEndTime,
                     ms_lvls = paste(run_info$msLevels, collapse = ","),
                     time_stamp = run_info$startTimeStamp)
  
  run_info
}

# Create the initial data frame with the file names and file paths
exp_tbl <- tibble(mzml_file = mzml_files,
                  mzml_path = file.path(data_dir, mzml_file))


# Now parse each experiment using the parse_experiment function
# defined above
exp_tbl <- exp_tbl %>%
  mutate(exp_info = map(mzml_path, parse_experiment)) %>%
  # Expand out the results from parse_experiment
  unnest()


# Get the external data ready to merge
# Add in additional external information about the runs
ext_info <- ext_info %>%
  mutate(collection_time = as.character(collection_time),
         barcode_id = str_match(barcode, "([0-9][0-9]$)")[,2] %>% as.numeric())


# Create the final table
exp_tbl <- exp_tbl %>% 
  left_join(ext_info, by = "barcode_id") %>%
  arrange(barcode_id) %>%
  # Remove some unneeded columns
  select(-mzml_path, -low_mz, -high_mz, -ms_lvls, -time_stamp, -barcode_id, -start_time)

saveRDS(exp_tbl, "experiment_table.rds")

