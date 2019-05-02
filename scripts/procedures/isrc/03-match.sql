\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 01 - Exact matching of recording names
---------------------------------------------------------------------

DROP TABLE IF EXISTS ws.recording_matchname1;
CREATE TABLE ws.recording_matchname1 AS
SELECT DISTINCT a.uname, b.name, a.id AS wsrecording, b.recording AS mbrecording, b.isrc
FROM ws.recording a
INNER JOIN ws.mb_rec_isrc b
ON a.uname=b.uname;
/*
SELECT 3175863
Time: 18090,298 ms (00:18,090)
*/

SELECT * FROM ws.recording_matchname1 OFFSET 100000 LIMIT 100;

SELECT COUNT(DISTINCT wsrecording) FROM ws.recording_matchname1;
/*
 count  
--------
 215748
(1 row)
*/

SELECT COUNT(DISTINCT isrc) FROM ws.recording_matchname1;
/*
 count  
--------
 213265
(1 row)
*/

SELECT COUNT(DISTINCT mbrecording) FROM ws.recording_matchname1;
/*
 count  
--------
 212244
(1 row)
*/


