-- Nashville housing clean-up project
-- Author: Rian Kuffo
-- Tools:  Excel, PostgreSQL (pgAdmin 4), Tableau
-- Source: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data


--  This script performs exploratory analysis on the cleaned Nashville Housing dataset.
--  The setup (nashville_housing_set-up.sql) and cleaning script (nashville_housing_clean-up.sql) should be run before this analysis.





--  Key areas of analysis:


--  1. Overall average sale price


SELECT ROUND(AVG(sale_price), 0) AS avg_sale_price
FROM nashville_housing;





--  2. Average sale price by land use category


SELECT land_use,
    COUNT(*) AS sales,
    ROUND(AVG(sale_price), 0) AS avg_sale_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sale_price) AS median_sale_price
FROM nashville_housing
GROUP BY land_use
ORDER BY avg_sale_price DESC;




--  3. Transaction volume by tax district


SELECT tax_district,
       COUNT(*) AS transactions,
       ROUND(AVG(sale_price), 0) AS avg_sale_price
FROM nashville_housing
GROUP BY tax_district
ORDER BY transactions DESC;




--  4. Vacancy discount


SELECT sold_as_vacant,
       COUNT(*) AS sales,
       ROUND(AVG(sale_price), 0) AS avg_sale_price
FROM nashville_housing
GROUP BY sold_as_vacant;




