\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table only recording info in WS 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.recording;
CREATE TABLE ws.recording AS
	SELECT DISTINCT
			a.des_id AS id,
			a.des_name AS name,
			UPPER(a.des_name) AS uname,
			a.des_release_year AS release_year,
			a.des_main_genre AS genre
		FROM ws.main a
	UNION 
	SELECT DISTINCT
			a.sou_id AS id,
			a.sou_name AS name,
			UPPER(a.sou_name) AS uname,
			a.sou_release_year AS release_year,
			a.sou_main_genre AS genre
		FROM ws.main a;

/*
SELECT 404828
Time: 1827,579 ms (00:01,828)
*/

SELECT * FROM ws.recording LIMIT 100;

-- SHOW DUPLICATE IDS
SELECT a.*, c.count_
	FROM  ws.recording a
	INNER JOIN (SELECT b.id, COUNT (b.*) AS count_
	FROM  ws.recording b
	GROUP BY b.id
	HAVING COUNT(b.*) > 1) c
	ON a.id=c.id;
/*
  id   |         name         |        uname         | release_year | genre | count_ 
-------+----------------------+----------------------+--------------+-------+--------
 64015 | You're Still the One | YOU'RE STILL THE ONE | 1998         | R     |      2
 64015 | You're Still the One | YOU'RE STILL THE ONE | 1997         | R     |      2
(2 rows)

Time: 519,033 ms

DETAIL:  Key (id)=(64015) is duplicated.
SO, I will delete the one release in 1998, to create a unique index
*/

DELETE FROM ws.recording
  WHERE id = '64015' AND release_year = '1998';

DROP INDEX IF EXISTS wsrecording_idx; 
CREATE UNIQUE INDEX wsrecording_idx ON ws.recording (id);
/*
CREATE INDEX
Time: 145,383 ms
*/
CREATE INDEX wsrecording_unamex1 ON ws.recording USING GIN (uname gin_trgm_ops);
CREATE INDEX wsrecording_unamex2 ON ws.recording USING GIN(to_tsvector('mb_simple', uname));
CREATE INDEX wsrecording_unamex3 ON ws.recording (uname);


-- Add Column, found in destination
ALTER TABLE ws.recording DROP COLUMN IF EXISTS des;
ALTER TABLE ws.recording ADD COLUMN des BOOLEAN;
UPDATE ws.recording p SET des=
       (SELECT TRUE
        FROM ws.recording a
	INNER JOIN (SELECT DISTINCT c.des_id 
			FROM ws.main c) b
        ON a.id=b.des_id
        WHERE a.id=p.id);
/*
UPDATE 404827
Time: 17203,675 ms (00:17,204)
*/

-- Add Column, found in source
ALTER TABLE ws.recording DROP COLUMN IF EXISTS sou;
ALTER TABLE ws.recording ADD COLUMN sou BOOLEAN;
UPDATE ws.recording p SET sou=
       (SELECT TRUE
        FROM ws.recording a
	INNER JOIN (SELECT DISTINCT c.sou_id 
			FROM ws.main c) b
        ON a.id=b.sou_id
        WHERE a.id=p.id);
/*
UPDATE 404827
Time: 16083,534 ms (00:16,084)
*/
