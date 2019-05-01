-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table only artist info in WS 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.artist;
CREATE TABLE ws.artist AS
	SELECT DISTINCT
			a.des_main_artist_id AS id,
			a.des_main_artist_name AS name,
			UPPER(a.des_main_artist_name) AS uname
		FROM ws.main a
	UNION 
	SELECT DISTINCT
			a.sou_main_artist_id AS id,
			a.sou_main_artist_name AS name,
			UPPER(a.sou_main_artist_name) AS uname
		FROM ws.main a;

/*
SELECT 92159
Time: 888,779 ms
*/

SELECT * FROM ws.artist LIMIT 100;

-- SHOW DUPLICATE IDS
SELECT a.*, c.count_
	FROM  ws.artist a
	INNER JOIN (SELECT b.id, COUNT (b.*) AS count_
	FROM  ws.artist b
	GROUP BY b.id
	HAVING COUNT(b.*) > 1) c
	ON a.id=c.id;
/*
 id | name | uname | count_ 
----+------+-------+--------
(0 rows)

Time: 138,243 ms
*/

DROP INDEX IF EXISTS wsartist_idx; 
CREATE UNIQUE INDEX wsartistidx ON ws.artist (id);
/*
CREATE INDEX
Time: 77,133 ms
*/


