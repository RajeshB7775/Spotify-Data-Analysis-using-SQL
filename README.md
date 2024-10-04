# Spotify SQL Project and Query Optimization

![spotify_logo](https://github.com/user-attachments/assets/f698ebe5-4a4a-4476-a980-277bb11bbaef)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
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
```

## Project Steps
## 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:

* `Artist`: The performer of the track.
* `Track`: The name of the song.
* `Album`: The album to which the track belongs.
* `Album_type`: The type of album (e.g., single or album).
* Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.
  
## 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into easy, medium, and advanced levels to help progressively develop SQL proficiency.

### Easy Queries
* Simple data retrieval, filtering, and basic aggregations.
  
### Medium Queries
* More complex queries involving grouping, aggregation functions, and joins.

### Advanced Queries
* Nested subqueries, window functions, CTEs, and performance optimization.
  
## 3. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:

* **Indexing**: Adding indexes on frequently queried columns.
* **Query Execution Plan**: Using EXPLAIN ANALYZE to review and refine query performance.


# 15 Practice Questions
### Easy Level
1.Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT track FROM spotify
WHERE stream > 1000000000;
```

2.List all albums along with their respective artists.
```sql
SELECT 
  DISTINCT album, artist
FROM spotify
ORDER BY 1;
```

3.Get the total number of comments for tracks where licensed = TRUE.
```sql
SELECT  
  SUM(comments) AS total_comments
FROM spotify
WHERE licensed = true;
```

4.Find all tracks that belong to the album type single.
```sql
SELECT * FROM spotify 
WHERE album_type = 'single';
```

5.Count the total number of tracks by each artist.
```sql
SELECT 
  artist,
  COUNT(*) AS total_no_of_song
FROM spotify
GROUP BY artist
ORDER BY 2 ;
```

### Medium Level
6.Calculate the average danceability of tracks in each album.
```sql
SELECT 
  album,
  AVG(danceability) AS avg_danceability
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
```

7.Find the top 5 tracks with the highest energy values.
```sql
SELECT 
  track,
  MAX(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

8.List all tracks along with their views and likes where official_video = TRUE.
```sql
SELECT 
  track,
  SUM(views) as total_views,
  SUM(likes) as total_likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
```

9.For each album, calculate the total views of all associated tracks.
```sql
SELECT
  album,
  track,
  SUM(views) total_views
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC
```

10.Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
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
```

### Advanced Level
11.Find the top 3 most-viewed tracks for each artist using window functions.
```sql
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
```

12.Write a query to find tracks where the liveness score is above the average.
```sql
SELECT 
  track,
  artist,
  liveness
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)
```

13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
```sql
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
```

14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT 
  artist, 
  track, 
  album, 
  energy, 
  liveness, (energy / liveness) AS energy_to_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2;
```

15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT 
  artist, 
  track, 
  album, 
  views, 
  likes, 
  SUM(likes) OVER (ORDER BY views ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_likes
FROM spotify
ORDER BY views DESC;
```

# Query Optimization Technique
To improve query performance, we carried out the following optimization process:

* **Initial Query Performance Analysis Using `EXPLAIN`**

    * We began by analyzing the performance of a query using the EXPLAIN function.
    * The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
      * Execution time (E.T.): 7 ms
      * Planning time (P.T.): 0.17 ms
    * Below is the screenshot of the EXPLAIN result before optimization:
    ![spotify_explain_before_index](https://github.com/user-attachments/assets/021b77a3-5576-4f49-b353-cede718e2f90)

* **Index Creation on the artist Column**

    * To optimize the query performance, we created an index on the artist column. This ensures faster retrieval of rows where the artist is queried.
    * **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```
* **Performance Analysis After Index Creation**

    * After creating the index, we ran the same query again and observed significant improvements in performance:
      * Execution time (E.T.): 0.153 ms
      * Planning time (P.T.): 0.152 ms
    * Below is the screenshot of the EXPLAIN result after index creation:
      ![spotify_explain_after_index](https://github.com/user-attachments/assets/743b2a7f-3b86-46d6-ad24-dd28e0015ccd)

* **Graphical Performance Comparison**

    * A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    * **Graph view** shows the significant drop in both execution and planning times:
      ![spotify_graphical view 3](https://github.com/user-attachments/assets/3b4e2c30-a1b4-44a5-8ba3-667483fa9ca9)
      ![spotify_graphical view 2](https://github.com/user-attachments/assets/94be138e-6dcf-4e66-a732-2db8938dfde7)
      ![spotify_graphical view 1](https://github.com/user-attachments/assets/e0a7ea6d-7d1a-4baf-a8f3-f555338e5cbc)

# This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
## Technology Stack
* **Database**: PostgreSQL
* **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
* **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL





