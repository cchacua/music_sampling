-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE INFO WS_ARTISTS
-- First run all_recordings.sql
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- This table relies on WS artist ID to get the MB artist ID. Thereafter, it would be necessary to collapse by MB artist ID, as the WS artist ID has errors
DROP TABLE IF EXISTS ws.artists;
CREATE TABLE ws.artists AS
	SELECT DISTINCT a.main_artist_id, a.main_artist_name, a.main_artist_musicbrainz_id, string_agg(DISTINCT a.main_genre, ', ' ORDER BY a.main_genre) AS genres
	FROM ws.records a
GROUP BY a.main_artist_id, a.main_artist_name, a.main_artist_musicbrainz_id;
/*
SELECT 92159
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

CREATE INDEX trgm_idx ON ws.artists USING GIN (main_artist_name gin_trgm_ops);
CREATE INDEX idx_name ON ws.artists (main_artist_name);
CREATE INDEX idx_wsaid ON ws.artists (main_artist_id);
CREATE INDEX idx_mbaid ON ws.artists (main_artist_musicbrainz_id);
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




