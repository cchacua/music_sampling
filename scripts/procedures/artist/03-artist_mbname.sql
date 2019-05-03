\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table with all the artist names od MB
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.mb_artist_name;
CREATE TABLE ws.mb_artist_name AS
SELECT DISTINCT artist, sort_name AS name, UPPER(sort_name) AS uname
	FROM musicbrainz.artist_alias
	WHERE name<>sort_name
UNION 
SELECT DISTINCT artist, name, UPPER(name) AS uname
	FROM musicbrainz.artist_alias
UNION 
SELECT DISTINCT id AS artist, name, UPPER(name) AS uname
	FROM musicbrainz.artist
UNION
SELECT DISTINCT id AS artist, sort_name AS name, UPPER(sort_name) AS uname
	FROM musicbrainz.artist
	WHERE name<>sort_name;
/*
SELECT 2.529.598
Time: 8108,666 ms (00:08,109)
*/

CREATE INDEX mb_artist_name_unamex1 ON ws.mb_artist_name USING GIN (uname gin_trgm_ops);
CREATE INDEX mb_artist_name_unamex2 ON ws.mb_artist_name USING GIN(to_tsvector('mb_simple', uname));
CREATE INDEX mb_artist_name_unamex3 ON ws.mb_artist_name (uname);
CREATE INDEX mb_artist_name_artistx ON ws.mb_artist_name (artist);
