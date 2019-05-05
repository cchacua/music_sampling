\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 02-List of other recordings not in ws.matchname1
-- Assuming that artist in ws.matchname1 are true matches, 
-- get all the recordings in ws and mb and do a fuzzy match of recordings of those artists
---------------------------------------------------------------------

\d ws.artist_matchname2
\d ws.wsrec_wsart
\d ws.matchname1

DROP TABLE IF EXISTS ws.recording_matchname2;
CREATE TABLE ws.recording_matchname2 AS
SELECT DISTINCT b.wsrecording, a.mbartist, a.wsartist
FROM ws.matchname1 a
INNER JOIN ws.wsrec_wsart b
ON a.wsartist=b.wsartist
LEFT OUTER JOIN ws.matchname1 c
ON b.wsrecording=c.wsrecording
WHERE c.wsrecording IS NULL;
/*
SELECT 76619
Time: 11142,614 ms (00:11,143)
*/

SELECT * FROM ws.recording_matchname2 LIMIT 100;
SELECT * FROM ws.matchname1 WHERE wsrecording=57;

CREATE INDEX wsrecordingmatchname2_wsrecordingx ON ws.recording_matchname2 (wsrecording);
CREATE INDEX wsrecordingmatchname2_mbartistx ON ws.recording_matchname2 (mbartist);
CREATE INDEX wsrecordingmatchname2_wsartistx ON ws.recording_matchname2 (wsartist);




