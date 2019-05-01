\connect musicbrainz;
\timing
---------------------------------------------------------------------
-- Count distinct ISRC
---------------------------------------------------------------------
SELECT COUNT(DISTINCT id) FROM musicbrainz.isrc;
/*
 count  
--------
 924.178
(1 row)

Time: 757,642 ms
*/


---------------------------------------------------------------------
-- Keep only the recordings that have a isrc code from the recording table
-- And add the alternative names
---------------------------------------------------------------------



DROP TABLE IF EXISTS ws.mb_isrc;
CREATE TABLE ws.mb_isrc AS
SELECT a.id
	FROM musicbrainz.isrc a
	INNER JOIN musicbrainz.recording b
	ON a.id=b.id;
/*
AS wsid, a.name AS wsname, UPPER(a.name) AS uwsname, a.genres, a.rwsids, a.rmbids, a.percenmbids, a.gid 
*/
