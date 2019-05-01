

-- Records to find 1 
DROP TABLE IF EXISTS ws.records_tf1;
CREATE TABLE ws.records AS
SELECT a.id AS wsid, a.name AS wsname, UPPER(a.name) AS uwsname, a.genres, a.rwsids, a.rmbids, a.percenmbids, a.gid 
	FROM ws.artistsmb_unique a 
	WHERE a.gid IS NULL;
/*
SELECT 30338
*/
