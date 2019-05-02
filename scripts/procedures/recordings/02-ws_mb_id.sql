\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table linking ws_id with mb_gid
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.recording_mb;
CREATE TABLE ws.recording_mb AS
	SELECT DISTINCT a.des_id AS wsrecording,
			a.des_musicbrainz_id AS ogid
	FROM ws.main a
	WHERE a.des_musicbrainz_id IS NOT NULL
	UNION
	SELECT DISTINCT b.sou_id AS wsrecording,
			b.sou_musicbrainz_id AS ogid
	FROM ws.main b
	WHERE b.sou_musicbrainz_id IS NOT NULL;
/*

SELECT 236723
Time: 841,243 ms
*/

DROP INDEX IF EXISTS wsrecordingmb_wsrecordingx; 
CREATE UNIQUE INDEX wsrecordingmb_wsrecordingx ON ws.recording_mb (wsrecording);
DROP INDEX IF EXISTS wsrecordingmb_ogidx; 
CREATE INDEX wsrecordingmb_ogidx ON ws.recording_mb (ogid);


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- ADD A COLUMN WITH THE NUMERIC RECORDING ID OF MB, TO SPEED THE QUERIES
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
ALTER TABLE ws.recording_mb DROP COLUMN IF EXISTS mbrecording;
ALTER TABLE ws.recording_mb ADD COLUMN mbrecording INT;
UPDATE ws.recording_mb p SET mbrecording=
       (SELECT b.id
        FROM ws.recording_mb a
	INNER JOIN (SELECT c.id, c.gid 
			FROM musicbrainz.recording c
		    UNION
		    SELECT d.new_id AS id, d.gid 
			FROM musicbrainz.recording_gid_redirect d) b
        ON a.ogid=b.gid
        WHERE a.ogid=p.ogid AND a.wsrecording=p.wsrecording);
/*
UPDATE 236723
Time: 8583,659 ms (00:08,584)
*/
DROP INDEX IF EXISTS wsrecordingmb_mbrecordingx; 
CREATE INDEX wsrecordingmb_mbrecordingx ON ws.recording_mb (mbrecording);

SELECT COUNT(DISTINCT ogid) FROM ws.recording_mb;
/*
 count  
--------
 232482
(1 row)

Time: 272,845 ms
*/

SELECT COUNT(DISTINCT mbrecording) FROM ws.recording_mb;
/*
 count  
--------
 232393
(1 row)

Time: 194,191 ms
So, there are ogid that have the same mbrecording (expected, because of the use of musicbrainz.recording_gid_redirect)
or that are not found 
*/

SELECT COUNT(DISTINCT wsrecording) FROM ws.recording_mb WHERE mbrecording IS not NULL;
/*
 count  
--------
 236686
(1 row)

Time: 132,744 ms
*/


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Delete the gid provided by ws that cannot be found in musicbrainz 
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

SELECT a.wsrecording, b.name, a.ogid FROM ws.recording_mb a INNER JOIN ws.recording b ON a.wsrecording=b.id WHERE a.mbrecording IS NULL;
/*
 wsrecording |                  name                   |                 ogid                 
-------------+-----------------------------------------+--------------------------------------
       20438 | Soy 18 With a Bullet                    | 54b729ec-52de-484d-99cb-3bd045cd50de
       25787 | Redemption Song (For Haiti Relief)      | 373c43de-2fc8-4f46-a28a-4a298b786d9e
       65107 | Für Immer Punk                          | 18c37f57-f052-4e69-8948-2552b353d653
       73271 | This World Pt 3                         | 0032a123-5255-4c05-a1f0-0ec1327fafba
       73274 | Never Gonna Leave the Game              | 0e11a011-2447-4499-b9cc-d6c170acc4fa
       89539 | Thunderpuss GHV2 Megamix                | 357287be-5b67-4e5b-9f54-cc6c77da85b7
      112055 | Black Dove                              | d463b282-01d2-43e9-bf0c-76233c9d2e8c
      112058 | Thematics                               | 6e2efe41-b300-450b-84ca-c2a761a8b763
      112059 | Precious Metals                         | f93ee383-f1bb-465e-a2b7-fd92031203e3
      112062 | Price of Livin'                         | 0657eddc-5305-4e89-8892-249edac69dfe
      123490 | Act Like U Know                         | 18d96327-a7a4-49e4-b854-049b86e307a0
      158400 | Zooby Zooby                             | 468aab9a-f8ac-44f6-a6c9-c86bdd505ef1
      167143 | Last Days                               | 51c1169a-8afb-4ce7-bbdf-5ba3728ee7c2
      219587 | If You Want It                          | d2779032-8e50-4fa4-8792-859eab81df0f
      225290 | Controlled by Your Love                 | 1208ccd2-3b04-4cdc-84a6-d9acf11bf9cf
      229314 | Bustin Out                              | 8a7661e0-f4d7-4714-89d7-f1dd1d7db1a6
      261455 | Can't Strain My Brain                   | 1b9752c5-6905-4b5f-a9e7-9c62ffde9c9f
      269447 | Lost Without Your Love                  | 7d9944f5-1642-4297-b18d-6caf1ad8a262
      274152 | Canção Do Apocalipse                    | 1b2605af-0210-4052-b7ce-476db50a6830
      277277 | The Inner Voice                         | c0095ff4-4343-44fd-a01b-1c0f55c76ed9
      305437 | Incubi Ricorrenti (Opening Titles)      | e3892699-bb69-4b16-a384-9c2697aa7c60
      320783 | Habang May Buhay                        | 46b56abf-8074-4c47-8524-dee8c720dee6
      334254 | Central Park Arrest                     | 55fe675c-c233-46b5-9379-9c8607ef373c
      335429 | Sukiyaki (Forever)                      | da594c66-ee99-49d2-bf37-31fdf5cf01b9
      396914 | Russell Westbrook on a Farm             | dbd91846-f7b4-4b22-a0fd-05dba233287f
      407643 | Bye and Bye We're Going to See the King | e3fc9a15-b91e-45da-9cb8-7df9ee4eeb82
      454524 | Tequila                                 | 9522e233-1307-4c5d-aa66-0b129df61c3a
      464207 | Eternal                                 | 918f1cda-27a4-4423-a701-6c07504d6e7d
      476439 | Snow                                    | 6213b778-d23d-4fb5-ab38-cb7eecc3350c
      485202 | Blue N' Boogie                          | b30b8ee3-0325-4033-aba9-0a1c55879bb1
      486124 | Love Rain (Head Nod Joachim Remix)      | 1208ccd2-3b04-4cdc-84a6-d9acf11bf9cf
      493983 | Political Proverbs                      | 18793955-7804-4343-8a18-ee4b20867187
      506204 | A Mother's Love                         | 94094ff6-e036-4b67-961c-da83bee1f69c
      506429 | Body Language                           | b2603eb1-9091-47f3-acfe-84089a971f6c
      516398 | Draw the Line                           | 6aa8e8ae-358a-4d09-86f2-b35297ce86ef
      534037 | Destroy the Whole World                 | 40fea5d2-d787-4ca8-94c0-ef55ad271488
      534427 | Rap Battle                              | 527360f0-06f0-4705-93af-c1b265dd1908
(37 rows)

*/

DELETE FROM ws.recording_mb a
  WHERE a.wsrecording IN (SELECT b.wsrecording FROM ws.recording_mb b WHERE b.mbrecording IS NULL);
/*
DELETE 37
Time: 20,170 ms
*/

-- To insert rows
-- https://www.oreilly.com/library/view/practical-postgresql/9781449309770/ch04s03.html
-- https://www.postgresql.org/docs/9.5/sql-createsequence.html
