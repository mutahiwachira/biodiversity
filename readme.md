# Introduction

The purpose of this app is to assist in preserving the biodiversity of Poland and countries around the world. It uses data from [https://observation.org](observation.org). This data includes a record of what species were observed when and where by crowdsourcing from various people.

The original request was to build a dashboard which would allow users to see these observations visually, and to search for species in a clean, intuitive and simple way. The two primary visualisations requested were 
* a map which would plot observations of species in a particular area
* a time based plot to display the count of species over time, rather than space

In preparing the basic plot, several issues related to the performance, presentability, utility and data-design of the app came up. This document serves to explain the design choices made in the design of the app, with several ad-hoc notes being stored under the folder 'Design Choices'. Each section also includes recommendations for future work moving forward.

# Data Understanding

The requirements given requested plots of the observations in particular areas or in particular times, broken down by species. 

This was delivered by first aggregating up several of the records by species. This was done because each record in the original dataframe includes a variable `individualCount` and so one record does not equal just one observation. Plotting the default data would be inaccurate, and an aggregating step was also necessary. Data was also aggregated spatially - by binning observations near each other together. This again reflects an extension of the structure of the underlying data. Not every data point had the same accuracy, but by appropriately rounding off all the longitudes and latitudes, a clean, aggregated dataset was obtained. Finally, data was aggregated to the monthly level, with all dates being rounded down to the first of the month. See the Rmarkdown document [on data preparation](analysis/Data%20Preparation.Rmd).

There are serious problems with the requirement in terms of the stated goal of the project. If the goal is to preserve biodiversity, you have to take into account the following:

* number of species in an area (known as species richness in ecology) is probably more important than the count of individuals of a given species
* in terms of preserving species, we actually want to emphasize species, locations, and periods of time were the number of observations is small or falling. Plotting the observations as they are, aggregated or raw, actually dilutes and hides those species which are rare are losing population, which are the very species we care the most about. But plotting the inverse or negative of counts is not visually intuitive either.
* counts of species are, by their nature, small numbers with a fairly small distribution. Usually single digit observations, even when aggregated. Time series of small counts with large gaps between them do not look good visually. And the actual numerical value of the count tells you much less about species rarity because most species are rare and will only be osberved so often.

Here are some recommendations to improve the app:

* Use a formal [metric of diversity](https://en.wikipedia.org/wiki/Diversity_index) to score regions in terms of their biodiversity, and highlight this in a separate plot which is more focused on regional decision makers. Metrics like the [relative species abundance](https://en.wikipedia.org/wiki/Relative_species_abundance) have been designed to include both information about number of individuals and number of species to score the biodiversity of an ecosystem.
* For a given species, calculate a rarity score based on the average time between observations. A species is in danger if it is becoming rarer and rarer for there to be sightings of that species. This way, even if at each sighting an observer stumbles upon a small family of individuals, for example, it is the rarity of any sighting at all, rather than the naive count, which denotes rarity.
    * Negative binomial regression, or poisson regression, would represent the full formal theory of such an approach. But simply calculating the time between successive observations may well get you far enough.
    * include a an element at the foot of the dashboard which presents the rarity scores of species based on this metric, to add greater context to what is seen
    * Seasonality should be taken into account. Some species will not be observed during certain times of the year at all, so perhaps some analyses should restrict themselves to periods of the year where animals are not, for example, hibernating or migrating out.
* Another valuable metric would be geographic spread. Species which are highly or uniquely concentrated in one area should be considered particularly sensitive, even if their counts are fairly high.
* Several general improvement can be made to make the dashboard more powerful for exploring purposes
    * The time plot should allow users to select a time range, and the map should allow users to select a geographic bound, and these two visual filters should filter the underlying data and impact each other
    * Some jitter should be added to the spatial data to prevent overplotting, where two records overlap and one does not see the underlying one clearly. In the current implementation, transparency was used to achieve a similar effect, but a more careful design of the plotting element on the map could go further.
* Finally, linking back to the original dataset in the dashboard would be useful, because it gives users somewhere to go and something to do to get more information.

# App Performance

The original data as received was approximately 20GB in size. This was far to big to fit into memory and run the dashboard efficiently. Various scripts and Rmarkdown files in the 'analysis' folder will show the calculations and investigations that were performed regarding app performance. The following was found about the original dataset:

* There were many columns which were superfluous to the work at hand, and of these columns some included redundant information (around the ID of each observation). By selecting only the most important columns, the size of the dataset was decreased.
* Aggregation of rows, as described in the previous section, also reduced the size of the data substantially.
* It was found that the Netherlands accounts for 85% of the data by size. This is significant for users of the data who are not in the Netherlands as it suggests even the full data may be manageable if all the Netherlands' rows were removed. They were kept in the current dataset.

Removing of columns and aggregating of rows was sufficient enough such that for all countries except the Netherlands, the data was manipulable in-memory in R without a noticeable delay.

In addition to reducing the size of the data, the following design choices were made to improve performance and user experience:
* The data are loaded from a SQLite database which is queried with a simple filter for country.     
    * The table in this database is `occurence_processed` and it represents the result of applying the aforementioned aggregations on the data. The SQLite database is under 2GB in total, but also includes files from a second dataset `multimedia` which includes links to multimedia useful in making the app more visual. Currently, all data processing except for the original read and filter by country is done in-memory in R.
* For the spatial plot, counts are aggregated over time. This ensures we don't plot 5 circles on top of each other representing 5 different observations in time at the exact same place, when obviously a spatial plot doesn't even represent time. The reverse applies for the time plot.
* As much of the calculation as possible was done in the backend, out of shiny, in R functions, so as to speed up the app. 

Here are some recommendations to help in generalizing the app such that we can load even more of the data at once (e.g. for a truly global analysis):

* Query optimization could provide for very effective views which would make diverse and rich tables available to R for viewing. A SQL expert could assist to write better views.
* The *fastverse* suite of tools in R, including the packages `collapse`, `data.table`, `kit` and `matrixStats` provide tools for very fast, in-memory processing of data if statistical calculations become important (e.g. for the rarity index mentioned under 'Data Understanding').
* No explicit use was made of the caching capacity in Shiny, aside from the fact that Shiny only recalculates a reactive if an upstream dependency has invalidated, and the only upstream dependency which triggers a re-quering of the database is a change in country. More advanced tools in shiny, like `bind_cache` could speed up the performance of the app.
* A dedicated backend process could be established in R which could continuously analyse the data and then cache results to make available to the front-end. The calculation would be done in a process entirely separate from the shiny process, and prevent it from slowing down. This has been done in instances where live data is needed, but it could find some uses here. A thorough exploratory analysis involving hundreds of potential connections could be designed to run over time, and whenever useful connections are uncovered, the results are cached for future use.

# UI/UX and JavaScript interactivity

## CSS
The app relies on the basic theming facilities of R Shiny.

A single custom component, main_box, was designed to organize the content on the front-page.

Some minor CSS adjustments were included, although there are issues with how this was done as I don't have the most experience when it comes to CSS.

Much improvement could be made by adopting a systematic and informed CSS/SASS redesign of the app.

## JavaScript

One button in the app, the settings button which is supposed to provide an interactive way to allow users to change the country and then hide that selector since it is usually not needed, still has some issues associated with it due to reactivity.

This needs to be improved, perhaps by removing it from the module entirely and relying on shinyjs, which is an excellent package but doesn't seem to play well with modules.

HTMLwidgets, plotly and leaflet provide many opportunities for more sophisticated interactive experience. Their full features should be reviewed and alternatives to these (like dygraphs or, indeed, plotly itself as an alternative to leaflet) may be in order.

## Personalization

Since the app is setup with a database already, it should be relatively simple to write information back to the database. Users should be able to save and bookmark their various filters. In the present form of the app, that may not be so useful, but if the app were to go into production, feature requests would eventually yield a subset of features that benefit heavily from personalization.

Locale based personalization would be more important. The app is more intuitive if it starts in the country where the individual is located. In addition, animals are often known by common names in a local language. At the very least, localization of the common names in the database would improve usability of the app.

## Multimedia

In order to highlight each individual species and it's threats better, multimedia content like pictures of the species should be included in the app. These are available in the database, although various joins may be necessary to extract a set of images for each species.

The ideal way to deploy this is together with the 'species richness' metrics. A bootstrap carousel at the bottom of the page could show images of each species together with species specific facts which speak more to the danger faced by the animal: a rarity index, average time between sightings, geographic spread or niche status...

# Deployment

The app was deployed to an AWS Ubuntu server with 30 GB of disk space and 8GB of memory. Access to the server is controlled and I am in posession of the private key to SSH into the server. HTTPS and a custom domain have not yet been set up.

Docker was used to enclose the application state, with the `rocker/shinyverse` and `rocker/tidyverse` packages being used to include Shiny Server Open Source and RStudio Server Open Source respectively.

`renv` was used to keep track of the libraries used in the project, but this was not included directly in the Dockerfile. So the design of the app is three quarters of the way to full reproducibility. However, the packages used were included statically and packaged together. See [mutahiwachira/biodiversity](https://hub.docker.com/repository/docker/mutahiwachira/biodiversity) for a docker container including Shiny Server and the packages needed for this project as at (27th June).

Please email me for the credentials for Rstudio Server, which can be useful for testing on the server.

Improving the deployment process of the project would involve
* Setting up a proper HTTPS configuration on the server, and purchasing a custom domain, and implementing a web server like NGINX to manage requests and possibly do load balancing.
* Developing a CI/CD pipeline such that changes push to Github are pulled through to update the app if they pass automated unit checks
* Including `renv` in the Dockerfile as per the `renv` [documentation](https://rstudio.github.io/renv/articles/docker.html), so that the Docker reads `renv` to better manage the packages included in the container.

# Unit Testing and Documetation

While every effort was made to program defensively and informatively, full unit testing has not yet been written for each function.

In the near future, `testthat`, `roxygen2` and other similar packages may be useful to improve the reliability of the app.

Data validation is particularly important since most of the data is entered by humans. The Appsilon `data.validator` package could be useful in this regard.

Mark van der Loo's packages `tinytest` and `validate` are also two good, lightweight options for doing unit testing and data validation respectively.

-----

Please email me at mutahi.wachira@gmail.com with any questions.