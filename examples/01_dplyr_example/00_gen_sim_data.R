
library(tidyverse)

set.seed(123456)

analytes <- c("AAA", "BBB", "CCC", "DDD", "EEE", "FFF")
offsets <- c(10, 100, 0.1, 500, 50, 250)
conc_lvls <- c(1, 5, 10, 50, 100)
n_reps <- 3
noise_frac <- 0.10

sim_dat <- map(seq_along(analytes), function(i){
  analyte <- analytes[i]
  offset <- offsets[i]
  
  resp <- map(conc_lvls, function(x) {
    x + rnorm(n_reps, mean = 0, sd = noise_frac * (x+offset))
  }) %>% unlist + offset
  
  tibble(analyte = analyte,
         conc = sort(rep(conc_lvls, n_reps)),
         response = resp)
}) %>% bind_rows()

write.table(sim_dat, "calc_curve_sim_data.csv", row.names = FALSE, sep = ",")


