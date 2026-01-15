# SQL Data Cleaning Project – Wildlife Observations of Eastern Europe

## Project Overview
This project demonstrates a full SQL-based data cleaning workflow applied to a raw wildlife observation dataset from Eastern Europe.  
The goal was to transform messy, raw data into an analysis-ready table using SQL.

All transformations were performed in MySQL using staging tables to preserve the original dataset.

> **Note:** The dataset used in this project was AI-generated to simulate real-world environmental data quality issues.

---

## Dataset Description
**Source:** Kaggle
**Region:** Eastern Europe  
**Data Type:** Wildlife observations with physical measurements and geographic metadata

### Key Challenges
- Full-row duplicate records
- Inconsistent categorical values
- Leading/trailing whitespace
- Empty strings representing missing data
- Non-ISO date formats
- Unnecessary identifier columns

---

## Cleaning Workflow Summary

### 1. View Raw Data
- Noted data inconsistencies
- Created plan of action to clean data

### 2. Staging Table
- Created a staging table to preserve the raw dataset
- Ensured all transformations were reproducible and non-destructive

### 3. Duplicate Removal
- Identified full-row duplicates using `ROW_NUMBER()`
- Retained one record per duplicate group
- Removed duplicate rows into a final deduplicated table

### 4. Data Standardization
- Renamed malformed column headers
- Trimmed whitespace across all text fields
- Standardized categorical values:
  - Animal Type (European bison, lynx, hedgehog, red squirrel)
  - Country names (Austria, Czech Republic, Poland, Germany, Hungary)
-  Converted date format to standard ISO format

### 5. Missing Data Handling
- Converted empty strings and whitespace-only values into `NULL`s
- Removed records missing vital identifiers (Animal Type)

### 6. Schema Cleanup
- Dropped unnecessary identifier columns
- Retained only analysis-relevant fields

---

## Final Output
The final cleaned table:
- Contains no full-row duplicates
- Uses consistent categorical values
- Stores dates in ISO-compliant format
- Represents missing values as `NULL`

---

## Skills Demonstrated
- SQL data cleaning
- Window functions
- Staging table workflows
- Data standardization and validation
- Handling missing and inconsistent data
- Date conversion
- Schema refinement
