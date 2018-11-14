
DROP TABLE IF EXISTS ws.main;

-- Create table of whoissampling

CREATE TABLE ws.main
(
connection_id INT,
connection_type CHAR(1),
connection_popularity REAL,
des_id INT,
des_name VARCHAR(100),
des_release_year CHAR(4),
des_main_genre CHAR(1),
des_main_artist_id INT,
des_main_artist_name VARCHAR(100),
des_youtube_id VARCHAR(50),
des_musicbrainz_id UUID,
des_main_artist_musicbrainz_id UUID,
sou_id INT,	
sou_name VARCHAR(100),
sou_release_year CHAR(4),
sou_main_genre CHAR(1),
sou_main_artist_id INT,
sou_main_artist_name VARCHAR(100),
sou_youtube_id VARCHAR(50),
sou_musicbrainz_id UUID,
sou_main_artist_musicbrainz_id UUID,
CONSTRAINT whois_pkey PRIMARY KEY (connection_id)
);

/**
CODE TO LOAD (COPY) THE CSV FILE USING pgAdmin4

"/usr/bin/psql" --command " "\\copy ws.main (connection_id, connection_type, connection_popularity, des_id, des_name, des_release_year, des_main_genre, des_main_artist_id, des_main_artist_name, des_youtube_id, des_musicbrainz_id, des_main_artist_musicbrainz_id, sou_id, sou_name, sou_release_year, sou_main_genre, sou_main_artist_id, sou_main_artist_name, sou_youtube_id, sou_musicbrainz_id, sou_main_artist_musicbrainz_id) FROM '/home/christian/github_new/music_sampling/whosampled/CSV.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE '\"' ESCAPE '\"';""

**/


-- SOME QUERY TEST
SELECT a.* FROM ws.main a LIMIT 10 OFFSET 2;
SELECT a.* FROM ws.main a WHERE a.connection_id=240730;
SELECT a.* FROM ws.main a WHERE a.connection_id=261886;

SELECT a.sou_id, a.sou_name, a.sou_musicbrainz_id, a.des_id, a.des_name FROM ws.main a LIMIT 10;

SELECT a.sou_name, COUNT(DISTINCT a.sou_musicbrainz_id)
 FROM ws.main a 
 GROUP BY a.sou_name
 HAVING COUNT(DISTINCT a.sou_musicbrainz_id)>1
 LIMIT 100;

SELECT a.sou_id, COUNT(DISTINCT a.sou_musicbrainz_id)
 FROM ws.main a 
 GROUP BY a.sou_id
 HAVING COUNT(DISTINCT a.sou_musicbrainz_id)>1
 LIMIT 100;

SELECT a.sou_id, COUNT(DISTINCT a.sou_name)
 FROM ws.main a 
 GROUP BY a.sou_id
 HAVING COUNT(DISTINCT a.sou_name)>1
 LIMIT 100;

--------------------------------------------------------------------------
-- CREATE INDEX
--------------------------------------------------------------------------

-- For the destination track
CREATE INDEX des_idx ON ws.main (des_musicbrainz_id);
CREATE INDEX sou_idx ON ws.main (sou_musicbrainz_id);

