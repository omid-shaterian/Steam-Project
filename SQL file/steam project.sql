select * from steam_project;

ALTER TABLE steam_project
ALTER COLUMN price TYPE numeric USING REPLACE(price, '$', '')::numeric;

ALTER TABLE steam_project
ALTER COLUMN linux TYPE BOOLEAN USING
    CASE
        WHEN linux = 'TRUE' THEN TRUE
        WHEN linux = 'FALSE' THEN FALSE
        ELSE NULL  -- Handle other values if necessary
    END;


-- 1. What are the most popular genres among Steam users?(Analyze the frequency of different genres in the dataset.)
with each_genre as(
select
appid,
name,
unnest(string_to_array(genres, ',')) as genre
from steam_project
)
select
count(appid),
genre
from each_genre
group by 2
order by 1 desc;

--2. Which price ranges correlate with higher user scores?(Investigate the relationship between game prices and user reviews.)

select
sum(positive) as positive_reviews,
price
from steam_project
group by 2
order by 1 desc;

--3. What is the distribution of release dates across years?(Determine trends over time, e.g., the number of games released each year.)

select
count(appid) as num_of_games,
"Release year"
from steam_project
group by 2
order by 1 desc;

--4. How does the "Estimated Owners" metric vary across genres or price ranges?(Identify which genres have the highest reach.)

select
sum("Estimated sale"),
unnest(string_to_array(genres, ',')) as genre
from steam_project
group by 2
order by 1 desc;

--5. Which games have the highest average playtime?(Explore the top games by "Average Playtime" to understand what keeps players engaged.)

select
"name",
"Average playtime forever"/ 60 as average_playtime_in_hours,
recommendations
from steam_project
order by 3 desc,2 desc

--6. What factors influence Metacritic scores?(Perform correlation analysis between Metacritic scores and features like price, DLC count, or genre.)

select
unnest(string_to_array(genres, ',')) as genre,
AVG("Metacritic score") AS Average_Metacritic_Score
FROM steam_project
GROUP BY 1
ORDER BY 2 DESC

WITH meta_category AS(
SELECT
CASE
	WHEN "Metacritic score" >= 85 THEN 'masterpiece'
	WHEN "Metacritic score" BETWEEN 80 AND 85 THEN 'very good' 
	WHEN "Metacritic score" BETWEEN 70 AND 81 THEN 'good'
	WHEN "Metacritic score" BETWEEN 60 AND 71 THEN 'average'
	WHEN "Metacritic score" <= 60 THEN 'weak'
END AS Meta,
appid
FROM steam_project
)

SELECT
AVG((price)) AS avg_price,
Meta
FROM meta_category AS mc
JOIN steam_project AS sp
ON sp.appid = mc.appid
GROUP BY 2
ORDER BY 1 DESC


SELECT 
COUNT("Metacritic score"),
"Metacritic score"
FROM steam_project
GROUP BY 2
ORDER BY 1 DESC

--7. Do games with multiple supported languages perform better in terms of user scores or ownership?(Study whether localization impacts a game's success.)

WITH sep_lang AS(
SELECT
appid,
UNNEST(STRING_TO_ARRAY("Supported languages",',')) AS lang
FROM steam_project
)

SELECT
sp.appid,
"name",
COUNT(lang),
"Estimated sale",
"User score"
FROM sep_lang AS sl
JOIN steam_project AS sp
ON sp.appid = sl.appid
GROUP BY 1
ORDER BY 5 DESC

--8. What is the distribution of positive versus negative reviews?(Evaluate how user sentiment varies across genres or price brackets.)
WITH pos_neg AS(
SELECT
unnest(string_to_array(genres, ',')) as genre,
SUM("positive") AS positive_reviews,
SUM("negative") AS negative_reviews
FROM steam_project
GROUP BY genre
)

SELECT
genre,
CASE
	WHEN negative_reviews != 0 THEN positive_reviews / negative_reviews
	WHEN negative_reviews = 0 THEN positive_reviews
END AS sentiment_ratio
FROM pos_neg
ORDER BY 2 DESC

--9. Which pricing strategies seem to work best for developers?(Analyze price versus estimated ownership to see the sweet spot for pricing.)

SELECT
SUM("Estimated sale") AS num_of_sales,
price
FROM steam_project
GROUP BY 2
ORDER BY 1 DESC

--10. How does the presence of DLCs correlate with game sales or user scores?(Assess whether games with additional content sell better or receive higher scores.)

SELECT 
"DLC count",
SUM("Estimated sale") AS sales,
AVG("User score")
FROM steam_project
GROUP BY 1
ORDER BY 2 DESC;

--11. What is the relationship between sales and platform availability (Windows, Mac, Linux)?(Determine if cross-platform availability impacts ownership or reviews.)
WITH platform AS(
SELECT
appid,
CASE
	WHEN windows IS TRUE AND mac IS TRUE AND linux IS TRUE THEN 'w_m_l'
	WHEN windows IS TRUE AND mac IS TRUE AND linux IS FALSE THEN 'w_m'
	WHEN windows IS TRUE AND mac IS FALSE AND linux IS FALSE THEN 'w'
END AS windows_mac_linux
FROM steam_project
)

SELECT
windows_mac_linux,
SUM("Estimated sale") AS sales,
AVG("Average playtime forever")
FROM platform AS pl
JOIN steam_project AS sp
ON sp.appid = pl.appid
GROUP BY 1
ORDER BY 2 DESC

--12. Are certain months or seasons more favorable for game releases?(Identify patterns in release dates and subsequent sales or reviews.)

SELECT
TO_CHAR("Release date",'Month') AS month,
SUM("Estimated sale") AS sales,
SUM(Recommendations) AS recommend
FROM steam_project
GROUP BY 1
ORDER BY 2 DESC

--13. How have user preferences (genres, playtime) evolved over the years?(Detect shifts in gaming trends over time.)

WITH genre_rank AS (
SELECT
"Release year",
UNNEST(STRING_TO_ARRAY(genres,',')) AS genre,
SUM("Estimated sale") AS sales,
ROW_NUMBER() OVER(PARTITION BY "Release year" ORDER BY SUM("Estimated sale") DESC) AS ranking
FROM steam_project
GROUP BY 1,2
ORDER BY 1 DESC, 3 DESC
)
SELECT * FROM genre_rank
WHERE ranking < 4

--14. Which game developers or publishers have the highest-rated games?(Rank developers by average user or Metacritic scores.)

SELECT
developers,
AVG("Metacritic score") AS average_meta,
SUM("positive") AS positive_user_reviews,
COUNT(appid) AS num_of_games
FROM steam_project
GROUP BY 1
ORDER BY 2 DESC, 3 DESC

--15. Which game features (genres, supported languages, etc.) are common among top-rated games?(Perform feature analysis to identify traits of successful games.)

WITH top100 AS(
SELECT
"name",
"Metacritic score",
ROW_NUMBER() OVER(ORDER BY "Metacritic score" DESC) AS ranking,
UNNEST(STRING_TO_ARRAY("tags",',')) AS tag
FROM steam_project
ORDER BY 2 DESC
)

SELECT
tag,
COUNT(tag) AS popular_tags
FROM top100
WHERE ranking < 101
GROUP BY 1
ORDER BY 2 DESC

--16. Do games with lower age requirements appeal to a broader audience?(Explore correlations between required age and estimated ownership or user scores.)

SELECT
"Required age",
SUM("Estimated sale")
FROM steam_project
GROUP BY 1
ORDER BY 2 DESC

--17.Which regions (based on supported languages) seem to dominate the gaming space?(Understand the regional appeal by analyzing the language data.)

WITH cleaned_lang AS(
SELECT
TRIM(UPPER(REPLACE(REPLACE("Full audio languages", '[', ''), ']', '')), ' ') AS cleaned_column
FROM steam_project
)

, unwraped AS(
SELECT
UNNEST(STRING_TO_ARRAY(cleaned_column, ',')) AS popular_lang
FROM cleaned_lang
)

SELECT
popular_lang,
COUNT(*) AS frequency
FROM unwraped
GROUP BY 1
ORDER BY 2 DESC 

--18. How does average playtime correlate with user scores or ownership?(Evaluate whether longer engagement results in better reviews or higher sales.)

SELECT
"name",
("Average playtime forever" / 60) AS avg_playtime_in_hours,
"User score",
"Estimated sale"
FROM steam_project
ORDER BY 2 DESC


-- creating views to unwrap 'genres', 'tags' and 'Full audio languages' columns separatly to avoid creating overwelming number of rows.


-- DROP AND CREATE VIEW FOR GENRES
DROP VIEW IF EXISTS genre_over_time;
CREATE VIEW genre_over_time AS (
  SELECT
    appid,
    "name",
    "Release date",
    UNNEST(STRING_TO_ARRAY(genres, ',')) AS genre,
    ("Average playtime forever" / 60) AS avg_playtime_in_hours,
    "positive",
    "negative",
    "recommendations",
    "Metacritic score",
    "Estimated sale"
  FROM steam_project
);

-- DROP AND CREATE VIEW FOR TAGS
DROP VIEW IF EXISTS tags_over_time;
CREATE VIEW tags_over_time AS (
  SELECT
    appid,
    "name",
    "Release date",
    UNNEST(STRING_TO_ARRAY(tags, ',')) AS tag,
    ("Average playtime forever" / 60) AS avg_playtime_in_hours,
    "positive",
    "negative",
    "recommendations",
    "Metacritic score",
    "Estimated sale"
  FROM steam_project
);

-- DROP AND CREATE VIEW FOR LANGUAGES
DROP VIEW IF EXISTS languages_over_time;
CREATE VIEW languages_over_time AS (
  SELECT
    appid,
    "name",
    "Release date",
    UNNEST(
      STRING_TO_ARRAY(
        TRIM(
          UPPER(
            REPLACE(
              REPLACE("Full audio languages", '[', ''), 
              ']', ''
            )
          )
        ), 
        ','
      )
    ) AS supported_language,
    ("Average playtime forever" / 60) AS avg_playtime_in_hours,
    "positive",
    "negative",
    "recommendations",
    "Metacritic score",
    "Estimated sale"
  FROM steam_project
);
