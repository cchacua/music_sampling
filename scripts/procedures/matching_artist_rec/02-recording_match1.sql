\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 01 - Exact matching of recording names
---------------------------------------------------------------------

\d ws.recording
\d ws.mb_recording_name

DROP TABLE IF EXISTS ws.recording_matchname1;
CREATE TABLE ws.recording_matchname1 AS
SELECT DISTINCT a.id AS wsrecording, b.recording AS mbrecording
FROM ws.recording a
INNER JOIN ws.mb_recording_name b
ON a.uname=b.uname;
/*
SELECT 76818215
Time: 370940,411 ms (06:10,940)
*/

SELECT * FROM ws.recording_matchname1 OFFSET 100000 LIMIT 100;


CREATE INDEX wsrecordingmatchname1_wsrecordingx ON ws.recording_matchname1 (wsrecording);
/*
Time: 84662,519 ms (01:24,663)
*/
CREATE INDEX wsrecordingmatchname1_mbrecordingx ON ws.recording_matchname1 (mbrecording);
/*
Time: 140589,244 ms (02:20,589)
*/


SELECT COUNT(DISTINCT wsrecording) FROM ws.recording_matchname1;
/*
 count  
--------
 345,663
(1 row)

Time: 47735,669 ms (00:47,736)

*/


SELECT COUNT(DISTINCT mbrecording) FROM ws.recording_matchname1;
/*
  count  
---------
 4,847,954
(1 row)

Time: 84603,619 ms (01:24,604)
*/

