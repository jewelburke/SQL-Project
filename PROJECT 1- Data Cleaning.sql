-- DATA Cleaning 
-- 1. creating staging table (raw dataset)
-- 2. Remove Duplicates
-- 3. Standardized the data
-- 4. Null or blank values (populate if you can)
-- 5. Remove unnecessary columns and rows


-- 1. staging table
SELECT * 
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;	

-- 2. Duplicates

SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- copied data to clipboard and pasted below, added row_num INT and changed table name to generate new table
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- create new blank table to put above data into
SELECT *
FROM layoffs_staging2;

-- insert data into new blank table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- IDENTIFY DUPLICATES
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- DELETE DUPLICATES
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- CHECK TO SEE IF DUPLICATES ARE DELETED
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- CHECK FULL TABLE
SELECT *
FROM layoffs_staging2;

-- 3. Standardizing Data

-- trimming extra spaces
SELECT TRIM(company)
FROM layoffs_staging2;

-- Updating table to TRIM spaces
UPDATE layoffs_staging2
SET company = TRIM(company);

-- VIEW INCONSISTENT INDUSTRY TITLES
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- HONE IN ON INCONSISTENCY
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- UPDATED INDUSTRY TO BE CONSISTENT
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- LOOKING AT EACH COLUMN TITLE FOR INCONSISTENCIES
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- FOUND INCONSISTENCY IN U.S.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- MAKE A NEW COLUMN WITH CORRECT "U.S."
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- UPDATE TABLE WITH CORRECT COUNTRIES
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- change date column from text to "date"
SELECT `date`
FROM layoffs_staging2;

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- 4. Working with Nulls and Blank values

-- finding rows where both columns are null
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- honing in on specific column
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- noticing that we have 2 airbnb rows but only 1 says "travel" for industry- so we must populate the other one
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- JOINED TABLE TO ITSELF
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- SET BLANKS TO NULLS
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- update table to populate Nulls with industry type
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- checked everything to see if there were still Nulls, investigated further
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- 5. Remove unneccessary columns and rows (in this case, row_num, rows with nulls under laid offs)

SELECT *
FROM layoffs_staging2;
 
 -- viewed unneccessary rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

 -- deleted unneccessary rows
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;