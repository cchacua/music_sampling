
DROP TABLE IF EXISTS musicbrainz.whois;

-- Create table of whoissampling

CREATE TABLE musicbrainz.whois
(
connection_id INT,
connection_type CHAR(1),
connection_popularity REAL,
dest_track_id INT,
dest_track_name VARCHAR(100),
dest_track_release_year CHAR(4),
dest_track_main_genre CHAR(1),
dest_track_main_artist_id INT,
dest_track_main_artist_name VARCHAR(100),
dest_track_youtube_id VARCHAR(50),
dest_track_musicbrainz_id UUID,
dest_track_main_artist_musicbrainz_id CHAR(36),
source_track_id INT,	
source_track_name VARCHAR(100),
source_track_release_year CHAR(4),
source_track_main_genre CHAR(1),
source_track_main_artist_id INT,
source_track_main_artist_name VARCHAR(100),
source_track_youtube_id VARCHAR(50),
source_track_musicbrainz_id UUID,
source_track_main_artist_musicbrainz_id UUID,
CONSTRAINT whois_pkey PRIMARY KEY (connection_id)
);

/**
CODE TO LOAD (COPY) THE CSV FILE USING pgAdmin4

"/usr/bin/psql" --command " "\\copy musicbrainz.whois (connection_id, connection_type, connection_popularity, dest_track_id, dest_track_name, dest_track_release_year, dest_track_main_genre, dest_track_main_artist_id, dest_track_main_artist_name, dest_track_youtube_id, dest_track_musicbrainz_id, dest_track_main_artist_musicbrainz_id, source_track_id, source_track_name, source_track_release_year, source_track_main_genre, source_track_main_artist_id, source_track_main_artist_name, source_track_youtube_id, source_track_musicbrainz_id, source_track_main_artist_musicbrainz_id) FROM '/home/christian/github_new/music_sampling/whoissampling/CSV.csv' DELIMITER ';' CSV HEADER ENCODING 'UTF8' QUOTE '\"' ESCAPE '\"';""
**/


-- SOME QUERY TEST
SELECT a.* FROM musicbrainz.whois a LIMIT 10 OFFSET 2;
SELECT a.* FROM musicbrainz.whois a WHERE a.connection_id=240730;
SELECT a.* FROM musicbrainz.whois a WHERE a.connection_id=261886;

SELECT a.source_track_id, a.source_track_name, a.source_track_musicbrainz_id, a.dest_track_id, a.dest_track_name FROM musicbrainz.whois a LIMIT 10;

SELECT a.source_track_name, COUNT(DISTINCT a.source_track_musicbrainz_id)
 FROM musicbrainz.whois a 
 GROUP BY a.source_track_name
 HAVING COUNT(DISTINCT a.source_track_musicbrainz_id)>1
 LIMIT 100;

SELECT a.source_track_id, COUNT(DISTINCT a.source_track_musicbrainz_id)
 FROM musicbrainz.whois a 
 GROUP BY a.source_track_id
 HAVING COUNT(DISTINCT a.source_track_musicbrainz_id)>1
 LIMIT 100;

SELECT a.source_track_id, COUNT(DISTINCT a.source_track_name)
 FROM musicbrainz.whois a 
 GROUP BY a.source_track_id
 HAVING COUNT(DISTINCT a.source_track_name)>1
 LIMIT 100;

--------------------------------------------------------------------------
-- CREATE INDEX
--------------------------------------------------------------------------

-- For the destination track
CREATE INDEX des_idx ON musicbrainz.whois (dest_track_musicbrainz_id);
CREATE INDEX sou_idx ON musicbrainz.whois (source_track_musicbrainz_id);

