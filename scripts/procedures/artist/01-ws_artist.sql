\connect musicbrainz;
\timing

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

-- Add Column, found in destination
ALTER TABLE ws.artist DROP COLUMN IF EXISTS des;
ALTER TABLE ws.artist ADD COLUMN des BOOLEAN;
UPDATE ws.artist p SET des=
       (SELECT TRUE
        FROM ws.artist a
	INNER JOIN (SELECT DISTINCT c.des_main_artist_id 
			FROM ws.main c) b
        ON a.id=b.des_main_artist_id
        WHERE a.id=p.id);
/*
UPDATE 92159
Time: 1089,671 ms (00:01,090)
*/


-- Add Column, found in source
ALTER TABLE ws.artist DROP COLUMN IF EXISTS sou;
ALTER TABLE ws.artist ADD COLUMN sou BOOLEAN;
UPDATE ws.artist p SET sou=
       (SELECT TRUE
        FROM ws.artist a
	INNER JOIN (SELECT DISTINCT c.sou_main_artist_id 
			FROM ws.main c) b
        ON a.id=b.sou_main_artist_id
        WHERE a.id=p.id);
/*
UPDATE 92159
Time: 1468,828 ms (00:01,469)
*/
