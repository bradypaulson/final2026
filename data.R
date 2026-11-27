library(readr)
library(dplyr)
library(tidyr)
library(zoo)

url <- "https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv"
#replace missing values
df <- read_csv(
  url,
  skip = 1,
  na = c("***", ""),
  col_types = cols(.default = col_double()),
  show_col_types = FALSE
)

#annual data
annual_df <- df |>
  select(Year, Anomaly = `J-D`) |>
  drop_na(Anomaly) |>
  mutate(
    Rolling = rollmean(Anomaly, k = 5, fill = NA, align = "right")
  )
#monthly data
months <- month.abb

monthly_df <- df |>
  select(Year, all_of(months)) |>
  pivot_longer(
    cols = all_of(months),
    names_to = "Month",
    values_to = "Anomaly"
  ) |>
  drop_na(Anomaly) |>
  mutate(
    Month = factor(Month, levels = months),
    Year = as.integer(Year)
  ) |>
  arrange(Year, Month)

#summary numbers 
latest <- slice_tail(annual_df, n = 1)
warmest <- slice_max(annual_df, Anomaly, n = 1, with_ties = FALSE)