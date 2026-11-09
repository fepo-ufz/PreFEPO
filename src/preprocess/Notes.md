# Some notes about the data:

- In some cases, the scientist install different traps, in a small regions. Some of these traps include the
sand flies and some of them not. It means we will have the same environmental situation but the target values are different.
These play a negative role in the model performance like a noise.

- We should know in months 1,2, (even 3), and 12 in all European countries, the temperature is low and the sand flies are not active.
However, is some place on the middle east or south of Turkey, the temperature is high and the sand flies are active.
In many case the scientist don't provide the data for these months.

- In some case, the scientist provide zero values for the target values in all month of years. 
In this situation we will have a coordinate with all zero in target variable for a specific species.
- Why they have done this, because they want to say that species is not available in that region, but this routing is not common in all region.

- Based on Yoni explained, in some dataset like Vector net and Bulgaria, the scientist provide a survey for wide region.
- It means that their work was a large survey, focused on characterizing species distribution in various habitats, including just a few samples in every location.
such these dataset act a as a noice in a training dataset.


- If for each coordinate and species we have just one observation (for example lat_1, lon_1, spec_code_1, we have one records wth dst > 0 ) it is wierd, 
and can be a sign on servey study dataset.
- check coordinate one by one and species differently. it should have semi seasonal data, for example for each coordinate, 
spec_code and year it should have at least 3 points of data.
- and then we can add some zero values for 1, 2, 12
- we con focus on just 3 species and just based on reliable datasets.


# Top level regulations
1. Correct data types
   - start and end dates, should be simple and uniform, like 2020-01-01
   - latitude and longitude should be numeric with 4 digits after the point.
     - in some case latitude and longitude are greater than 90 and 180, we should divide them by 1000 .
   - All numeric columns should be numeric with 4 digits after the point.
2. We work on some species that identify by Eduardo. It is included 14 different species.
   - We uniform the species name based on the Eduardo tables and if the specie names are 'others' then we remove them.
3. If region code and species are not match with the Eduardo table, we remove them.
4. If zero values of number_of_collected are in the middle of active months, we remove them.
5. We cover three different collecting methods, LT (Light Trap), SP (Stick Paper), HC (Hand Collection), OTH (Others).
   - In some case we have LT, CDC, CO2, LST, LTCO2 and so on, all of these collection method we be assumed as LT.
   - After this transformation of collecting method we should aggregate
6. We removed all NA values in the dst column.
    - We should be sure that these columns are not NA in the dataset.
    - "latitude", "longitude", "collecting_methods", "start_date", "number_of_collected"
    - for the collecting_methods, we should remove the NA values if collecting_methods is only LT.
7. We should uniform the Sex F/M. 
8. We should check the start and end date, in some cased we should swap them.
   - If the duration of sampling is more than 10 days, we remove them.
   - If start date and end date are the same, we add one day to the end date.
9. We should check the duration of sampling, if it is more than 10 days, we remove them.
10. Check unique coordinate should be inside of water and also the NUTS name should be reasonable.
11. All records should be grouped by:
    - grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species")
    - And then we should get the maximum values of the dst for each group.


- Remove all records include NA in coordinates, collecting_number, collection methods
- If the all record for a specific species in a specific coordinate is zero
  - We check the record with Eduardo Map, if there is not in the map we should remove and else we can keep it as an absent data
- The zero value inside of activity season should be removed.
  - It means zero in months 5-10 should be removed.
  - we can add zero values for 1, 2, 12 (because the sand flies are not active in these months in Europe)
- If we have a coordinates that all values are zero it should be removed.
- All records should be group by
  - grp_key <- c("latitude", "longitude", "collecting_methods", "start_date", "end_date", "number_of_trap", "sex", "species")
  - And then we should get the maximum values of the dst for each group.
   
- I think mots of the time the scientists did not like to install a trap where the sand flies are not available.
  - Thus all of records are some how of presence of sand flies, not absence.
  - If they had a empty trap, the microclimate situations were not suitable for sand flies.
  - Or they did not install a trap in that proper place.
  - As a consequence of this, we can remove all zero values in dst column. and in another words, the zero values play a role of noisy data.



# Question
- We remove turkey from EDNEXT and use just turkey
- We should do tye same for others like French, portugal, and so on?
- 