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
-- 01 - Exact matching of artist names
---------------------------------------------------------------------

DROP TABLE IF EXISTS ws.artist_matchname1;
CREATE TABLE ws.artist_matchname1 AS
SELECT DISTINCT a.uname, b.name, a.id AS wsartist, b.artist AS mbartist
FROM ws.artist a
INNER JOIN ws.mb_artist_name b
ON a.uname=b.uname;
/*
SELECT 114384
Time: 1447,584 ms (00:01,448)
*/

SELECT * FROM ws.artist_matchname1 OFFSET 100000 LIMIT 100;

SELECT COUNT(DISTINCT wsartist) FROM ws.artist_matchname1;
/*
 count 
-------
 69487
(1 row)

69487/92159=0.7539904
*/

SELECT COUNT(DISTINCT mbartist) FROM ws.artist_matchname1;
/*
 count  
--------
 111922
(1 row)
*/

CREATE INDEX artistmatchname1_wsartistx ON ws.artist_matchname1 (wsartist);
CREATE INDEX artistmatchname1_mbartistx ON ws.artist_matchname1 (mbartist);


