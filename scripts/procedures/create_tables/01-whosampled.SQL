---------------------------------------------------------------------------------
-- TO RUN ON A POSTGRESQL CLIENT (PSQL, pgAdmin, etc.)
---------------------------------------------------------------------------------

-- List all databases
\l

-- Connect to the database
\connect musicbrainz;

-- Create schema or tablespace for WhoSampled
CREATE SCHEMA ws;

DROP TABLE IF EXISTS ws.main;

-- Create main table of WhoSampled

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

COMMENT ON TABLE  ws.main
    IS 'This table contains the original data from who sampled';

-- Load data
\copy ws.main FROM '/mnt/hdd1/repositories/christian/mbrainz/CSV.csv' WITH CSV DELIMITER ';'  QUOTE '"' HEADER;
/*
COPY 414354
*/


SELECT a.* FROM ws.main a LIMIT 10;

--------------------------------------------------------------------------
-- CREATE INDEX
--------------------------------------------------------------------------

-- For the destination track
CREATE INDEX des_idx ON ws.main (des_musicbrainz_id);
CREATE INDEX sou_idx ON ws.main (sou_musicbrainz_id);

CREATE INDEX wsmain_des_main_artist_idx ON ws.main (des_main_artist_id);
CREATE INDEX wsmain_sou_main_artist_idx ON ws.main (sou_main_artist_id);

CREATE INDEX wsmain_des_idx ON ws.main (des_id);
CREATE INDEX wsmain_sou_idx ON ws.main (sou_id);
