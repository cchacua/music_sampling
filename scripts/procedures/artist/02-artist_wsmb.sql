\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table linking ws_artistid with mb_artistgid
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.artist_mb;
CREATE TABLE ws.artist_mb AS
	SELECT DISTINCT a.des_main_artist_id AS wsartist,
			a.des_main_artist_musicbrainz_id AS ogid
	FROM ws.main a
	WHERE a.des_main_artist_musicbrainz_id IS NOT NULL
	UNION
	SELECT DISTINCT b.sou_main_artist_id AS wsartist,
			b.sou_main_artist_musicbrainz_id AS ogid
	FROM ws.main b
	WHERE b.sou_main_artist_musicbrainz_id IS NOT NULL;
/*
SELECT 61829
Time: 542,847 ms
*/

DROP INDEX IF EXISTS wsartistmb_wsartistx; 
CREATE UNIQUE INDEX wsartistmb_wsartistx ON ws.artist_mb (wsartist);
DROP INDEX IF EXISTS wsartistmb_ogidx; 
CREATE INDEX wsartistmb_ogidx ON ws.artist_mb (ogid);


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- ADD A COLUMN WITH THE NUMERIC Artist ID OF MB, TO SPEED THE QUERIES
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
ALTER TABLE ws.artist_mb DROP COLUMN IF EXISTS mbartist;
ALTER TABLE ws.artist_mb ADD COLUMN mbartist INT;
UPDATE ws.artist_mb p SET mbartist=
       (SELECT b.id
        FROM ws.artist_mb a
	INNER JOIN (SELECT c.id, c.gid 
			FROM musicbrainz.artist c
		    UNION
		    SELECT d.new_id AS id, d.gid 
			FROM musicbrainz.artist_gid_redirect d) b
        ON a.ogid=b.gid
        WHERE a.ogid=p.ogid AND a.wsartist=p.wsartist);
/*
UPDATE 61829
Time: 12036,191 ms (00:12,036)
*/
DROP INDEX IF EXISTS wsartistmb_mbartistx; 
CREATE INDEX wsartistmb_mbartistx ON ws.artist_mb (mbartist);

SELECT COUNT(DISTINCT ogid) FROM ws.artist_mb;
/*
 count 
-------
 61097
(1 row)

Time: 42,608 ms
*/

SELECT COUNT(DISTINCT mbartist) FROM ws.artist_mb;
/*
 count 
-------
 61017
(1 row)
Time: 26,439 ms

So, there are ogid that have the same mbartist (expected, because of the use of musicbrainz.artist_gid_redirect)
or that are not found 
*/

SELECT COUNT(DISTINCT wsartist) FROM ws.artist_mb WHERE mbartist IS not NULL;
/*
 count 
-------
 61814
(1 row)

Time: 27,470 ms
*/


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Delete the gid provided by ws that cannot be found in musicbrainz 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

SELECT a.wsartist, b.name, a.ogid FROM ws.artist_mb a INNER JOIN ws.artist b ON a.wsartist=b.id WHERE a.mbartist IS NULL;
/*
 wsartist |                 name                  |                 ogid                 
----------+---------------------------------------+--------------------------------------
   167386 | Jeremy Wakefield                      | a1400130-b5da-4cfd-a991-2219a150b933
   153092 | J. Levine                             | b31ac3b6-c227-40fd-8016-36213e774caa
   141192 | Alisah Bonaobra                       | 50daf48b-f0d7-464b-92e0-eadba8d0dfb2
    78145 | Adam Burnett                          | 75bb1b11-c747-4eeb-80dc-2ef588a75685
    64055 | Solar/BiałAs                          | 0b2aed90-93fd-44df-a53e-b3532416f369
   139413 | Rodolfo Y Su Tipica                   | ead8d6d9-e58b-4dd8-916f-cf7f359db38e
   183058 | Francisco Allendes & Marcelo Rosselot | d2b9535e-169b-43dc-80b7-8b23d727c7f0
   174453 | Tore, Erlend & Eirik                  | 8273fd2d-5790-4291-bd83-6525ee36ac61
    65236 | El Bahattee                           | a5428e6d-790d-4686-9ec1-1cd4a67778d1
    88783 | Guti Luca Bacchetti                   | f9392838-647a-4af5-bfca-504de9ae542b
    31241 | Alex Gilbert                          | 9ca43320-dec6-42d0-a6e0-92c31d387db5
   116214 | Gregson & Collister                   | 4a4eba69-1751-4631-8f78-15555437136e
   169265 | Henry Ford                            | 79738791-6bc0-4124-a526-521d43e17b8a
    90664 | Ray McKinley and Some of the Boys     | 5ef84caa-147d-4b34-b249-ae041055387d
    50487 | Visionmasters                         | a50cb176-42ff-4f60-a5ff-f4c8d5854709
(15 rows)

Time: 32,870 ms

*/

DELETE FROM ws.artist_mb a
  WHERE a.wsartist IN (SELECT b.wsartist FROM ws.artist_mb b WHERE b.mbartist IS NULL);
/*
DELETE 15
Time: 16,953 ms
*/

-- To insert rows
-- https://www.oreilly.com/library/view/practical-postgresql/9781449309770/ch04s03.html
-- https://www.postgresql.org/docs/9.5/sql-createsequence.html
