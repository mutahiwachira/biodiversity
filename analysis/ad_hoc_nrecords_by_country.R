df <- readr::read_csv("data/dist_by_country.csv")

df |> 
  select(country = 1, count = 2) |> 
  arrange(desc(count))

# The netherlands is the biggest by far

df |> 
  select(country = 1, count = 2) |> 
  arrange(desc(count)) |> 
  mutate(count = count / sum(count))
# the  netherlands accounts for 87 percent of the data!

df |> 
  select(country = 1, count = 2) |> 
  arrange(desc(count)) |> 
  mutate(count = log(count,base = 10) |> round(0)) |> 
  pull(count) |> 
  table()
