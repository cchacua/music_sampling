-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE INFO WS_ARTISTS
-- First run all_recordings.sql
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- This table relies on WS artist ID to get the MB artist ID. Thereafter, it would be necessary to collapse by MB artist ID, as the WS artist ID has errors
DROP TABLE IF EXISTS ws.artists;
CREATE TABLE ws.artists AS
	SELECT a.main_artist_id, a.main_artist_name, a.main_artist_musicbrainz_id, string_agg(DISTINCT a.main_genre, ', ' ORDER BY a.main_genre) AS genres, COUNT(DISTINCT id) AS rwsids, COUNT(DISTINCT musicbrainz_id) AS rmbids, COUNT(DISTINCT musicbrainz_id)/COUNT(DISTINCT id)::FLOAT8 AS percenmbids
	FROM ws.records a
GROUP BY a.main_artist_id, a.main_artist_name, a.main_artist_musicbrainz_id;

/*
-- ORDER BY percenmbids DESC, rwsids DESC

SELECT 92159
*/

SELECT * FROM ws.artists LIMIT 100;

-- INDEX
CREATE INDEX trgm_idx ON ws.artists USING GIN (main_artist_name gin_trgm_ops);
CREATE INDEX idx_name ON ws.artists (main_artist_name);
CREATE INDEX idx_wsaid ON ws.artists (main_artist_id);
CREATE INDEX idx_mbaid ON ws.artists (main_artist_musicbrainz_id);

\d ws.artists
\d musicbrainz.artist

-- LEFT JOIN ON MB ARTIST INFO USING NAMES AND ALIASES TO EVALUATE QUALITY
-- All the statistics are computed using UPPER cases

DROP TABLE IF EXISTS ws.artistsmb;
CREATE TABLE ws.artistsmb AS
SELECT a.main_artist_id AS wsid, a.main_artist_name AS wsname, f.name AS mbname1, similarity(UPPER(a.main_artist_name), UPPER(f.name)), levenshtein(UPPER(a.main_artist_name), UPPER(f.name)) AS levdis1, GREATEST(CHAR_LENGTH(a.main_artist_name), CHAR_LENGTH(f.name)) AS maxchar1, a. genres, a.rwsids, a.rmbids, a.percenmbids, f.gid, a.main_artist_musicbrainz_id
	FROM ws.artists a
	LEFT JOIN (
		SELECT DISTINCT b.name, b.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist b
			ON a.main_artist_musicbrainz_id=b.gid
		UNION
		SELECT DISTINCT b.sort_name AS name, b.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist b
			ON a.main_artist_musicbrainz_id=b.gid
		UNION
		SELECT DISTINCT c.name, c.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist_gid_redirect b
			ON a.main_artist_musicbrainz_id=b.gid
			INNER JOIN musicbrainz.artist c
			ON b.new_id=c.id
		UNION
		SELECT DISTINCT c.sort_name AS name, c.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist_gid_redirect b
			ON a.main_artist_musicbrainz_id=b.gid
			INNER JOIN musicbrainz.artist c
			ON b.new_id=c.id
		UNION
		SELECT DISTINCT d.name, b.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist b
			ON a.main_artist_musicbrainz_id=b.gid
			INNER JOIN musicbrainz.artist_alias d
			ON b.id=d.artist
		UNION
		SELECT DISTINCT d.name, c.gid, a.main_artist_musicbrainz_id
			FROM ws.artists a
			INNER JOIN musicbrainz.artist_gid_redirect b
			ON a.main_artist_musicbrainz_id=b.gid
			INNER JOIN musicbrainz.artist c
			ON b.new_id=c.id
			INNER JOIN musicbrainz.artist_alias d
			ON b.new_id=d.artist) f
	ON a.main_artist_musicbrainz_id=f.main_artist_musicbrainz_id
	ORDER BY 1;
/*
SELECT 161852
*/

SELECT * FROM ws.artistsmb ORDER BY mbname1, wsid LIMIT 100;
SELECT * FROM ws.artistsmb ORDER BY wsid LIMIT 100;

SELECT * FROM ws.artistsmb WHERE gid IS NULL LIMIT 100;
SELECT COUNT (DISTINCT gid) FROM ws.artistsmb;
/* 
 count 
-------
 61041
(1 row)
*/

SELECT COUNT (DISTINCT main_artist_musicbrainz_id) FROM ws.artistsmb;
/*
 count 
-------
 61097
(1 row)
*/

-- The table with the best matching statistics to compare
DROP TABLE IF EXISTS ws.artistsmb_unique;
CREATE TABLE ws.artistsmb_unique AS
SELECT DISTINCT ON (a.wsid) a.wsid, a.wsname, a.mbname1, a.similarity, a.levdis1, a.maxchar1, a.genres, a.rwsids, a.rmbids, a.percenmbids, a.gid, a.main_artist_musicbrainz_id 
FROM ws.artistsmb a
ORDER BY a.wsid, a.levdis1 ASC, a.similarity DESC;
/*
SELECT 92159
*/

SELECT * FROM ws.artistsmb_unique ORDER BY wsid LIMIT 100;
CREATE INDEX autrgm_idx ON ws.artistsmb_unique USING GIN (wsname gin_trgm_ops);
CREATE INDEX auidx_name ON ws.artistsmb_unique (wsname);
CREATE INDEX auidx_wsaid ON ws.artistsmb_unique (wsid);
CREATE INDEX auidx_mbaid ON ws.artistsmb_unique (gid);

\d ws.artistsmb_unique

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- STATISTICS
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- COUNT # OF DISTINCTS WSIDS WITH GID INFO
SELECT COUNT(DISTINCT wsid) FROM ws.artistsmb_unique WHERE gid IS NOT NULL;
/*
count 
-------
 61821
(1 row)
*/

-- COUNT # OF DISTINCTS GID
SELECT COUNT(DISTINCT gid) FROM ws.artistsmb_unique;
/*
 count 
-------
 61041
(1 row)
*/

/*


SELECT DISTINCT ON (gid) gid, mbname1, similarity, levdis1, FROM ws.artistsmb_unique 
ORDER BY levdis1 ASC, similarity DESC;
*/


-- GET GIDS WITH MORE THAN ONE WSID
SELECT gid, COUNT(wsid) FROM ws.artistsmb_unique 
WHERE gid IS NOT NULL
GROUP BY gid
HAVING COUNT(wsid)>1
ORDER BY COUNT(wsid) DESC;




SELECT * FROM ws.artistsmb_unique WHERE gid='ea9078ef-20ca-4506-81ea-2ae5fe3a42e8';

SELECT * FROM ws.records WHERE main_artist_musicbrainz_id='152a5f9a-b0e2-42c4-ab71-c559352cc235';
SELECT * FROM ws.records WHERE main_artist_musicbrainz_id='ea9078ef-20ca-4506-81ea-2ae5fe3a42e8';

SELECT * FROM musicbrainz.recording WHERE gid='6740d0da-5063-40a1-91e8-55c7d46c4151';


-- TABLE OF MBIDS WITH COMPLETE SONGS
DROP TABLE IF EXISTS ws.artistsmb_unique_m;
CREATE TABLE ws.artistsmb_unique_m AS
SELECT b.gid, string_agg(DISTINCT a.main_genre, ', ' ORDER BY a.main_genre) AS genres, COUNT(DISTINCT a.id) AS rwsids, COUNT(DISTINCT a.musicbrainz_id) AS rmbids, COUNT(DISTINCT a.musicbrainz_id)/COUNT(DISTINCT a.id)::FLOAT8 AS percenmbids
FROM ws.records a
INNER JOIN ws.artistsmb_unique b
ON a.main_artist_id=b.wsid
WHERE b.gid IS NOT NULL
GROUP BY b.gid;
/*
SELECT 61041
*/

SELECT * FROM ws.artistsmb_unique_m LIMIT 100;
SELECT COUNT(*) FROM ws.artistsmb_unique_m WHERE percenmbids=1;
/*
 count 
-------
 22012
(1 row)
*/



-- Statistics of artists with MB-artist ID
SELECT genres, COUNT(*) FROM ws.artists WHERE main_artist_musicbrainz_id IS NULL GROUP BY genres ORDER BY COUNT(*);

-- Test some cases
SELECT * FROM ws.artists WHERE genres='A, E, H, J, L, O, S, T, W';
SELECT * FROM ws.records WHERE main_artist_id='168340';

-- COUNT MAX LENGHT
SELECT CHAR_LENGTH(main_artist_name), COUNT(*) FROM ws.artists GROUP BY CHAR_LENGTH(main_artist_name) ORDER BY CHAR_LENGTH(main_artist_name) DESC;
/*
The maximum value is 71
char_length | count 
-------------+-------
          71 |     2
          70 |     2
          67 |     1
          62 |     1
          60 |     1
          59 |     1
          58 |     3
          57 |     1
          56 |     3
          55 |     3
          54 |     2
          53 |     6
          52 |     2
          51 |     4
          50 |     2
          49 |     7
          48 |     9
          47 |    10
          46 |    12
          45 |    12
          44 |    18
          43 |    15
          42 |    29
          41 |    27
          40 |    25
          39 |    39
          38 |    34
          37 |    58
          36 |    61
          35 |    91
          34 |   111
          33 |   118
          32 |   156
          31 |   193
          30 |   228
          29 |   272
          28 |   297
          27 |   336
          26 |   421
          25 |   477
          24 |   630
          23 |   740
          22 |   890
          21 |  1136
          20 |  1390
          19 |  1645
          18 |  2133
          17 |  2921
          16 |  3810
          15 |  4958
          14 |  6562
          13 |  7875
          12 |  8956
          11 |  8756
          10 |  7809
           9 |  6701
           8 |  5441
           7 |  4906
           6 |  4600
           5 |  3609
           4 |  2201
           3 |  1185
           2 |   202
           1 |    13
(64 rows)
*/

-----------------------------------------------------------------------------------------
-- USING THE EXTENSION pg_trgm
-----------------------------------------------------------------------------------------
CREATE EXTENSION pg_trgm;

-- CREATE INDEX trgm_idx ON ws.artists USING GIN (main_artist_name gin_trgm_ops);

-- To see indexes
\d ws.artists
\d musicbrainz.artist

-- Set timing

-- Configuring trgm
-- https://www.postgresql.org/docs/9.5/pgtrgm.html

-- Show curretn similarity threshold
SELECT show_limit();
/*
 show_limit 
------------
        0.3
(1 row)
Returns the current similarity threshold used by the % operator. This sets the minimum similarity between two words for them to be considered similar enough to be misspellings of each other, for example.
*/

-- Set a similarity threshold of 0.8
SELECT set_limit(0.5);

SELECT main_artist_name, similarity(main_artist_name, 'Willie Colon') AS sml
  FROM ws.artists
  WHERE main_artist_name % 'Willie Colon'
  ORDER BY sml DESC, main_artist_name;


SELECT name, similarity(name, 'Willie Colon') AS sml
  FROM musicbrainz.artist
  WHERE name % 'Willie Colon'
  ORDER BY sml DESC, name;
/*
      name       |   sml    
-----------------+----------
 Willie & Co.    | 0.642857
 Willie Colón    |    0.625
 Willie Collins  | 0.588235
 Willie Cotton   | 0.588235
 Willie Cobb     |   0.5625
 Willie Cook     |   0.5625
 Willie J. & Co. |   0.5625
 Willie          | 0.538462
 Willie          | 0.538462
 Willie          | 0.538462
 Will Collier    | 0.529412
 Willie Cobbs    | 0.529412
 Willie Cooper   |      0.5
 Willie Cortez   |      0.5
 Willie Will     |      0.5
 Willie Wilson   |      0.5
 Willie Wilson   |      0.5
 Willi Willie    |      0.5
(18 rows)

Time: 5779,693 ms (00:05,780)
*/


-----------------------------------------------------------------------------------------
-- USING fuzzystrmatch package and the levenshtein function
-----------------------------------------------------------------------------------------
CREATE EXTENSION fuzzystrmatch;

SELECT main_artist_name, levenshtein(main_artist_name, 'Willie Colon') AS sml
     FROM ws.artists
     WHERE levenshtein(main_artist_name, 'Willie Colon') < 3
     ORDER BY sml, main_artist_name;

SELECT main_artist_name, levenshtein(upper(main_artist_name), upper('Willie Colon'))/greatest(length(main_artist_name), length('Willie Colon'))::real AS dis
     FROM ws.artists
     WHERE levenshtein(upper(main_artist_name), upper('Willie Colon'))/greatest(length(main_artist_name), length('Willie Colon'))::real  < 0.1
     ORDER BY dis, main_artist_name;

SELECT
    main_artist_name,
    (SELECT name
     FROM musicbrainz.artist
     WHERE levenshtein(main_artist_name, name) < 3
     ORDER BY levenshtein(main_artist_name, name)
     LIMIT 1
    )
FROM ws.artists




