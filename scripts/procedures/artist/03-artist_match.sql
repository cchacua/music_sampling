\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Artist_match
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

\d musicbrainz.artist
\d ws.artist


SELECT COUNT(DISTINCT id) FROM musicbrainz.artist;
/*  count  
---------
 1474065
(1 row)

Time: 1334,570 ms (00:01,335)
*/

---------------------------------------------------------------------
-- 01 - Exact matching of recording names
---------------------------------------------------------------------

DROP TABLE IF EXISTS ws.artist_matchname1;
CREATE TABLE ws.artist_matchname1 AS
SELECT DISTINCT a.uname, b.name, a.id AS wsrecording, b.recording AS mbrecording, b.isrc
FROM ws.recording a
INNER JOIN ws.mb_rec_isrc b
ON a.uname=b.uname;
