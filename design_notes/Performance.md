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

# Improvements and Future Directions

* Do corrections to the longitude and latitude roundings to make sure that they respect the geometry of the Earth (km/longitude-degree is not constant as we assumed)
* Consider a proper SQL scheme to process the entire data, not just for Poland
* Consider using the fastverse suite of packages (collapse, kit, matrixStats, data.table) if you need much faster statistical and matrix calculations 