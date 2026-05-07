-- Nashville housing clean-up project
-- Author: Rian Kuffo
-- Tools:  Excel, PostgreSQL (pgAdmin 4), Tableau
-- Source: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data





--  Step 0: Importing the Nashville housing data from Kaggle. 


--  First, I downloaded the CSV file and imported it into Excel for clean-up.
--  I created a copy of the file to keep a legacy version for reference.
--  I replaced spaces with underscores, and upper case with lower case in the columns.

--  There were two columns removed, one being the Unnamed column, which was replaced with a primary key column.
--  The image column was also removed as its use was unnecessary for this project.

--  I took the liberty of finding the maximum number of characters in each column using the Excel LEN() and MAX() functions. 
--  I used that number for the character varying and numeric data-type columns.
--  I have provided both CSV files in the repository for reference to the changes made.

--  Attached below is the code I used to create the table, 
--  then the code used to import the CSV to the SQL editor pgAdmin. 


-- Table creation query:


CREATE TABLE nashville_housing (
    id integer,
    parcel_id varchar(16),
    land_use varchar(42),
    property_address varchar(31),
    suite varchar(6),
    property_city varchar(14),
    sale_date date,
    sale_price integer,
    legal_ref varchar(17),
    sold_as_vacant varchar(3),
    multi_parcel varchar(3),
    owner_name varchar(60),
    address varchar(30),
    city varchar(14),
    state varchar(2),
    acreage numeric(6,2),
    tax_district varchar(25),
    neighborhood varchar(4),
    land_value integer,
    building_value integer,
    total_value integer,
    finished_area numeric(11,5),
    foundation_type varchar(9),
    year_built smallint,
    ext_wall varchar(12),
    grade varchar(4),
    bedrooms smallint,
    full_bath smallint,
    half_bath smallint
);


--  Importing Nashville housing query example (not the exact file path):


COPY nashville_housing
FROM 'C:\MyDirectory\nashville_housing_copy'
WITH (FORMAT CSV, HEADER);





--  Step 1: Raw imported data preview.


--  I used this select all query to glance over the columns and ensure the data imported correctly.


SELECT *
FROM nashville_housing;


--  I then selected a count of all rows to ensure the total rows matched what was present in the CSV file.


SELECT COUNT(*) AS total_rows
FROM nashville_housing;


--  When glancing over the select all query earlier, I found many nulls. 
--  To determine how many nulls each column contained, I utilized the following query, 
--  taking the total count and subtracting from the total non-null count found in each column: 


SELECT COUNT(*) AS total_rows,
    COUNT(*) - COUNT(parcel_id)           AS null_parcel_id,
    COUNT(*) - COUNT(property_address)    AS null_property_address,
    COUNT(*) - COUNT(sale_date)           AS null_sale_date,
    COUNT(*) - COUNT(sale_price)          AS null_sale_price,
    COUNT(*) - COUNT(legal_ref)           AS null_legal_reference,
    COUNT(*) - COUNT(owner_name)          AS null_owner_name,
    COUNT(*) - COUNT(address)		  AS null_owner_address,
    COUNT(*) - COUNT(acreage)             AS null_acreage,
    COUNT(*) - COUNT(tax_district)        AS null_tax_district,
    COUNT(*) - COUNT(land_value)          AS null_land_value,
    COUNT(*) - COUNT(building_value)      AS null_building_value,
    COUNT(*) - COUNT(total_value)         AS null_total_value,
    COUNT(*) - COUNT(year_built)          AS null_year_built,
    COUNT(*) - COUNT(bedrooms)            AS null_bedrooms,
    COUNT(*) - COUNT(full_bath)           AS null_full_bath,
    COUNT(*) - COUNT(half_bath)           AS null_half_bath
FROM nashville_housing;





--  Step 2: Address string clean-up.


--  Many addresses are null or contain extra spaces, 
--  so the goal of this step will be to standardize their presentation.

--  With the help of the previous query, I know there are 159 nulls present in the property_address column, 
--  and 30,619 nulls in the owner address field.

--  To see if these nulls have duplicates with the missing information present in the table, 
--  I use the following query to test the parcel_id column.


SELECT parcel_id, 
    COUNT(parcel_id) AS parcel_id_duplicates
FROM nashville_housing
GROUP BY parcel_id
HAVING COUNT(parcel_id) > 1
ORDER BY COUNT(parcel_id) DESC;


--  At first glance, there are at most 4 rows with duplicate information per ID.
--  Now that we know there are duplicates in this field, we can potentially use the parcel_id column
--  to fill in information missing from other rows.

--  To do this, I will begin by previewing what can be used to fill in the missing information with the following query.


SELECT a.parcel_id,
    a.property_address      AS missing,
    b.property_address      AS fill_from
FROM nashville_housing AS a
JOIN nashville_housing AS b
    ON  a.parcel_id       = b.parcel_id
    AND a.id      	 <> b.id
WHERE a.property_address IS NULL
AND b.property_address IS NOT NULL;


--  From this query, we can determine there are a total of 16 rows where we can use the parcel_id to match the missing addresses.
--  To update the table with this information, I will first create a backup of the table, then use the following query.


UPDATE nashville_housing AS a
SET property_address = b.property_address
FROM nashville_housing AS b
WHERE a.parcel_id       = b.parcel_id
    AND a.id     	       <> b.id
    AND a.property_address IS NULL
    AND b.propery_address IS NOT NULL;


--  We will then use the following query to see if the missing nulls were updated.


SELECT COUNT(*) AS missing_addresses
FROM nashville_housing
WHERE property_address IS NULL;


--  With the missing addresses at 143, the 16 records were updated successfully.





--  Step 2.1: Property addresses beginning with 0.

--  There are many property addresses beginning with 0, which is likely unintentional.
--  I will check to see if this information can be rectified using the other address field we have. 
--  which is meant to represent owner addresses, the 'address' column.

--  To check if this is possible, I will begin with this query.


SELECT property_address,
    address
FROM nashville_housing
WHERE property_address LIKE '0 %'
    AND address NOT LIKE '0 %'
    AND SUBSTRING(address FROM POSITION(' ' IN address) + 1)
    = SUBSTRING(property_address FROM POSITION(' ' IN property_address) + 1);


--  Upon running this query, it lists 27 instances where this information can be filled in from the owner address field.
--  With this information in hand, I will create a backup of the table, 
--  and begin to update the property address column using the following query.


UPDATE nashville_housing
SET property_address = address
WHERE property_address LIKE '0 %'
    AND address NOT LIKE '0 %'
    AND SUBSTRING(address FROM POSITION(' ' IN address) + 1) 
    = SUBSTRING(property_address FROM POSITION(' ' IN property_address) + 1);


--  With this, we have replaced the address lines beginning with 0 with their correct fields.
--  Looking at this the other way around, however, we discover there are two fields in the owner address column
--  starting with 0, which we can fix with the address in the property address column.

--  To look at this, I use the inverse of the previous SELECT query, 
--  reversing the LIKE and NOT LIKE in the columns in the WHERE statement found in the query below.


SELECT property_address,
    address
FROM nashville_housing
WHERE property_address NOT LIKE '0 %'
    AND address LIKE '0 %'
    AND SUBSTRING(address FROM POSITION(' ' IN address) + 1)
    = SUBSTRING(property_address FROM POSITION(' ' IN property_address) + 1);

--  We find 3 entries, one of which has an invalid replacement. 
--  To fix the other two, I will exclude this entry.
--  I will back up the table again and update the entries with the following query.


UPDATE nashville_housing
SET address = property_address
WHERE property_address NOT LIKE '0 %'
    AND property_address NOT LIKE '  HAD%'
    AND address LIKE '0 %'
    AND SUBSTRING(address FROM POSITION(' ' IN address) + 1) 
    = SUBSTRING(property_address FROM POSITION(' ' IN property_address) + 1);


--  It completed updating the two incorrect entries.
--  As for the invalid entry, I checked to see if there were other entries
--  that would allow us to fill in the missing information; there were no duplicates
--  with the pertinent information.
--  I used the following queries to do so. 


SELECT *
FROM nashville_housing
WHERE id = '9095';

SELECT *
FROM nashville_housing
WHERE parcel_id = '063 12 0 063.00';


--  As the missing information cannot be rectified by use of the table, we will likely cull the entries later. 
--  This is also the case with 57 entries found using the same query without the substrings for matching.
--  Query below for reference.


SELECT property_address,
    address
FROM nashville_housing
WHERE property_address NOT LIKE '0 %'
    AND address LIKE '0 %';





--  Step 2.2: Removing leading and extra spaces.


--  To first preview the entries with leading spaces, I use the following query.


SELECT property_address
FROM nashville_housing
WHERE property_address LIKE ' %';


--  A total of seven records appear. 
--  Only one of these records has a suite or house number attached.
--  To eliminate these leading spaces, I first backup the table then use the query below.


UPDATE nashville_housing
SET property_address = TRIM(property_address);


-- We will also use this for the address column.


UPDATE nashville_housing
SET address = TRIM(address);


--  This has rid us of the trailing spaces, but now we must look at the extra spaces in between the suite number and street lines.
--  To do this, let us first preview the records with this issue using the following query.


SELECT property_address
FROM nashville_housing
WHERE property_address LIKE '%  %'


--  To resolve the extra spaces, I will back up the table, then use the query below.


UPDATE nashville_housing
SET property_address = REGEXP_REPLACE(property_address, '\s+', ' ', 'g');


--  This will capture all whitespace characters exceeding one, and replace them with a singular space.
--  Now we will do the same for the address column.


UPDATE nashville_housing
SET address = REGEXP_REPLACE(address, ' {2,}', ' ');





--  Step 2.3: Property addresses missing house numbers.

--  Glancing through the property addresses, we find many missing their respective street numbers.
--  To rectify, we first discover where there are instances of these missing numbers in the other 'address' column.
--  I previewed this information using the following query.


SELECT property_address, 
    address
FROM nashville_housing
WHERE property_address !~ '^[0-9]'
    AND address ~ '^[1-9]';


--  Upon running the query, we find 30 rows with the missing information present in the address column.
--  I will now back up the table again and use the following query to replace the missing numbers.


UPDATE nashville_housing
SET property_address = address
WHERE property_address !~ '^[0-9]'
    AND address ~ '^[1-9]';





--  Step 3: Remove duplicates.

--  Now that we have utilized duplicated fields for missing information, we can begin to remove them.
--  First, I will preview duplicate rows using the CTE and SELECT query below.


WITH ranked AS (
    SELECT id,
        ROW_NUMBER() OVER (
            PARTITION BY
                parcel_id,
                property_address,
                sale_price,
                legal_ref,
                sale_date
            ORDER BY id
        ) AS row_num
    FROM nashville_housing
)

SELECT COUNT(*) AS duplicate_rows
FROM ranked
WHERE row_num > 1;


--  This query returns a number that is our target for removal, 
--  so by using the following query, we can drop the duplicate rows.


DELETE FROM nashville_housing
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid,
            ROW_NUMBER() OVER (
                PARTITION BY
                    parcel_id,
                    property_address,
                    sale_price,
                    legal_ref,
                    sale_date
                ORDER BY ctid
            ) AS row_num
        FROM nashville_housing
    ) ranked
    WHERE row_num > 1
);





--  Step 3.1: Remove null property addresses

--  We will now remove the null property address rows.
--  To preview this information, I will use the query below.


SELECT * AS null_address_rows
FROM nashville_housing
WHERE property_address IS NULL;


--  To remove these nulls, I will use this query.


DELETE
FROM nashville_housing
WHERE property_address IS NULL;




--  Step 3.2: Remove property addresses beginning with 0.

--  First, we will preview this information with this query.

SELECT *
FROM nashville_housing
WHERE property_address ~ '^[0]';


--  Once we have this information, we will back up the table and use the following query for removal.


DELETE
FROM nashville_housing
WHERE property_address ~ '^[0]';





--  Step 4: Data quality check.

--  Now that we have cleaned the most apparent errors and standardized the address strings,
--  we can begin to glance over the data for quality assurance.

--  I will start with a general count of rows after the cleaning to compare with before.


SELECT COUNT(*) AS final_cleaning_count
FROM nashville_housing;


--  We can also preview the information, using the following query.


SELECT *
FROM nashville_housing
ORDER BY id
LIMIT 20;


--  Take a look at some of the summary statistics as well.


SELECT ROUND(AVG(sale_price), 2)    AS avg_sale_price,
    MIN(sale_price)                 AS min_sale_price,
    MAX(sale_price)                 AS max_sale_price,
    ROUND(AVG(acreage), 4)          AS avg_acre,
    MIN(year_built)                 AS oldest_built,
    MAX(year_built)                 AS newest_built
FROM nashville_housing;


--  And for a final check, we can see how many nulls are present in key columns.


SELECT COUNT(*) - COUNT(property_address)    AS null_property_address,
    COUNT(*) - COUNT(sale_date)             AS null_sale_date,
    COUNT(*) - COUNT(sale_price)            AS null_sale_price
FROM nashville_housing;


--  Of which there are none at this time.





--  Step 5: Export to CSV.

--  From here, I can export this table back to CSV to import into Tableau and begin building a visualization to aid with
--  exploratory analysis, highlighting key metrics, and aligning business objectives.


