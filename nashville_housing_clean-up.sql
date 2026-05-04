-- Nashville housing clean-up project
-- Author: Rian Kuffo
-- Tool:   Excel, PostgreSQL (pgAdmin 4)
-- Source: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data



--  Step 0: Importing the nashville housing data from Kaggle. 

--  First, I downloaded the csv file, and imported it in Excel for clean-up.
--  I created a copy of the file to keep a legacy version for reference.
--  I replaced spaces with underscores, and upper case for lower case in the columns.

--  There were two columns removed, one being the Unnamed column, which was replaced with a primary key column.
--  The image column was removed as the use of it was unnecessary for this project.

--  I took the liberty of finding the max amount of characters in each column using the Excel LEN() and MAX() functions. 
--  I used that number for the character varying and numeric data-type columns.
--  I have provided both csv files in the repository for reference of the changes made.

--  Attached below is the code I used to create the table, 
--  then the code used to import the csv to the SQL editor pgAdmin. 


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


--  Importing nashville housing query example (not the exact file path):

COPY nashville_housing
FROM 'C:\MyDirectory\nashville_housing_copy'
WITH (FORMAT CSV, HEADER);



--  Step 1: Raw imported data preview.

--  I used this select all query to glance over the columns and ensure the data imported correctly.

SELECT *
FROM nashville_housing;


--  I then selected a count of all rows to ensure the total rows matched what was present in the csv file.

SELECT COUNT(*) AS total_rows
FROM nashville_housing;


--  When glancing over the select all query earlier, I found many nulls. 
--  To determine how many nulls each column contained I utilized the following query, 
--  taking the total count and subtracting from the total non-null count found in each column: 

SELECT COUNT(*) AS total_rows,
    COUNT(*) - COUNT(parcel_id)           AS null_parcel_id,
    COUNT(*) - COUNT(property_address)    AS null_property_address,
    COUNT(*) - COUNT(sale_date)           AS null_sale_date,
    COUNT(*) - COUNT(sale_price)          AS null_sale_price,
    COUNT(*) - COUNT(legal_ref)           AS null_legal_reference,
    COUNT(*) - COUNT(owner_name)          AS null_owner_name,
    COUNT(*) - COUNT(address)      		  AS null_owner_address,
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
