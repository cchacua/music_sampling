-----------------------------------------------------------------------------------------
-- CREATE SCHEMA ws;

CREATE OR REPLACE FUNCTION ws.dlevestein(IN namevalue VARCHAR, IN threshold float8)
	RETURNS TABLE (
			artist_name VARCHAR, 
			distance float8) 
	AS $$
	BEGIN
		RETURN QUERY SELECT  main_artist_name, 
		levenshtein(upper(main_artist_name), upper(namevalue))/greatest(length(main_artist_name), length(namevalue))::REAL AS dis
	     FROM ws.artists
	     WHERE levenshtein(upper(main_artist_name), upper(namevalue))/greatest(length(main_artist_name), length(namevalue))::REAL  < threshold
	     ORDER BY main_artist_name, dis;
	END;
	$$
	LANGUAGE 'plpgsql';

SELECT * FROM ws.dlevestein('Willie Colon', 0.1);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- FUNCTION TO COMPUTE levenshtein DISTANCE FOR TWO STRINGS
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ws.dlevenshteinstring(IN namestring1 VARCHAR, IN namestring2 VARCHAR, IN threshold FLOAT8)
	RETURNS TABLE (distance FLOAT8) 
	AS $$
	BEGIN
		RETURN QUERY
		EXECUTE format('SELECT levenshtein(upper(%1$L), upper(%2$L))/greatest(length(%1$L), length(%2$L))::FLOAT8 AS dis
	     WHERE CHAR_LENGTH(%1$L)<254 AND CHAR_LENGTH(%2$L)<254 AND levenshtein(upper(%1$L), upper(%2$L))/greatest(length(%1$L), length(%1$L))::FLOAT8  < %3$s
	     ORDER BY dis', namestring1, namestring2, threshold);
	END;
	$$
	LANGUAGE 'plpgsql';

SELECT * FROM ws.dlevenshteinstring('Willie Colon', 'Willie Colón', 1 );
SELECT ws.dlevenshteinstring('Willie Colon', 'Willie Colón', 1 );

select metaphone('조성모',5);
select metaphone('Jo Sung Mo',5);

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- FUNCTION THAT EXTRACT SIMILAR VALUES AND IDS 
-- ATTENTION: HERE I AM CONSIDERING ONLY STRINGS WITH LESS THAN 250 CHARACTERS, BECAUSE OF THE LIMITS OF THE levenshtein FUNCTION
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION ws.dlevestein(IN namevalue VARCHAR, IN threshold FLOAT8, IN _tablename regclass, IN _columname TEXT, IN _columnid TEXT)
	RETURNS TABLE ( id VARCHAR,
			string VARCHAR, 
			distance FLOAT8) 
	AS $$
	BEGIN
		RETURN QUERY
		EXECUTE format('SELECT %5$s::VARCHAR,  %4$s, 
		levenshtein(upper(%4$s), upper(%2$L))/greatest(length(%4$s), length(%2$L))::FLOAT8 AS dis
	     FROM %1$s
	     WHERE CHAR_LENGTH(%4$s)<250 AND levenshtein(upper(%4$s), upper(%2$L))/greatest(length(%4$s), length(%2$L))::FLOAT8  < %3$s
	     ORDER BY dis', _tablename, namevalue, threshold, _columname, _columnid);
	END;
	$$
	LANGUAGE 'plpgsql';

SELECT * FROM ws.dlevestein('Willie Colon', 0.1, 'ws.artists', 'main_artist_name', 'main_artist_musicbrainz_id');

SELECT * FROM ws.dlevestein('SNOOP DOG', 0.2, 'musicbrainz.artist', 'name', 'gid');

SELECT * FROM ws.dlevestein('1986 Omega Tribe', 0.4, 'musicbrainz.artist', 'name', 'gid');
SELECT * FROM ws.dlevestein('1986 オメガトライブ', 0.4, 'musicbrainz.artist', 'name', 'gid');
SELECT * FROM ws.dlevestein('1986 オメガトライブ', 0.4, 'musicbrainz.artist_alias', 'name', 'artist');
SELECT * FROM ws.dlevestein('1986 Omega Tribe', 0.4, 'musicbrainz.artist_alias', 'name', 'artist');


	
DROP TABLE IF EXISTS ws.mbtemp;
CREATE TABLE ws.mbtemp AS
SELECT * FROM ws.dlevestein('SNOOP DOGG', 0.4, 'musicbrainz.artist', 'name', 'id');
CREATE INDEX mbtempid ON ws.mbtemp (id);

SELECT * FROM ws.mbtemp;
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- QUERY TO EXTRACT MB SONGS OF AN ARTIST
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
SELECT DISTINCT a.id, c.name
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.artist_credit_name b
	ON a.id::INT=b.artist
	INNER JOIN musicbrainz.recording c
	ON b.artist_credit=c.artist_credit
	ORDER BY a.id, c.name;

-- QUERY TO EXTRACT WORKS using link artist-work

SELECT DISTINCT a.id, a.string, b.entity1, c.name
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.l_artist_work b
	ON a.id::INT=b.entity0
	INNER JOIN musicbrainz.work c
	ON b.entity1=c.id
	ORDER BY a.id;

-- QUERY TO EXTRACT WORKS using link artist-recording-work

SELECT DISTINCT a.id, e.name, c.name, e.gid
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.artist_credit_name b
	ON a.id::INT=b.artist
	INNER JOIN musicbrainz.recording c
	ON b.artist_credit=c.artist_credit
	INNER JOIN musicbrainz.l_recording_work d
	ON c.id=d.entity0
	INNER JOIN musicbrainz.work e
	ON d.entity1=e.id
	ORDER BY a.id, e.name;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- QUERY TO EXTRACT WORKS using link artist-recording-work AND artist-work
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

SELECT DISTINCT a.id, c.name, c.gid
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.l_artist_work b
	ON a.id::INT=b.entity0
	INNER JOIN musicbrainz.work c
	ON b.entity1=c.id
UNION ALL
SELECT DISTINCT a.id, e.name, e.gid
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.artist_credit_name b
	ON a.id::INT=b.artist
	INNER JOIN musicbrainz.recording c
	ON b.artist_credit=c.artist_credit
	INNER JOIN musicbrainz.l_recording_work d
	ON c.id=d.entity0
	INNER JOIN musicbrainz.work e
	ON d.entity1=e.id;


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- For those artist in WS that have an MB_artist_ID, get the names
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

SELECT COUNT (DISTINCT main_artist_musicbrainz_id) FROM ws.artists;
/*
 count 
-------
 61097
(1 row)
*/

SELECT COUNT(DISTINCT f.main_artist_musicbrainz_id) 
FROM (
SELECT DISTINCT a.main_artist_musicbrainz_id 
	FROM ws.artists a
	INNER JOIN musicbrainz.artist b
	ON a.main_artist_musicbrainz_id=b.gid
UNION
SELECT DISTINCT a.main_artist_musicbrainz_id
	FROM ws.artists a
	INNER JOIN musicbrainz.artist_gid_redirect b
	ON a.main_artist_musicbrainz_id=b.gid) f;
/*
 count 
-------
 61089
(1 row)
*/

-- Get the names using bot artist and redirect artist
DROP TABLE IF EXISTS ws.artist_wsmb_names;
CREATE TABLE ws.artist_wsmb_names AS
SELECT DISTINCT a.main_artist_name, b.name, a.main_artist_musicbrainz_id, b.gid
	FROM ws.artists a
	INNER JOIN musicbrainz.artist b
	ON a.main_artist_musicbrainz_id=b.gid
UNION
SELECT DISTINCT a.main_artist_name, c.name, a.main_artist_musicbrainz_id, c.gid
	FROM ws.artists a
	INNER JOIN musicbrainz.artist_gid_redirect b
	ON a.main_artist_musicbrainz_id=b.gid
	INNER JOIN musicbrainz.artist c
	ON b.gid=c.gid
	ORDER BY 1;

SELECT * FROM ws.artists WHERE main_artist_musicbrainz_id='0af3229f-5885-4e06-9d79-9e7491e18d1f';
SELECT * FROM ws.records WHERE main_artist_musicbrainz_id='0af3229f-5885-4e06-9d79-9e7491e18d1f';

SELECT COUNT (DISTINCT gid) FROM ws.artist_wsmb_names;


-----------------------------------------------------------------------------------------

-- QUERY TO EXTRACT WORKS using link artist-recording-work using ISWC (incomplete information)

SELECT DISTINCT a.id, e.name, e.gid, f.iswc
	FROM ws.mbtemp a
	INNER JOIN musicbrainz.artist_credit_name b
	ON a.id::INT=b.artist
	INNER JOIN musicbrainz.recording c
	ON b.artist_credit=c.artist_credit
	INNER JOIN musicbrainz.l_recording_work d
	ON c.id=d.entity0
	INNER JOIN musicbrainz.work e
	ON d.entity1=e.id
	INNER JOIN musicbrainz.iswc f
	ON e.id=f.work
	ORDER BY a.id, e.name;

SELECT * FROM musicbrainz.artist_credit
LIMIT 100;

SELECT * FROM musicbrainz.artist_credit_name
LIMIT 100;

SELECT * FROM musicbrainz.recording
LIMIT 100;
