Issues
* Reducing the size of the data
* Efficient mapping - what does one point on the map represent?
* Faster statistical measures for 
* Optimizations for global data

# Reducing the size of the data

The raw data from source comprises of many superfluous columns which are not relevant to the core analysis.
By selecting just the columns needed, one can avoid having big datasets to deal with

Secondly, the rows need to be aggregated together.
In the first place, each record in the original dataset does not represent a single observation
So to get truly representative data of how many observations were made on a given day in a given place, we have to sum up the counts of individuals observed.

In addition to summing up the counts, many observations can be binned together spatially by rounding of longitudes and latitudes.
Finally, the data can presumably by reduced to monthly observations.

The order of these aggregations should be:
* first transform the longitudes and latitudes
* then truncate the date-time data to be just year-month
* then do the aggregation on the counts, grouping by date, location and species

It's important to note that, in addition to being a performance improvement, this aggregation doesn't actually cause any problems for the visualisation.
The granularity/grain of the data in the first place was never one row = one observation.
If you just plotted multiple observations in the same place (one observation = one row = one point), it would be very much like having a single point where the opacity of it represents the count.
And from a visualisation perspective, even if it was, you would just end up overplotting the same point on itself multiply times.
Again, for points which are very close together, there isn't too much difference between one observation being one point and having, for example, a size variable proportional to the count.
Finally, if you review the Data Understanding notes, you'll see that it isn't necessarily correct to focus on species with higher counts. Briefly, part of preserving biodiversity must include worrying about those species which are rare or declining in population.
Therefore, from both a data understanding and a performance perspective, this primary processing of the raw data is justified.

By selecting columns, reducing rows and aggregating, we can compact the data greatly which is important for a system that could have many simultaneous users.


# Efficient visualisations

Some important rules for doing efficient visualisations:

* Maps do not have a time dimension - so before you plot the data you must make sure to aggregate out the date. It should just be counts by location for a given species or set of species. Don't put 100 points in the same place because it was 100 days worths of recordings (or even 5 points for 5 monthly aggregates).


------

# Potential for Improvement

The overall goal for performance is to be able to load in global data
Initially, this would be providing an option for people to specify the country they want to look at
But in the very long run, it might be useful to work with all the data (perhaps not plotting all of it) so that we can get information within an international context (e.g. birds that migrate between South Africa and Poland are important to know about so that the Polish and South African governments can jointly secure their biodiversity, each one dependent on the other)
These performance enhancements are necessary only toward that end:

* Consider a proper SQL scheme to process the entire data, not just for Poland
* Consider using the fastverse suite of packages (collapse, kit, matrixStats, data.table) if you need much faster statistical and matrix calculations 

## Using a database instead of CSVs

* For a fixed data db, you can create all the tables you want once-off and then just query them with DBI and dbplyr.
* 

## Fastverse

Several packages from the *fastverse* suite of tools present possible opportunities for speeding up what data processing must be done in R/Shiny:
* collapse provides very fast statistical functions
* matrixStats provides powerful matrix operations and calculations; it also reminds us that we don't always have to work with dataframes which are bulky compared to matrices
* data.table provides a massive speed boost for sorting and joining and even for simple calculations it is great because the `:=` operator allows you to modify in place, you just have to be very careful to get the semantics right and not accidentally override important objects. Generally, copy once at the beginning of a function and then within a function use modify-in-place. Try to declare where you are using data.table explicitly, because it's semantics for square brackets are so different to data.frame and this can be a source of confusion.