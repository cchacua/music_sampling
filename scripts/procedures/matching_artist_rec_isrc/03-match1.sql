\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 01 - Matching using the ws database (a relationship that we assume as true)
---------------------------------------------------------------------

\d ws.recording_matchname1
\d ws.wsrec_wsart
\d ws.artist_matchname1

DROP TABLE IF EXISTS ws.wsmatchname1;
CREATE TABLE ws.wsmatchname1 AS
SELECT DISTINCT a.wsrecording, a.mbrecording, a.isrc, c.wsartist, c.mbartist
FROM ws.recording_matchname1 a
INNER JOIN ws.wsrec_wsart b
ON a.wsrecording=b.wsrecording
INNER JOIN ws.artist_matchname1 c
ON b.wsartist=c.wsartist;

/*
SELECT 4725511
Time: 11072,015 ms (00:11,072)
*/

SELECT COUNT(DISTINCT wsrecording) FROM ws.wsmatchname1;
/*
 count  
--------
 192358
(1 row)

Time: 2848,012 ms (00:02,848)
*/

SELECT * FROM ws.wsmatchname1 LIMIT 100;

CREATE INDEX wsmatchname1_mbrecordingx ON ws.wsmatchname1 (mbrecording);
CREATE INDEX wsmatchname1_mbartistx ON ws.wsmatchname1 (mbartist);

DROP TABLE IF EXISTS ws.wsmatchname1_rec;
CREATE TABLE ws.wsmatchname1_rec AS
SELECT DISTINCT a.wsrecording, a.mbrecording, a.isrc
FROM ws.wsmatchname1 a;
/*
SELECT 2767379
Time: 5739,580 ms (00:05,740)
*/

CREATE INDEX wsmatchname1rec_mbrecordingx ON ws.wsmatchname1_rec (mbrecording);

DROP TABLE IF EXISTS ws.wsmatchname1_art;
CREATE TABLE ws.wsmatchname1_art AS
SELECT DISTINCT a.wsartist, a.mbartist
FROM ws.wsmatchname1 a;
/*
SELECT 76574
Time: 5545,316 ms (00:05,545)
*/

CREATE INDEX wsmatchname1art_mbartistx ON ws.wsmatchname1_art (mbartist);

---------------------------------------------------------------------
-- 02 - Matching using the MB database (a relationship that is (ceteris paribus) true)
---------------------------------------------------------------------

\d ws.wsmatchname1
\d musicbrainz.recording
\d musicbrainz.artist_credit_name

DROP TABLE IF EXISTS ws.mbmatchname1;
CREATE TABLE ws.mbmatchname1 AS
SELECT DISTINCT a.wsrecording, a.mbrecording, a.isrc, d.wsartist, d.mbartist
FROM ws.wsmatchname1_rec a
INNER JOIN musicbrainz.recording b
ON a.mbrecording=b.id
INNER JOIN musicbrainz.artist_credit_name c
ON b.artist_credit=c.artist_credit
INNER JOIN ws.wsmatchname1_art d
ON c.artist=d.mbartist;
/*
SELECT 2303687
Time: 22610,407 ms (00:22,610)
*/

SELECT COUNT(DISTINCT wsrecording) FROM ws.mbmatchname1;
/*
 count  
--------
 184193
(1 row)
*/

SELECT * FROM ws.mbmatchname1 LIMIT 100;

SELECT * FROM ws.wsrec_wsart LIMIT 100;


CREATE INDEX mbmatchname1_wsrecordingx ON ws.mbmatchname1 (wsrecording);
CREATE INDEX mbmatchname1_wsartistx ON ws.mbmatchname1 (wsartist);


---------------------------------------------------------------------
-- 03 - Matching mbmatchname1 and 
---------------------------------------------------------------------

\d ws.mbmatchname1 
\d ws.wsrec_wsart

DROP TABLE IF EXISTS ws.matchname1;
CREATE TABLE ws.matchname1 AS
SELECT DISTINCT a.wsrecording, a.mbrecording, a.isrc, a.wsartist, a.mbartist
	FROM ws.mbmatchname1 a
	INNER JOIN ws.wsrec_wsart b
	ON a.wsrecording=b.wsrecording AND a.wsartist=b.wsartist;
/*
SELECT 79548
Time: 967,906 ms
*/

SELECT COUNT(DISTINCT wsrecording) FROM ws.matchname1;
/*
 count 
-------
 50552
(1 row)
*/

SELECT * FROM ws.matchname1 WHERE wsrecording=3 LIMIT 10;

-- TO DO: The first step is not necessary and the tables of artist and recordings my be used directly

