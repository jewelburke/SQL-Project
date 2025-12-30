-- ============================================
-- Project: Data Cleaning
-- Dataset: Raw animal observation data of Eastern Europe (AI generated)
-- Source: Github
-- ============================================

-- 1. View raw data
SELECT * 
FROM animal_data_dirty;

-- 2. Create staging table
CREATE TABLE animal_data_cleaned
LIKE animal_data_dirty;

INSERT animal_data_cleaned
SELECT *
FROM animal_data_dirty;
 
SELECT *
FROM animal_data_cleaned;

-- 3. Remove Duplicates
CREATE TABLE animal_data_cleaned2 AS
SELECT *,
       ROW_NUMBER() OVER(
       PARTITION BY `Animal Type`, Country, `Weight kg`, `Body Length cm`, Gender, `Animal Code`, Latitude, Longitude, `Animal Name`, `Observation date`, `Data compiled by`
	   ORDER BY `Animal Type`, Country, `Weight kg`, `Body Length cm`, Gender, `Animal Code`, Latitude, Longitude, `Animal Name`, `Observation date`, `Data compiled by`
       ) AS row_num
FROM animal_data_cleaned;

SELECT *
FROM animal_data_cleaned2;

SELECT COUNT(*) AS duplicate_rows
FROM animal_data_cleaned2
WHERE row_num > 1;

CREATE TABLE animal_data_deduped AS
SELECT *
FROM animal_data_cleaned2
WHERE row_num = 1;

SELECT *
FROM animal_data_deduped;

-- 4. Standardize the data
ALTER TABLE animal_data_deduped
RENAME COLUMN `ï»¿Animal type` TO `Animal Type`;

UPDATE animal_data_deduped
SET `Animal Type` = TRIM(`Animal Type`),
	`Country` = TRIM(`Country`),
	`Weight kg` = TRIM(`Weight kg`),
    `Body Length cm` = TRIM(`Body Length cm`),
     Gender = TRIM(Gender),
    `Animal code` = TRIM(`Animal code`),
    Latitude = TRIM(Latitude),
    Longitude = TRIM(Longitude),
    `Observation date` = TRIM(`Observation date`),
    `Data compiled by` = TRIM(`Data compiled by`);

SELECT `Animal Type`,
COUNT(*)
FROM animal_data_deduped
GROUP BY `Animal Type`;

UPDATE animal_data_deduped
SET `Animal Type` = CASE
WHEN `Animal Type` LIKE 'European%' THEN 'European bison'
WHEN `Animal Type` LIKE '%edgeh%' THEN 'hedgehog'
WHEN `Animal Type` LIKE 'lynx%' THEN 'lynx'
WHEN `Animal Type` LIKE 'red%' THEN 'red squirrel'
ELSE `Animal Type`
END;

SELECT `Animal Type`, COUNT(*)
FROM animal_data_deduped
GROUP BY `Animal Type`
ORDER BY COUNT(*);

SELECT *
FROM animal_data_deduped;

SELECT `Country`, COUNT(*)
FROM animal_data_deduped
GROUP BY `Country`;

UPDATE animal_data_deduped
SET `Country` = CASE
WHEN `Country` LIKE 'Aust%' THEN 'Austria'
WHEN `Country` LIKE 'C%' THEN 'Czech Republic'
WHEN `Country` LIKE 'P%' THEN 'Poland'
WHEN `Country` LIKE 'DE' THEN 'Germany'
WHEN `Country` LIKE 'H%' THEN 'Hungary'
ELSE `Country`
END;

UPDATE animal_data_deduped
SET `Observation date` = STR_TO_DATE(`Observation date`, '%d.%m.%Y');

ALTER TABLE animal_data_deduped
MODIFY `Observation date` DATE;

-- 5. Populate blank values to Null

UPDATE animal_data_deduped
SET
  `Animal Type`       = NULLIF(TRIM(`Animal Type`), ''),
  Country             = NULLIF(TRIM(Country), ''),
  Gender              = NULLIF(TRIM(Gender), ''),
  `Animal code`       = NULLIF(TRIM(`Animal code`), ''),
  `Animal name`       = NULLIF(TRIM(`Animal name`), ''),
  `Data compiled by`  = NULLIF(TRIM(`Data compiled by`), '');

-- 6. Remove unncessarry columns/rows

SELECT *
FROM animal_data_deduped
WHERE `Animal Type` IS NULL;

DELETE FROM animal_data_deduped
WHERE `Animal Type` IS NULL;

ALTER TABLE animal_data_deduped
DROP COLUMN `Animal code`,
DROP COLUMN `Animal name`,
DROP COLUMN row_num;





