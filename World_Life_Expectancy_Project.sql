# World Life Expectancy Project

# World Life Expectancy Project (Data Cleaning)

SELECT * 
FROM world_life_expectancy;

# Looking for duplicates

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

# Assigning a row number and partitioning that row number, so that we can identify the specific rows that are duplicates

SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
FROM world_life_expectancy;

# Cant filter without putting our row_num in a sub query
# Now we know the Row_ID of the duplicate Concat(Country, Year) because they have a row_num of > 2

SELECT *
FROM( 
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy) as row_table
    WHERE Row_Num > 1
;

# Deleting the duplicate rows found in our previous query

DELETE FROM world_life_expectancy
WHERE Row_ID IN(
SELECT Row_ID
FROM ( 
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy) as row_table
    WHERE Row_Num > 1)
;

# Looking for rows where status is NULL or empty

SELECT *
FROM world_life_expectancy
WHERE Status = '';

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE Status <> ''
;

# There are rows where the countries status goes from 'Developing' in one year to '' (empty) the next into 'Developing' the next year. 
# We can assume that a country wouldn't change its status from 'Developing' to 'Developed' in a one year span so we can fill in those missing values with 'Developing'
 
SELECT distinct(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

# Does Not Work
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT distinct(Country)
FROM world_life_expectancy
WHERE Status = 'Developing')
;

# Join world_life_expectancy to itself
# Set the first world_life_expectancy status to developing where its status is empty and the 2nd world_life_expectancy status is not empty
# Where its blank in table 1 and not blank on table 2 and Country is the same
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

SELECT *
FROM world_life_expectancy
WHERE Country = 'United States of America';

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

SELECT *
FROM world_life_expectancy;

# Two missing values. However the Life expectancy seems to follow a general upwards trend that may be adequately populated by taking the average between the value above and below the missing

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = '';

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy;

SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

# Finallizing our filling of the empty values in life expectancy by taking the average of the value below and above our missing value.

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) /2,1)
WHERE t1.`Life expectancy` = '';





# World Life Expenctancy Project (Exploratory Data Analysis)

SELECT *
FROM world_life_expectancy;

# Lets look at the Minimum and Maximum life expectancies in our dataset
# We find a lot of countries in the African regions have seen massive growth in life expectancy in recent years.
# Haiti in particular has grown from 36.3 years to 65 years over the last 15 years which is a amazing improvement and makes me question how truly horrifying their position is.

SELECT Country, MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC;

# Average Life Expectancy ~ 68
SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
AND `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

SELECT *
FROM world_life_expectancy;

# Lower GDP Countries are highly correlated with low Life_Exp

SELECT Country, ROUND(AVG(`Life expectancy`),2) as Life_Exp, ROUND(AVG(GDP),1) as GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP ASC;

# As expected, higher GDP countries are highly correlated with high life expectancy

SELECT Country, ROUND(AVG(`Life expectancy`),2) as Life_Exp, ROUND(AVG(GDP),1) as GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;

# In this dataset, there are 1326 High GDP countries and 1612 Low GDP countries.
# High GDP Life Expectancy is around 74
# Low GDP Life Expectancy is around 65

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy;

SELECT *
FROM world_life_expectancy;

# Developing life expectancy is around 67
# Developed life expectancy is around 79

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status;

# However, there are a lot more developing countries
# 32 Developed
# 161 Developing

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status;

# This dataset's values on BMI are slightly unbelievable so any insights taking from those numbers should be taken with a grain of salt
# i.e. USA has a average BMI of 58.4 ????

SELECT Country, ROUND(AVG(`Life expectancy`),2) as Life_Exp, ROUND(AVG(BMI),1) as BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0 AND BMI > 0
ORDER BY BMI DESC;


# A rolling total of adult mortalities

SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) as Rolling_Total
FROM world_life_expectancy;

SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) as Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE '%United%';