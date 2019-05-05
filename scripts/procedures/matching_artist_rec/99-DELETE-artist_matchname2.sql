
\d ws.matchname1
\d ws.wsrec_wsart

DROP TABLE IF EXISTS ws.artist_matchname2;
CREATE TABLE ws.artist_matchname2 AS
SELECT DISTINCT a.wsartist, a.mbartist
	FROM ws.matchname1 a
	ORDER BY a.mbartist;
/*
SELECT 49620
Time: 1050,259 ms (00:01,050)
*/

CREATE INDEX artistmatchname2_wsartistx ON ws.artist_matchname2 (wsartist);
CREATE INDEX artistmatchname2_mbartistx ON ws.artist_matchname2 (mbartist);

SELECT * FROM ws.artist_matchname2 LIMIT 100;

SELECT a.wsartist, a.mbartist, b.name, c.name AS wsname
	FROM ws.artist_matchname2 a
	INNER JOIN musicbrainz.artist b
	ON a.mbartist=b.id
	INNER JOIN ws.artist c
	ON a.wsartist=c.id
	ORDER BY mbartist 
	LIMIT 100;
