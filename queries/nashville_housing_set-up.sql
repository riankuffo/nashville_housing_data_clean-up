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
--  I have provided a limited version of both CSV files for reference.

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


