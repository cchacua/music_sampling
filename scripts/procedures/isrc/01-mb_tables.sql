\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- Count distinct ISRC
---------------------------------------------------------------------
SELECT COUNT(DISTINCT recording) FROM musicbrainz.isrc;
/*
 count  
--------
 899713
(1 row)

*/

SELECT COUNT(DISTINCT id) FROM musicbrainz.recording;
/*
  count   
----------
 20196860
(1 row)

Time: 24334,543 ms (00:24,335)

899713/20196860=0.04454717

So, in terms of coverage, only around 4.4% of songs in MB have an ISRC ID
*/

---------------------------------------------------------------------
-- Keep only the recordings that have a isrc code from the recording table
-- And add the alternative names
---------------------------------------------------------------------

\d musicbrainz.recording
\d musicbrainz.recording_alias

DROP TABLE IF EXISTS ws.mb_rec_isrc;
CREATE TABLE ws.mb_rec_isrc AS
SELECT a.recording, a.isrc, b.name, UPPER(b.name) AS uname
	FROM musicbrainz.isrc a 
	INNER JOIN (
		SELECT DISTINCT recording, sort_name AS name
			FROM musicbrainz.recording_alias
			WHERE name<>sort_name
		UNION 
		SELECT DISTINCT recording, name
			FROM musicbrainz.recording_alias
		UNION 
		SELECT DISTINCT id AS recording, name
			FROM musicbrainz.recording) b
	ON a.recording=b.recording;
/*
SELECT 1016659
Time: 60051,784 ms (01:00,052)
*/

CREATE INDEX wsmb_rec_isrc_unamex1 ON ws.mb_rec_isrc USING GIN (uname gin_trgm_ops);
CREATE INDEX wsmb_rec_isrc_unamex2 ON ws.mb_rec_isrc USING GIN(to_tsvector('mb_simple', uname));
CREATE INDEX wsmb_rec_isrc_unamex3 ON ws.mb_rec_isrc (uname);
CREATE INDEX wsmb_rec_isrc_recordingx ON ws.mb_rec_isrc (recording);
CREATE INDEX wsmb_rec_isrc_isrcx ON ws.mb_rec_isrc (isrc);

