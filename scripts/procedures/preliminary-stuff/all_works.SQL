-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE WITH ALL WORK NAMES, ALIASES AND INTERNAL MB ID (IT ISN'T THE GID) 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- ONLY NAMES OF LENGTH<90 AS THE MAX IN THE WS TABLE IS 80
DROP TABLE IF EXISTS ws.mb_worknames;
CREATE TABLE ws.mb_worknames AS
	SELECT DISTINCT name, UPPER(name) AS upname, id
		FROM musicbrainz.work
		WHERE CHAR_LENGTH(name)<90
	UNION
	SELECT DISTINCT name, UPPER(name) AS upname, work AS id
		FROM musicbrainz.work_alias
		WHERE CHAR_LENGTH(name)<90
	UNION
	SELECT DISTINCT sort_name AS name, UPPER(sort_name) AS upname, work AS id
		FROM musicbrainz.work_alias
		WHERE name!=sort_name AND CHAR_LENGTH(sort_name)<90;

/*
SELECT 1.124.762
*/

CREATE INDEX mb_worknames_vpat_idx ON ws.mb_worknames (upname varchar_pattern_ops);
CREATE INDEX mb_worknames_trgm_idx ON ws.mb_worknames USING GIN (upname gin_trgm_ops);
CREATE INDEX mb_worknames_gin_idx ON ws.mb_worknames USING GIN(to_tsvector('mb_simple', upname));
CREATE INDEX mb_worknames_idx_id ON ws.mb_worknames (id);

\d ws.mb_worknames
SELECT * FROM ws.mb_worknames LIMIT 100;

SELECT CHAR_LENGTH(name), COUNT(*) FROM ws.mb_worknames GROUP BY CHAR_LENGTH(name) ORDER BY CHAR_LENGTH(name) DESC;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Works for the WS list of recordings
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.workrec;
CREATE TABLE ws.workrec AS
SELECT DISTINCT a.mbid, b.entity1 AS mbwid 
	FROM ws.records a
	INNER JOIN musicbrainz.l_recording_work b
	ON a.mbid=b.entity0;
/*
SELECT 81.023
*/

CREATE INDEX workrec_mbid_idx ON ws.workrec (mbid);
CREATE INDEX workrec_mbwid_idx ON ws.workrec (mbwid);

SELECT COUNT(DISTINCT mbid) FROM ws.workrec;
/*
 count 
-------
 80140
(1 row)
*/

SELECT COUNT(DISTINCT mbwid) FROM ws.workrec;
/*
 count 
-------
 48127
(1 row)
*/

DROP TABLE IF EXISTS ws.workrec_ext;
CREATE TABLE ws.workrec_ext AS
SELECT DISTINCT b.name AS mbwname, c.name AS wsname, c.main_artist_name, c.mbid, b.id, b.gid
	FROM ws.workrec a 
	INNER JOIN musicbrainz.work b ON a.mbwid=b.id 
	INNER JOIN ws.records c ON a.mbid=c.mbid
	ORDER BY b.id;
\copy ws.workrec_ext TO '/home/christian/github_new/music_sampling/output/workrec_ext.csv' with csv header QUOTE '"'

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- SELECT
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------



