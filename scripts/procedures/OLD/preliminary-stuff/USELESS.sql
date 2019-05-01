

/*
DROP TABLE IF EXISTS ws.artists_tf1_done;
CREATE TABLE ws.artists_tf1_done AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1_test a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(a.wsname, b.name) < 2
WHERE CHAR_LENGTH(b.name)<100;
*/

DROP TABLE IF EXISTS ws.artists_tf1_done;
CREATE TABLE ws.artists_tf1_done AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1_test a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(upper(a.wsname), b.upname)/greatest(length(a.wsname), length(b.upname))::FLOAT8 < 0.4
WHERE CHAR_LENGTH(b.name)<100;


DROP TABLE IF EXISTS ws.artists_tf1_done;
CREATE TABLE ws.artists_tf1_done AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1_test a
INNER JOIN ws.mb_artistnames b
ON similarity(a.wsname, b.name)>0.9
WHERE CHAR_LENGTH(b.name)<100;

SELECT * FROM ws.artists_tf1_done LIMIT 100;


DROP TABLE IF EXISTS ws.artists_tf1_test;
CREATE TABLE ws.artists_tf1_test AS
SELECT a.wsid, a.wsname, UPPER(a.wsname) AS uwsname, a.genres, a.rwsids, a.rmbids, a.percenmbids, a.gid 
FROM ws.artists_tf2 a
WHERE CHAR_LENGTH(a.wsname)<30
LIMIT 10;



SELECT * FROM ws.artists_tf1_test LIMIT 10;

CREATE INDEX atf1t_trgm_idx ON ws.artists_tf1_test USING GIN (uwsname gin_trgm_ops);
CREATE INDEX atf1t_gin_idx ON ws.artists_tf1_test USING GIN(to_tsvector('mb_simple', uwsname));
CREATE INDEX atf1t_idx_name ON ws.artists_tf1_test (uwsname);
CREATE INDEX atf1t_idx_id ON ws.artists_tf1_test (wsid);
CREATE INDEX atf1t_vpat_idx ON ws.artists_tf1_test (uwsname varchar_pattern_ops);
CREATE INDEX atf1t_idx_id_name ON ws.artists_tf1_test (wsid, wsname);


\d ws.artists_tf1_test

SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1_test a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 < 0.4
WHERE CHAR_LENGTH(b.name)<30 AND CHAR_LENGTH(a.uwsname)<30;
/*
- with lev>0.1
Time: 47974,326 ms (00:47,974)

- With lev>0.4
Time: 43795,536 ms (00:43,796)

- with 10char and lev>0.4
Time: 5979,067 ms (00:05,979)
*/


\d ws.artists_tf1_test

EXPLAIN ANALYZE SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf1_test a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 < 0.4
WHERE CHAR_LENGTH(b.upname)<70;


EXPLAIN ANALYZE SELECT a.wsid, a.wsname, c.name AS mbname, c.id AS mbid, c.dis 
FROM ws.artists_tf1_test a
,   LATERAL (
   SELECT b.name, b.id, LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 AS dis
   FROM   ws.mb_artistnames b
   WHERE  CHAR_LENGTH(b.upname)<70 AND LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 < 0.4
   ORDER  BY dis 
   LIMIT 5           
   ) c
ORDER  BY 1;


EXPLAIN ANALYZE SELECT a.wsid, a.wsname, c.name AS mbname, c.id AS mbid 
FROM ws.artists_tf1_test a
,   LATERAL (
   SELECT b.name, b.id
   FROM   ws.mb_artistnames b
   WHERE  a.uwsname % b.upname
   ORDER  BY a.uwsname <-> b.upname
   LIMIT  5                  
   ) c
ORDER  BY 1;




-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- OLD to delete- USING 10 CHAR LIMIT AND 0.4


DROP TABLE IF EXISTS ws.artists_tf2_done_10C;
CREATE TABLE ws.artists_tf2_done_10C AS
SELECT DISTINCT a.wsid, a.wsname, b.name AS mbname, b.id AS mbid 
FROM ws.artists_tf2 a
INNER JOIN ws.mb_artistnames b
ON LEVENSHTEIN(a.uwsname, b.upname)/greatest(length(a.uwsname), length(b.upname))::FLOAT8 < 0.4
WHERE CHAR_LENGTH(b.name)<10 AND CHAR_LENGTH(a.uwsname)<10;

/*15:43 - 16:24
SELECT 318.561
*/











-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Funtion to get possible artists and save into the table
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION ws.get_artist() 
 RETURNS void AS $$
DECLARE 
    r record;
BEGIN
 FOR r IN(
	SELECT a.wsid, a.wsname
		FROM ws.artists_tf1 a
		LIMIT 3)  
 LOOP
	EXECUTE format('INSERT INTO ws.temp_out(wsid_, wsname_, mbid, mbname, levdis)
			SELECT %1$L, %2$L, a.id::INT, a.string, a.distance
				FROM ws.dlevenshteintablenrows(%2$L, 5, %3$L, %4$L, %5$L ) a' , 
				r.wsid, r.wsname, 'ws.mb_artistnames', 'name', 'id');
 END LOOP;
END; $$ 
LANGUAGE 'plpgsql';

-- OPTION 2
CREATE OR REPLACE FUNCTION ws.get_artist() 
 RETURNS void AS $$
DECLARE 
    r record;
BEGIN
 FOR r IN(
	SELECT a.wsid, a.wsname
		FROM ws.artists_tf1 a
		LIMIT 3)  
 LOOP
	INSERT INTO ws.temp_out(wsid_, wsname_, mbid, mbname, levdis)	
	SELECT  r.wsid, r.wsname, a.id, a.name,
		levenshtein(upper(a.name), upper(r.wsname))/greatest(length(a.name), length(r.wsname))::FLOAT8 AS dis
	     FROM ws.mb_artistnames a
	     WHERE CHAR_LENGTH(a.name)<100
	     ORDER BY dis
	     LIMIT  5;
 END LOOP;
END; $$ 
LANGUAGE 'plpgsql';






DROP TABLE IF EXISTS ws.temp_out;
CREATE TABLE ws.temp_out (
wsid_ INT, 
wsname_ VARCHAR(100),
mbid INT,
mbname VARCHAR(254),
levdis FLOAT8
);

SELECT * FROM ws.get_artist();
SELECT * FROM ws.temp_out;
/*

Time for 100: 672437,394 ms (11:12,437)
*/

-- ADD ALSO A ROW LOMIT IN THE dlevenshteintable TABLE AND TAKE THE ONLY FIRST 5 OR 10 OBS

/*
 simil FLOAT8
SELECT '1286' AS wsid, 'Farid El Atrache' AS wsname, a.*, similarity(UPPER('Farid El Atrache'), UPPER(a.string)) AS simi FROM ws.dlevenshteintable('Farid El Atrache', 0.4, 'ws.mb_artistnames', 'name', 'id') a;

*/
