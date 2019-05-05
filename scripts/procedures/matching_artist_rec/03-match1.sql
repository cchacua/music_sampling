\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 01 - Matching using the MB database (a relationship that is (ceteris paribus) true)
---------------------------------------------------------------------

\d ws.recording_matchname1
\d musicbrainz.recording
\d musicbrainz.artist_credit_name
\d ws.artist_matchname1
\d ws.wsrec_wsart 

DROP TABLE IF EXISTS ws.matchname1;
CREATE TABLE ws.matchname1 AS
SELECT DISTINCT a.wsrecording, a.mbrecording, d.wsartist, d.mbartist
FROM ws.recording_matchname1 a
INNER JOIN musicbrainz.recording b
ON a.mbrecording=b.id
INNER JOIN musicbrainz.artist_credit_name c
ON b.artist_credit=c.artist_credit
INNER JOIN ws.artist_matchname1 d
ON c.artist=d.mbartist
INNER JOIN ws.wsrec_wsart e
ON a.wsrecording=e.wsrecording AND d.wsartist=e.wsartist
ORDER BY a.wsrecording, d.wsartist;
/*
SELECT 1,087,932
Time: 101835,757 ms (01:41,836)
*/

SELECT COUNT(DISTINCT wsrecording) FROM ws.matchname1;
/*
 count  
--------
 242698
(1 row)
*/

SELECT COUNT(DISTINCT wsartist) FROM ws.matchname1;
/*
 count 
-------
 48760
(1 row)
*/


SELECT * FROM ws.matchname1 LIMIT 100;

SELECT * FROM ws.wsrec_wsart LIMIT 100;


CREATE INDEX matchname1_wsrecordingx ON ws.matchname1 (wsrecording);
CREATE INDEX matchname1_wsartistx ON ws.matchname1 (wsartist);
CREATE INDEX matchname1_mbrecordingx ON ws.matchname1 (mbrecording);
CREATE INDEX matchname1_mbartistx ON ws.matchname1 (mbartist);


SELECT a.wsrecording, a.mbrecording, b.name, b.gid 
	FROM ws.matchname1 a
	INNER JOIN musicbrainz.recording b
	ON a.mbrecording=b.id
	LIMIT 100;
