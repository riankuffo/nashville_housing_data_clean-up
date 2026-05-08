# Nashville Housing Data Clean-Up & EDA


Business Question:

What factors most influence residential sale prices in Nashville, and what patterns emerge across property type, tax district, and vacancy status?


Dataset:

Source: [Nashville Housing Data](https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data)

Domain: Residential and commercial real estate transactions, Nashville, Tennessee.

Raw row count: 56,636 records

Cleaned row count: 55,949 records


Tools:

Excel,
PostgreSQL (pgAdmin 4),
Tableau Public.


Data Cleaning Summary:
The raw dataset required standardization before analysis could begin. 

The following steps were taken:


Null handling and removal:

Identified 159 null values in the property_address column and 30,619 in the owner address field.
Filled in 16 null property addresses by matching parcel_id where a duplicate row contained the missing information.
Remaining nulled property addresses were removed as the information could not be recovered from the dataset.


Address standardization:

Corrected 27 property addresses beginning with zero by replacing them with the corresponding owner address where street names matched.
Corrected two owner addresses that begin with zero, using the corresponding property address.
Removed leading and extra whitespaces using TRIM().
Replaced consecutive whitespaces with single spaces using REGEXP_REPLACE(property_address, '\s+', ' ', 'g').
Corrected 30 property addresses missing street numbers by replacing them with the owner's address.


Duplicate removal:

Identified and removed duplicate rows using ROW_NUMBER() partitioned by parcel_id, property_address, sale_price, legal_ref, and sale_date
Used the CTID as the primary key for deletion since the dataset's ID column was not distinct due to previous restoration attempts.
Removed all remaining property addresses that began with zero that could not be corrected

The result of these steps was 687 rows removed through cleaning. This is a reduction of 1.2% from the raw dataset, preserving 55,949 clean records for analysis.


Key Findings:
1. Average sale price
The overall average sale price across all 55,949 cleaned records was $327,500. This will serve as the baseline benchmark for all property comparisons.
2. Vacant commercial land commands the highest prices
Vacant commercial land had the highest average sale price at $3,235,294. This reflects a premium placed on undeveloped commercial zones in the Nashville real estate market.
3. Vacant zoned multi-family is the most accessible entry point
At an average sale price of $12,000, vacant zoned multi-family land represents the lowest-costing property category in the dataset.
4. Urban Services District drives the most transaction volume
The Urban Services District recorded the highest number of property sales of all tax districts in the dataset. This alludes to it being the most active real estate market in Nashville.
5. Vacant properties sell at a $22,594 discount
Properties sold as vacant transacted at an average discount of $22,594 compared to occupied properties. This is a 6.9% reduction relative to the overall average sale price.


Business Recommendation:
Three independent patterns emerged: vacant multi-family is the cheapest category citywide. Vacant commercial commands the highest premiums (ten times the benchmark). Urban Services District drives the most volume across all categories. Buyers seeking value should investigate vacant multi-family parcels as district-level pricing within that category warrants further analysis.


Dashboard:
This includes exploratory data analysis visualizations about this topic in Tableau Public.
To view, please click [here](https://public.tableau.com/app/profile/rian.kuffo/viz/NashvilleHousingExploratoryDataAnalysis/NashvilleHousingDashboard?publish=yes).
