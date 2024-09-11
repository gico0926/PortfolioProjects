/*

Cleaning Data and Analysis in SQL Queries

*/

USE Portfolio;


--------------------------
-- Part 1 Cleaning Data --
--------------------------


--Check the overall data
--
SELECT *
FROM Portfolio.dbo.vehicles
--


--Check for duplicate rows that have same manufacturer, model, year, odometer
SELECT manufacturer, model, year, odometer,COUNT(*) as repeat_numbers
FROM Portfolio.dbo.vehicles
GROUP BY manufacturer, model, year, odometer
HAVING COUNT(*) > 1
ORDER BY COUNT(*) desc;
--


--Remove duplicate rows (!not on raw data!)
WITH CTE AS (
    SELECT 
        manufacturer, 
        model, 
        year, 
        odometer,
        ROW_NUMBER() OVER (PARTITION BY manufacturer, model, year, odometer ORDER BY (SELECT NULL)) AS row_num
    FROM Portfolio..vehicles
)
DELETE
FROM CTE
WHERE row_num > 1;
--


--Remove rows with null values in manufacturer and model and price = 0 (!not on raw data!)
DELETE
FROM Portfolio..vehicles
WHERE manufacturer IS NULL
  OR model IS NULL
  OR price = 0;
--


--Organize manufacturer, title_status, type column
SELECT DISTINCT manufacturer
FROM Portfolio..vehicles;
--
UPDATE Portfolio..vehicles
SET manufacturer = 'land rover'
WHERE manufacturer = 'rover';
--
UPDATE Portfolio..vehicles
SET title_status = NULL
WHERE title_status = 'missing';
--
UPDATE Portfolio..vehicles
SET type = 'truck'
WHERE type = 'pickup';


--------------------------
-- Part 2 Data Analysis --
--------------------------


--Top 10 Car type 
SELECT TOP 10 type, COUNT(type) AS type_count
FROM Portfolio..vehicles
GROUP BY type
ORDER BY type_count DESC;
--
/*
The most popular car types are sedans, SUVs, and trucks, 
with their numbers far exceeding those of the fourth-place category.
*/



--Top 10 Car Manufacturer--
WITH ManufacturerCounts AS (
    SELECT manufacturer, COUNT(manufacturer) AS manufacturer_count
    FROM Portfolio..vehicles
    GROUP BY manufacturer
),
TotalCount AS (
    SELECT SUM(manufacturer_count) AS total_count
    FROM ManufacturerCounts
)
SELECT TOP 10 
    mc.manufacturer, 
    mc.manufacturer_count, 
    (CAST(mc.manufacturer_count AS FLOAT) / tc.total_count) * 100 AS percentage
FROM ManufacturerCounts mc, TotalCount tc
ORDER BY mc.manufacturer_count DESC;
--
/*
Ford has the highest percentage in this ranking, reaching up to 17%.
*/



--Top 10 Car Manufacturer with model and type--
SELECT TOP 10 manufacturer, model, type, COUNT(*) AS count
FROM Portfolio..vehicles
GROUP BY manufacturer, model, type
ORDER BY count DESC;
--
/*
Ford, with its F-150, takes first place, 
and interestingly,the top three types of vehicles are all trucks.
*/



--Fuel category vs Percentage--
WITH FuelCounts AS (
    SELECT fuel, COUNT(*) AS count
    FROM Portfolio..vehicles
    GROUP BY fuel
),
TotalCount AS (
    SELECT SUM(count) AS total_count
    FROM FuelCounts
)
SELECT 
    fc.fuel, 
    fc.count, 
    (CAST(fc.count AS FLOAT) / tc.total_count) * 100 AS percentage
FROM FuelCounts fc, TotalCount tc
ORDER BY fc.count DESC;
--
/*
Gas is the most common fuel type, 
accounting for up to 89% of the total.
*/



--Top 10 Car's paint_color
SELECT TOP 10 paint_color, COUNT(*) AS count
FROM Portfolio..vehicles
GROUP BY paint_color
ORDER BY count DESC;
--
/*
White is the most common color in the car industry. 
It holds its resale value better than other colors.
*/




--------------------------
-- Part 3 Creating View --
--------------------------

--store data for visualiztions--


CREATE VIEW Top10CarTypes AS
SELECT TOP 10 type, COUNT(type) AS type_count
FROM Portfolio..vehicles
GROUP BY type
ORDER BY type_count DESC;
--
--
CREATE VIEW Top10CarManufacturers AS
WITH ManufacturerCounts AS (
    SELECT manufacturer, COUNT(manufacturer) AS manufacturer_count
    FROM Portfolio..vehicles
    GROUP BY manufacturer
),
TotalCount AS (
    SELECT SUM(manufacturer_count) AS total_count
    FROM ManufacturerCounts
)
SELECT TOP 10 
    mc.manufacturer, 
    mc.manufacturer_count, 
    (CAST(mc.manufacturer_count AS FLOAT) / tc.total_count) * 100 AS percentage
FROM ManufacturerCounts mc, TotalCount tc
ORDER BY mc.manufacturer_count DESC;
--
--
CREATE VIEW Top10CarManufacturerModelType AS
SELECT TOP 10 manufacturer, model, type, COUNT(*) AS count
FROM Portfolio..vehicles
GROUP BY manufacturer, model, type
ORDER BY count DESC;
--
CREATE VIEW FuelCategoryPercentage AS
WITH FuelCounts AS (
    SELECT fuel, COUNT(*) AS count
    FROM Portfolio..vehicles
    GROUP BY fuel
),
TotalCount AS (
    SELECT SUM(count) AS total_count
    FROM FuelCounts
)
SELECT TOP 10
    fc.fuel, 
    fc.count, 
    (CAST(fc.count AS FLOAT) / tc.total_count) * 100 AS percentage
FROM FuelCounts fc, TotalCount tc;
--
--
CREATE VIEW Top10CarPaintColors AS
SELECT TOP 10 paint_color, COUNT(*) AS count
FROM Portfolio..vehicles
GROUP BY paint_color
ORDER BY count DESC;
