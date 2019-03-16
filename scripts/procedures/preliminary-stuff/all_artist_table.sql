-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE WITH ALL ARTIST NAMES, ALIASES AND INTERNAL MB ID (IT ISN'T THE GID) 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.mb_artistnames;
CREATE TABLE ws.mb_artistnames AS
	SELECT DISTINCT name, UPPER(name) AS upname, id
		FROM musicbrainz.artist
	UNION
	SELECT DISTINCT sort_name AS name, UPPER(sort_name) AS upname, id
		FROM musicbrainz.artist
	UNION
	SELECT DISTINCT name, UPPER(name) AS upname, artist AS id
		FROM musicbrainz.artist_alias
	UNION
	SELECT DISTINCT sort_name AS name, UPPER(sort_name) AS upname, artist AS id
		FROM musicbrainz.artist_alias;
/*
SELECT 2.361.272
*/

CREATE INDEX trgm_idx_mballar ON ws.mb_artistnames USING GIN (name gin_trgm_ops);
CREATE INDEX gin_idx_mballar ON ws.mb_artistnames USING GIN(to_tsvector('mb_simple', name));
CREATE INDEX idx_name_mballar ON ws.mb_artistnames (name);
CREATE INDEX idx_name_mballarup ON ws.mb_artistnames (upname);
CREATE INDEX idx_id_mballar ON ws.mb_artistnames (id);

CREATE INDEX mballar_vpat_idx ON ws.mb_artistnames (upname varchar_pattern_ops);
CREATE INDEX mballar_trgm_idx ON ws.mb_artistnames USING GIN (upname gin_trgm_ops);
CREATE INDEX mballar_gin_idx ON ws.mb_artistnames USING GIN(to_tsvector('mb_simple', upname));
CREATE INDEX mballar_trgmgis_idx ON ws.mb_artistnames USING gist (upname gist_trgm_ops);
CREATE INDEX mballar_trgm_idx_70 ON ws.mb_artistnames USING GIN (upname gin_trgm_ops) WHERE CHAR_LENGTH(upname)<70;

SELECT * FROM ws.mb_artistnames LIMIT 100;

SELECT CHAR_LENGTH(name), COUNT(*) FROM ws.mb_artistnames GROUP BY CHAR_LENGTH(name) ORDER BY CHAR_LENGTH(name) DESC;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE WITH WS Artist names that do not have a MB ID
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Artist to find 1 
DROP TABLE IF EXISTS ws.artists_tf1;
CREATE TABLE ws.artists_tf1 AS
SELECT a.wsid, a.wsname, UPPER(a.wsname) AS uwsname, a.genres, a.rwsids, a.rmbids, a.percenmbids, a.gid 
	FROM ws.artistsmb_unique a 
	WHERE a.gid IS NULL;
/*
SELECT 30338
*/

\d ws.artists_tf1
CREATE INDEX trgm_idx_wsafind ON ws.artists_tf1 USING GIN (wsname gin_trgm_ops);
CREATE INDEX gin_idx_wsafind ON ws.artists_tf1 USING GIN(to_tsvector('mb_simple', wsname));
CREATE INDEX idx_name_wsafind ON ws.artists_tf1 (wsname);
CREATE INDEX idx_uname_wsafind ON ws.artists_tf1 (uwsname);
CREATE INDEX idx_id_wsafind ON ws.artists_tf1 (wsid);

SELECT * FROM ws.artists_tf1 LIMIT 100;

-- SIMPLE MATCHING BASED ON UPPER CASE NAMES AND EXACT MATCHING
DROP TABLE IF EXISTS ws.artists_tf1_done;
CREATE TABLE ws.artists_tf1_done AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1 a
INNER JOIN ws.mb_artistnames b
ON a.uwsname=b.upname;
/*
SELECT 24311
Time: 823,979 ms
*/

CREATE INDEX atf1d_idx_id ON ws.artists_tf1_done (wsid);

SELECT COUNT(DISTINCT wsid) FROM ws.artists_tf1_done; 
/*
 count 
-------
 11232
(1 row)

Time: 10,961 ms
*/




SELECT * FROM ws.artists_tf1_done LIMIT 100; 

-----------------------------------------------------------------------------------------
-- Artist to find 2: After deleting the exact matching cases
DROP TABLE IF EXISTS ws.artists_tf2;
CREATE TABLE ws.artists_tf2 AS
SELECT a.*
	FROM ws.artists_tf1 a 
	LEFT JOIN ws.artists_tf1_done b
	ON a.wsid = b.wsid	
	WHERE b.wsid IS NULL;
/*
SELECT 19106
*/


CREATE INDEX atf2_trgm_idx ON ws.artists_tf2 USING GIN (uwsname gin_trgm_ops);
CREATE INDEX atf2_gin_idx ON ws.artists_tf2 USING GIN(to_tsvector('mb_simple', uwsname));
CREATE INDEX atf2_vpat_idx ON ws.artists_tf2 (uwsname varchar_pattern_ops);
CREATE INDEX atf2_idx_name ON ws.artists_tf2 (uwsname);
CREATE INDEX atf2_idx_id ON ws.artists_tf2 (wsid);

SELECT * FROM ws.artists_tf2 LIMIT 100; 

-- To optimize the search, I will limit the possible matches by creating a group of small

	-- See maximum char_legth of names
	SELECT CHAR_LENGTH(wsname), COUNT(*) FROM ws.artists_tf2 GROUP BY CHAR_LENGTH(wsname) ORDER BY CHAR_LENGTH(wsname) DESC;

DROP TABLE IF EXISTS ws.artists_tf2_done;
CREATE TABLE ws.artists_tf2_done AS
SELECT a.wsid, a.wsname, c.name AS mbname, c.id AS mbid 
FROM ws.artists_tf2 a
,   LATERAL (
   SELECT b.name, b.id
   FROM   ws.mb_artistnames b
   WHERE  a.uwsname % b.upname
   ORDER  BY a.uwsname <-> b.upname
   LIMIT  5                  
   ) c
ORDER  BY 1;
/*
SELECT 93126
*/

CREATE INDEX atf2d_idx_id ON ws.artists_tf2_done (wsid);

SELECT COUNT(DISTINCT wsid) FROM ws.artists_tf2_done; 
/*
 count 
-------
 18876
(1 row)

19106- 18876=230
*/

\d ws.artists_tf2_done

SELECT * FROM ws.artists_tf2_done LIMIT 100; 

-----------------------------------------------------------------------------------------
-- Artist to find 3: After deleting the five-milit approximation
DROP TABLE IF EXISTS ws.artists_tf3;
CREATE TABLE ws.artists_tf3 AS
SELECT a.*
	FROM ws.artists_tf2 a 
	LEFT JOIN ws.artists_tf2_done b
	ON a.wsid = b.wsid	
	WHERE b.wsid IS NULL;


CREATE INDEX atf3_trgm_idx ON ws.artists_tf3 USING GIN (uwsname gin_trgm_ops);
CREATE INDEX atf3_gin_idx ON ws.artists_tf3 USING GIN(to_tsvector('mb_simple', uwsname));
CREATE INDEX atf3_vpat_idx ON ws.artists_tf3 (uwsname varchar_pattern_ops);
CREATE INDEX atf3_idx_name ON ws.artists_tf3 (uwsname);
CREATE INDEX atf3_idx_id ON ws.artists_tf3 (wsid);

\d ws.artists_tf3
SELECT * FROM ws.artists_tf3 LIMIT 100;
 
SELECT CHAR_LENGTH(wsname), COUNT(*) FROM ws.artists_tf3 GROUP BY CHAR_LENGTH(wsname) ORDER BY CHAR_LENGTH(wsname) DESC;

DROP TABLE IF EXISTS ws.artists_tf3_done;
CREATE TABLE ws.artists_tf3_done AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf3 a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 < 0.4
WHERE CHAR_LENGTH(b.upname)<70;

SELECT COUNT(DISTINCT wsid) FROM ws.artists_tf3_done; 

SELECT * FROM ws.artists_tf3_done LIMIT 100; 
