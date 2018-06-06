
# Location and listing of the files
mzml_dir <- "/Users/rwbenz/Clients/SCBI/20171201_DBS_20Samples/mzML"
mzml_names <- list.files(mzml_dir, pattern = "\\.mzML$")


# Function to plot a spectrum
plot_spectrum <- function(spec_num, ms_mode, peak_data) {
  if (length(spec_num) == 0) {
    return(NULL)
  }
  
  if (spec_num < 1 | spec_num > length(peak_data)) {
    stop("Spectrum number is out of range")
  }
  
  spec <- peak_data[[spec_num]]
  spec <- as.data.frame(spec)
  names(spec) <- c("mz", "abundance")
  
  ttl <- paste0("MS", ms_mode , " Spectrum #", spec_num, "")
  ggplot(spec) +
    geom_segment(aes(x = mz, xend = mz, y = 0, yend = abundance)) +
    xlab("m/z") +
    ylab("Abundance") +
    ggtitle(ttl)
}