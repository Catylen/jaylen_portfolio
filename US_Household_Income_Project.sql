# US_Householdincome_Data_Cleaning

SELECT *
FROM us_householdincome_statistics;

# Fixing a bad name column from import

ALTER TABLE us_householdincome_statistics RENAME COLUMN `ï»¿id` TO `id`;

SELECT *
FROM us_householdincome;

# Making sure all of my data was properly imported from the csv

SELECT COUNT(id)
FROM us_householdincome;

SELECT COUNT(id)
FROM us_householdincome_statistics;

# Looking for duplicates

SELECT id, COUNT(id)
FROM us_householdincome
GROUP BY id
HAVING COUNT(id) > 1;

# Assigning a row number and partitioning that row number, so that we can identify the specific rows that are duplicates

SELECT row_id,
 id,
 ROW_NUMBER() OVER(PARTITION BY id ORDER BY id)
 FROM us_householdincome;
 
 SELECT *
 FROM(
 SELECT row_id,
 id,
 ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
 FROM us_householdincome) duplicates
 WHERE row_num > 1;
 
 # Deleting the duplicate rows found in our previous query
 
DELETE FROM us_householdincome
WHERE row_id 
IN
(SELECT row_id  
 FROM(
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
	FROM us_householdincome) duplicates
 WHERE row_num > 1);
 
 SELECT id, COUNT(id)
FROM us_householdincome_statistics
GROUP BY id
HAVING COUNT(id) > 1;

# Fixing some typing errors in our string columns

SELECT State_Name, Count(State_Name)
FROM us_householdincome
Group BY State_Name;

SELECT DISTINCT State_Name
FROM us_householdincome
ORDER BY 1;

UPDATE us_householdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE us_householdincome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

SELECT *
FROM us_householdincome
WHERE Place = ''
ORDER BY 1;

SELECT *
FROM us_householdincome
WHERE County = 'Autauga County'
ORDER BY 1;

UPDATE us_householdincome
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';

SELECT Type, Count(Type)
FROM us_householdincome
GROUP BY Type;

UPDATE us_householdincome
SET Type = 'Borough'
Where Type = 'Boroughs';

# Checking our data integrity.
# A state cant be 0 water and 0 land

SELECT ALand, Awater
FROM us_householdincome
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand  = 0 OR ALand = '' OR ALand IS NULL);

SELECT ALand, Awater
FROM us_householdincome
WHERE ALand  = 0 OR ALand = '' OR ALand IS NULL;



# US_Householdincome_Exploratory_Data_Analysis



SELECT *
FROM us_householdincome;

SELECT *
FROM us_householdincome_statistics;

SELECT State_Name, County, City, ALand, AWater
FROM us_householdincome;

#Top 10 by Land Area

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_householdincome
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;

#Top 10 by Water Area

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_householdincome
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10;

# Unpopulated records

SELECT *
FROM us_householdincome u
RIGHT JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE u.id IS NULL;

SELECT *
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id;
    
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0;

# Lowest AVG income 
# (Puerto Rico) and Missisipi on our main land

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2
LIMIT 5;

# Lowest Median income
# Puerto Rico and Arkansas

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3
LIMIT 5;

#Highest AVG Income
# Mean (DC)
# Median (New Jersey)

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 DESC
LIMIT 5;

# Looking at our aggregations by Type
# Municipalities have the highest Mean, however theres only 1 municipality in the dataset

SELECT Type, COUNT(TYPE), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 3 DESC
;

# The Type 'Track' has the highest median AVG with a hefty count of 29000

SELECT Type, COUNT(TYPE), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(TYPE) > 100
ORDER BY 4 DESC
;

# We find that the Type 'Community' is only prevalent in Puerto Rico which would correlate with its low Mean and Median Income

SELECT *
FROM us_householdincome
WHERE TYPE = 'Community';

# Cities with the highest Income
#  Avg Mean: Delta Junction, Alaska | Short Hills, New Jersey | Nasberth, Pennsylvania

SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_householdincome u
INNER JOIN us_householdincome_statistics us
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY 3 DESC;
