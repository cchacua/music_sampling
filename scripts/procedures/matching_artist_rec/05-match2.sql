\connect musicbrainz;
\timing

---------------------------------------------------------------------
-- 02 - Matching using the MB database (a relationship that is (ceteris paribus) true)
---------------------------------------------------------------------

\d ws.recording_matchname2
\d musicbrainz.artist_credit_name
\d musicbrainz.recording
\d ws.mb_recording_name
\d ws.recording

DROP TABLE IF EXISTS ws.matchname2;
CREATE TABLE ws.matchname2 AS
SELECT DISTINCT a.wsrecording, d.recording AS mbrecording, a.wsartist, a.mbartist, ws.levenshtein(d.uname, e.uname)/greatest(length(d.uname), length(e.uname))::FLOAT8 AS levdis
FROM (SELECT * FROM ws.recording_matchname2 z LIMIT 20) a
INNER JOIN musicbrainz.artist_credit_name b
ON a.mbartist=b.artist
INNER JOIN musicbrainz.recording c
ON b.artist_credit=c.artist_credit
INNER JOIN ws.mb_recording_name d
ON c.id=d.recording
INNER JOIN ws.recording e
ON a.wsrecording=e.id AND ws.levenshtein(d.uname, e.uname)/greatest(length(d.uname), length(e.uname))::FLOAT8 < 0.1
WHERE CHAR_LENGTH(d.uname)<255 AND CHAR_LENGTH(e.uname)<255
ORDER BY a.wsrecording, a.wsartist, levdis;
/*
Maybe I should replace II by 2 or something like that, using a dictionary
*/



SELECT DISTINCT a.wsrecording, d.recording AS mbrecording, d.uname, e.uname,  ws.levenshtein(d.uname, e.uname)/greatest(length(d.uname), length(e.uname))::FLOAT8 AS levdis
FROM (SELECT * FROM ws.recording_matchname2 z LIMIT 20) a
INNER JOIN musicbrainz.artist_credit_name b
ON a.mbartist=b.artist
INNER JOIN musicbrainz.recording c
ON b.artist_credit=c.artist_credit
INNER JOIN ws.mb_recording_name d
ON c.id=d.recording
INNER JOIN ws.recording e
ON a.wsrecording=e.id AND ws.levenshtein(d.uname, e.uname)/greatest(length(d.uname), length(e.uname))::FLOAT8 < 0.1
WHERE CHAR_LENGTH(d.uname)<255 AND CHAR_LENGTH(e.uname)<255
ORDER BY a.wsrecording, levdis;



-- TO DO: I may change recording_matchname2 and include also the found wsrecording, as to get more mbrecording codes with partial matching. However, this can increase the number of false positives, especially for songs named track ##, so I should use the leverage distance to ponderate or something 

