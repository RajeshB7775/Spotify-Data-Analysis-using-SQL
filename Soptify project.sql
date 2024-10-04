-- Advance SQL Project Spotify Datasets

DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);


-- EDA
SELECT COUNT(*) FROM spotify;

SELECT COUNT(DISTINCT Artist) FROM spotify;

SELECT DISTINCT album_type FROM spotify;

SELECT MAX(duration_min) FROM spotify;
SELECT MIN(duration_min) FROM spotify;

SELECT * FROM spotify 
WHERE duration_min = 0

DELETE FROM spotify
WHERE duration_min = 0

SELECT DISTINCT channel FROM spotify

SELECT DISTINCT most_played_on FROM spotify

-- ------------------------------
-- Data Analysis - Easy Category
-- ------------------------------

-- Q.1 Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track FROM spotify
WHERE stream > 1000000000;


-- Q.2 List all albums along with their respective artists.

SELECT 
	DISTINCT album, artist
FROM spotify
ORDER BY 1;


-- Q.3 Get the total number of comments for tracks where licensed = TRUE.

SELECT  SUM(comments) AS total_comments
FROM spotify
WHERE licensed = true;

-- Q.4 Find all tracks that belong to the album type single.

SELECT * FROM spotify 
WHERE album_type = 'single'; 

-- Q.5 Count the total number of tracks by each artist.

SELECT 
	artist,
	COUNT(*) AS total_no_of_song
FROM spotify
GROUP BY artist
ORDER BY 2 ;


-- ------------
-- Medium Level
-- ------------

-- Q.6 Calculate the average danceability of tracks in each album.

SELECT 
	album,
	AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC

-- Q.7 Find the top 5 tracks with the highest energy values.

SELECT 
	track,
	MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


-- Q.8 List all tracks along with their views and likes where official_video = TRUE.

SELECT 
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC 

	
-- Q.9 For each album, calculate the total views of all associated tracks.

SELECT
	album,
	track,
	SUM(views) total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC


-- Q.10 Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT 
	*
FROM
	(SELECT
		track,
		-- most_played_on,
		COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' THEN  stream END), 0) as streamed_on_youtube,
		COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' THEN  stream END), 0) as streamed_on_spotify
	  FROM spotify	
	  GROUP BY 1
	 )AS t1
WHERE 
	streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube <> 0




-- --------------------------
-- Advance Problem
-- --------------------------

-- Q.11 Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranked_artist
AS
(SELECT 
	artist,
	track,
	SUM(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) AS d_rank
FROM spotify
GROUP  BY 1,2
ORDER BY 1,3 DESC 
)
SELECT * FROM ranked_artist
WHERE d_rank <= 3


-- Q.12 Write a query to find tracks where the liveness score is above the average.
	
SELECT 
	track,
	artist,
	liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)


-- Q.13 Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

WITH cte
AS
(SELECT
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energy
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energy as energy_diff
FROM cte
ORDER BY energy_diff DESC


-- Q.14 Find tracks where the energy-to-liveness ratio is greater than 1.2.


SELECT 
	artist, 
	track, 
	album, 
	energy, 
	liveness, (energy / liveness) AS energy_to_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2;


-- Q.15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
	artist, 
	track, 
	album, 
	views, 
	likes, 
    SUM(likes) OVER (ORDER BY views ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_likes
FROM spotify
ORDER BY views DESC;


-- Query Optimization 

EXPLAIN ANALYZE -- et 6.654 ms pt 0.108
SELECT
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND
	most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25


CREATE INDEX artist_index ON spotify (artist);

