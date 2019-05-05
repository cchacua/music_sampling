---------------------------------------------------------------------
-- 02 - Fuzzy matching of artist names
---------------------------------------------------------------------
\d ws.artist
\d ws.mb_artist_name
DROP TABLE IF EXISTS ws.artist_matchname2;
CREATE TABLE ws.artist_matchname2 AS
SELECT DISTINCT a.uname, b.name, a.id AS wsartist, b.artist AS mbartist
FROM (SELECT c.* FROM ws.artist c LIMIT 100) a
INNER JOIN ws.mb_artist_name b
ON ws.levenshtein(a.uname, b.uname)/greatest(length(a.uname), length(b.uname))::FLOAT8 < 0.1
WHERE CHAR_LENGTH(b.uname)<254;
