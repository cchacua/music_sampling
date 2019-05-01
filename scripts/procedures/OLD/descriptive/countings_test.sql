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


-- Retrieving songs that have MB_ID but that cannot be joint

-- Counting recording_ID
SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
FROM musicbrainz.whois b;
/*
 count 
-------
 74740
(1 row)
*/

-- COUNTING MB_ID
SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid;

SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            LEFT JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid
			    WHERE a.gid IS NULL AND b.source_track_musicbrainz_id IS NOT NULL;
-- 734 MISSING

SELECT b.*
                            FROM musicbrainz.whois b
                            LEFT JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid
			    WHERE a.gid IS NULL AND b.source_track_musicbrainz_id IS NOT NULL;

--------------------------------------------------------------------------------------------------
-- Counting track ID
SELECT COUNT(DISTINCT b.source_track_id)
FROM musicbrainz.whois b
WHERE b.source_track_musicbrainz_id IS NOT NULL;
/*
 count 
-------
 75697
(1 row)
*/

SELECT COUNT(a.*)
FROM (
	SELECT DISTINCT b.source_track_id, b.source_track_musicbrainz_id
		FROM musicbrainz.whois b
		WHERE b.source_track_musicbrainz_id IS NOT NULL) a;
/*
 count 
-------
 75697
(1 row)
*/

SELECT COUNT(DISTINCT b.source_track_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid;
/* count 
-------
 74951
(1 row)
*/


SELECT COUNT(DISTINCT b.source_track_id)
                            FROM musicbrainz.whois b
                            LEFT JOIN musicbrainz.recording a
                            ON b.source_track_musicbrainz_id=a.gid
			    WHERE a.gid IS NULL AND b.source_track_musicbrainz_id IS NOT NULL;

/*
 count 
-------
   746
(1 row)
*/


SELECT COUNT(DISTINCT b.source_track_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording_gid_redirect a
                            ON b.source_track_musicbrainz_id=a.gid;

/*
 count 
-------
   741
(1 row)
*/

-- JOIN 
SELECT COUNT(e.source_track_id)
FROM (
	SELECT DISTINCT b.source_track_id
		                    FROM musicbrainz.whois b
		                    INNER JOIN musicbrainz.recording a
		                    ON b.source_track_musicbrainz_id=a.gid
	UNION
	SELECT DISTINCT c.source_track_id
		                    FROM musicbrainz.whois c
		                    INNER JOIN musicbrainz.recording_gid_redirect d
		                    ON c.source_track_musicbrainz_id=d.gid) e;


-- This coincides with the number of songs
SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            LEFT JOIN musicbrainz.recording_gid_redirect a
                            ON b.source_track_musicbrainz_id=a.gid;

SELECT COUNT(DISTINCT b.source_track_musicbrainz_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording_gid_redirect a
                            ON b.source_track_musicbrainz_id=a.gid;

SELECT COUNT(DISTINCT b.source_track_id)
                            FROM musicbrainz.whois b
                            INNER JOIN musicbrainz.recording_gid_redirect a
                            ON b.source_track_musicbrainz_id=a.gid;
