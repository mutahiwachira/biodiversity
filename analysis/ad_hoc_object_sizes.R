df <- load_polish_sample()

df_sizes <- df |> 
  map(~ format(object.size(.x), units = "Mb")) |> 
  bind_rows() |> 
  pivot_longer(cols = everything()) |> 
  arrange(desc(value))

print(df_sizes, n = 100)

df_sizes |> 
  mutate(value = as.numeric(str_extract(value, "[[:digit:]]+\\.*[[:digit:]]*"))) |> 
  rename(value_mb = value) |> 
  group_by(is_big = value_mb > 1) |> 
  summarise(contribution = sum(value_mb))

df_sizes |> 
  mutate(value = as.numeric(str_extract(value, "[[:digit:]]+\\.*[[:digit:]]*"))) |> 
  rename(value_mb = value) |> 
  group_by(is_big = value_mb > 1) |> 
  filter(name %in% c(
    "eventDate", "country", "scientificName", "vernacularName", "id", "individualCount", "longitudeDecimal", "latitudeDecimal"
  )) |> 
  summarise(contribution = sum(value_mb))

# so the big columns make up about 2/3 of the data's size!
# and it's more or less the same information over and over again
# we could recode it to a big integer and just move on
# We could go to a table of about 6GB instead by just recoding the IDs and removing the other stuff

# the View can be expected to have a size 6/30 = one fifth the size.