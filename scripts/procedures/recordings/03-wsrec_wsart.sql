\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table linking wsrecording and wsartist
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
DROP TABLE IF EXISTS ws.wsrec_wsart;
CREATE TABLE ws.wsrec_wsart AS
	SELECT DISTINCT a.des_id AS wsrecording,
			a.des_main_artist_id AS wsartist
	FROM ws.main a
	UNION
	SELECT DISTINCT b.sou_id AS wsrecording,
			b.sou_main_artist_id AS wsartist
	FROM ws.main b;
/*
SELECT 404827
Time: 1065,778 ms (00:01,066)
*/


CREATE INDEX wswsrecwsart_wsrecordingx ON ws.wsrec_wsart (wsrecording);
CREATE INDEX wswsrecwsart_wsartistx ON ws.wsrec_wsart (wsartist);
