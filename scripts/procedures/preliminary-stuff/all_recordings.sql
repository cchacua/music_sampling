-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- TABLE INFO WS_TRACK and MB_ID
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS ws.records;
CREATE TABLE ws.records AS
	SELECT DISTINCT
			des_id AS id,
			des_name AS name,
			des_release_year AS release_year,
			des_main_genre AS main_genre,
			des_main_artist_id AS main_artist_id,
			des_main_artist_name AS main_artist_name,
			des_youtube_id AS youtube_id,
			des_musicbrainz_id AS musicbrainz_id, 
			des_main_artist_musicbrainz_id AS main_artist_musicbrainz_id
		FROM ws.main
	UNION 
	SELECT DISTINCT
			sou_id AS id,
			sou_name AS name,
			sou_release_year AS release_year,
			sou_main_genre AS main_genre,
			sou_main_artist_id AS main_artist_id,
			sou_main_artist_name AS main_artist_name,
			sou_youtube_id AS youtube_id,
			sou_musicbrainz_id AS musicbrainz_id, 
			sou_main_artist_musicbrainz_id AS main_artist_musicbrainz_id
		FROM ws.main;
/*
SELECT 404828
*/

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- There is a repeated ID, SO I delete one
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

SELECT COUNT(DISTINCT id)
	FROM  ws.records;
/*
 count  
--------
 404827
(1 row)
*/


SELECT id, COUNT (*)
	FROM  ws.records
	GROUP BY id
	HAVING count(*) > 1;
/*
 id | count 
----------+-------
    64015 |     2
(1 row)
*/

SELECT *
	FROM  ws.records
	WHERE id='64015';

/*
Problem with release date 

 id |      name      | release_year | main_genre | main_artist_id | main_artist_name | youtube_id |         musicbrainz_id         |   main_artist_musicbrainz_id   |  mb_id  |                mb_gid                
----------+----------------------+--------------------+------------------+----------------------+------------------------+------------------+--------------------------------------+--------------------------------------+---------+--------------------------------------
    64015 | You're Still the One | 1997               | R                |                 4995 | Shania Twain           | KNZH-emehxA      | 2ac1b488-18fb-4c78-82ab-be34b9c57f32 | faabb55d-3c9e-4c23-8779-732ac2ee2c0d | 1201663 | 2ac1b488-18fb-4c78-82ab-be34b9c57f32
    64015 | You're Still the One | 1998               | R                |                 4995 | Shania Twain           | KNZH-emehxA      | 2ac1b488-18fb-4c78-82ab-be34b9c57f32 | faabb55d-3c9e-4c23-8779-732ac2ee2c0d | 1201663 | 2ac1b488-18fb-4c78-82ab-be34b9c57f32
(2 rows)
*/

DELETE FROM ws.records
  WHERE id = '64015' AND release_year = '1998';

CREATE INDEX mb_idx ON ws.records (musicbrainz_id);
CREATE INDEX mb_artist_idx ON ws.records (main_artist_musicbrainz_id);


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- COUNTINGS
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- Number of tracks with MB recording ID
SELECT COUNT(DISTINCT id)
	FROM  ws.records
	WHERE musicbrainz_id IS NOT NULL;
/*
 count  
--------
 236723
(1 row)
*/


SELECT COUNT(DISTINCT musicbrainz_id)
	FROM  ws.records;
/*
 count  
--------
 232482
(1 row)

This means that there are songs with different ws ids but with the same mb id
*/


SELECT a.musicbrainz_id, COUNT(DISTINCT a.id)
 FROM ws.records a 
 GROUP BY a.musicbrainz_id
 HAVING COUNT(DISTINCT a.id)>1
 ORDER BY COUNT(DISTINCT a.id) DESC
 LIMIT 100;

/*
           musicbrainz_id            | count  
--------------------------------------+--------
                                      | 168104
 0bec597c-605c-441d-bb4f-0218b289e7c7 |     35
 94bc3e04-8b70-440e-9568-6c0c0d84f533 |     17
 d9fd1c91-0d80-47e2-a58c-85b23e120d20 |     14
 593c2cf3-d485-4413-a701-d5273d3343e0 |     14
 83d0b481-0583-469c-ab18-be68d2a756ea |     14
 12132b3e-5f6a-4757-bad1-b802c89ac245 |     12
 5dc4b8d0-2d09-412a-bde9-7cd2d4974f18 |     12
 c6540e68-de6e-4f0b-b72c-ba1a97c08146 |     11
 ccf54807-5d04-47b2-b143-c9ca3cafd48d |     11
 dff02f22-1c0b-4a24-9342-79ac33092826 |     10
 065582ee-841e-42be-bfb1-5e183e26d215 |      9
 ad1eb2af-6332-44ce-9cd9-42a5bda9ea62 |      9
 7c26e6a1-0fd6-4d0d-92a1-89d576bdacec |      9
 4e7ee1df-1233-4395-80cb-679360b04519 |      8
 cd1c1898-edc1-455b-8987-58d64d6e6f66 |      8
 e6d428f4-bbe2-4ac6-8c9d-a0b9f1f4638a |      7
 c83c1282-7589-4cf9-9bed-4979cf864ede |      7
 2d8c5630-9b05-4ef3-842b-3f2d044c816f |      7
 83f2708d-3c33-4b71-a972-dd0b5c2b5b7f |      7
 10671583-956b-4c0b-9602-b04f6077e383 |      7
 6c644faa-71d1-46eb-8ca7-503ecf6123b5 |      7
 b91a7741-3de1-47d7-ba38-5f0c6bafc49d |      7
 23764949-aa2e-4925-bdf7-af34ab9173b2 |      7
 b7d89bcb-e7c9-40c2-899d-835b76dbe2e7 |      7
 12db16d7-6541-4a3e-9fc1-fa1f27501bbb |      7

So the ID asssigned by WhoSampled is not good enough
*/



-----------------------------------------------------------------------------------------
-- Example of a bad MB ID attribution, because of poor information on the name

SELECT a.*
 FROM ws.records a 
 WHERE a.musicbrainz_id='0bec597c-605c-441d-bb4f-0218b289e7c7';

/*
id   |             name              | release_year | main_genre | main_artist_id | main_artist_name | youtube_id  |            mu
sicbrainz_id            |      main_artist_musicbrainz_id      
--------+-------------------------------+--------------+------------+----------------+------------------+-------------+--------------
------------------------+--------------------------------------
  86279 | Track 21                      | 2005         | H          |           1204 | J Dilla          | J1GdBGTW9I4 | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
  86282 | Track 28                      | 2005         | H          |           1204 | J Dilla          | NSG8v7Q2WNc | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 102532 | Track 21 (Beat CD '05 #3)     | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 102545 | Track 24                      | 2005         | H          |           1204 | J Dilla          | flR4D6CSKP0 | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 108551 | Track 06                      | 2005         | H          |           1204 | J Dilla          | FccfybtCMzc | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 111385 | Track 8                       | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 117910 | Track 4                       | 1998         | H          |           1204 | J Dilla          | OafJ8K6g2hE | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 120926 | Track 27                      | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c
-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 120928 | Track 42                      | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 121168 | Track 23                      | 2005         | H          |           1204 | J Dilla          | BBMi_4rcnJw | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 121247 | Track 16                      | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 134616 | Track 32                      | 2005         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 139737 | Track 12                      | 1998         | H          |           1204 | J Dilla          | v6c4eVwX0Vg | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 146283 | Track 26                      | 1998         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 146321 | Track 06 (Beat CD '05 #4)     | 2005         | H          |           1204 | J Dilla          | GVIgqYiCmog | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 194685 | Track 29                      | 1999         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 197130 | Track 21 (Da 1st Installment) | 2002         | H          |           1204 | J Dilla          | xRH7cM3wzA8 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 296854 | Track 36                      | 2002         | H          |           1204 | J Dilla          | XFYMX7IyGCI | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 366567 | Track 4 (The 1997 Batch)      | 1997         | H          |           1204 | J Dilla          | wKp958E16Zc | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 370135 | Track 28 (Another Batch)      | 1998         | H          |           1204 | J Dilla          |             | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 371247 | Track 6 (The 1997 Batch)      | 1997         | H          |           1204 | J Dilla          | ee_ivvTjsmc | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 380886 | Track 7 (The 1997 Batch)      | 1997         | H          |           1204 | J Dilla          | DABaELGpXJw | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 389720 | Track 12 (The 1997 Batch)     | 1997         | H          |           1204 | J Dilla          | EIYs2pyCPy4 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 432003 | Track 3 (1997 Batch)          | 1997         | H          |           1204 | J Dilla          | XXefVcFxZC8 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 443127 | Track 5                       | 1999         | H          |           1204 | J Dilla          | VPtTwYPI0YE | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
445250 | Track 29 (Another Batch)      | 1998         | H          |           1204 | J Dilla          | 64sP7g2e5bI | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 486251 | Track 20                      | 2005         | H          |           1204 | J Dilla          | Nhddi_m7fFg | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 491641 | Track 6 (Dee Zee)             | 1998         | H          |           1204 | J Dilla          | Pj-QpfPjbH8 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 491854 | Track 24 (Movin)              | 1998         | H          |           1204 | J Dilla          | XKB5h2tJQHQ | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 516132 | Track 27 (Another Batch)      | 1998         | H          |           1204 | J Dilla          | 5HSnoRBIe2k | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 520753 | Track 1 (1997 Batch)          | 1997         | H          |           1204 | J Dilla          | flR-xMGIn-8 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 530968 | Track 9 (The 1997 Batch)      | 1997         | H          |           1204 | J Dilla          | A6NTQRjjHH8 | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 540831 | Track 32 (Da 1st Installment) | 2005         | H          |           1204 | J Dilla          | IEzUBot7RWA | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 540848 | Track 32 (MPC 3000)           | 2005         | H          |           1204 | J Dilla          | vgL0Nr8QEXo | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
 542865 | Track 20 (Da 1st Installment) | 2002         | H          |           1204 | J Dilla          | WUc6SfM9Eiw | 0bec597c-605c-441d-bb4f-0218b289e7c7 | cbcbb22c-3a8d-46af-b4ba-09c98f0d7931
(35 rows)

Examples: https://www.youtube.com/watch?v=64sP7g2e5bI
*/


-- Example of a bad maching even with very different names
SELECT a.*
 FROM ws.records a 
 WHERE a.musicbrainz_id='94bc3e04-8b70-440e-9568-6c0c0d84f533';
/*
   id   |            name            | release_year | main_genre | main_artist_id |     main_artist_name      | youtube_id  |            musicbrainz_id            |      main_artist_musicbrainz_id      
--------+----------------------------+--------------+------------+----------------+---------------------------+-------------+--------------------------------------+--------------------------------------
 506857 | High Voltage               | 2005         | R          |         188272 | The Gothacoustic Ensemble |             | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 506925 | Place for My Head          | 2005         | R          |         188272 | The Gothacoustic Ensemble |             | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 506926 | Pushing Me Away            | 2005         | R          |         188272 | The Gothacoustic Ensemble |             | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 506928 | Somewhere I Belong         | 2005         | R          |         188272 | The Gothacoustic Ensemble |             | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 506931 | With You                   | 2005         | R          |         188272 | The Gothacoustic Ensemble |             | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508007 | H.                         | 2004         | R          |         188272 | The Gothacoustic Ensemble | sfUnj3g306U | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508018 | Whisper                    | 2007         | R          |         188272 | The Gothacoustic Ensemble | 9P15emb-6O0 | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508019 | Hello                      | 2007         | R          |         188272 | The Gothacoustic Ensemble | WDiqmrn_raI | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508630 | Farther Away               | 2007         | R          |         188272 | The Gothacoustic Ensemble | 2JH2ecPfdps | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508638 | My Last Breath             | 2007         | R          |         188272 | The Gothacoustic Ensemble | eZEcRGmRbP0 | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 508641 | Haunted                    | 2007         | R          |         188272 | The Gothacoustic Ensemble | zWi84Pm4wC0 | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512674 | Something I Can Never Have | 2005         | R          |         188272 | The Gothacoustic Ensemble | zxsERPdYQBs | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512676 | We're in This Together     | 2005         | R          |         188272 | The Gothacoustic Ensemble | 2BsApJjSyQA | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512704 | Head Like a Hole           | 2005         | R          |         188272 | The Gothacoustic Ensemble | z0LuHdl3QYU | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512706 | Heresy                     | 2005         | R          |         188272 | The Gothacoustic Ensemble | EhyioVga0Jo | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512707 | Hurt                       | 2005         | R          |         188272 | The Gothacoustic Ensemble | oIUfjXh1_yE | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
 512709 | The Perfect Drug           | 2005         | R          |         188272 | The Gothacoustic Ensemble | js99e5I9jPU | 94bc3e04-8b70-440e-9568-6c0c0d84f533 | e2ca237c-668b-49ec-afdf-71ea6be429c2
(17 rows)


And this MB ID only belongs to one the song H
https://musicbrainz.org/recording/94bc3e04-8b70-440e-9568-6c0c0d84f533
*/


SELECT a.*
 FROM ws.records a 
 WHERE a.musicbrainz_id='10671583-956b-4c0b-9602-b04f6077e383';
/*
   id   |                name                 | release_year | main_genre | main_artist_id |    main_artist_name     | youtube_id  |            musicbrainz_id            |      main_artist_musicbrainz_id      
--------+-------------------------------------+--------------+------------+----------------+-------------------------+-------------+--------------------------------------+--------------------------------------
  36437 | I See You                           | 2009         | H          |             65 | Snoop Dogg              | DFa5zLlOnWQ | 10671583-956b-4c0b-9602-b04f6077e383 | f90e8b26-9e52-4669-a5c9-e28529c47894
 183480 | It's Yours                          | 1998         | H          |          73533 | The Lone Ranger         |             | 10671583-956b-4c0b-9602-b04f6077e383 | 39f05750-e930-4bc0-882c-e94f8c1ef8d8
 229635 | You Got What I Eat                  | 2013         | H          |             65 | Snoop Dogg              |             | 10671583-956b-4c0b-9602-b04f6077e383 | f90e8b26-9e52-4669-a5c9-e28529c47894
 233507 | DPGC: You Know What I'm Throwin' Up | 2004         | H          |           1841 | Daz Dillinger           |             | 10671583-956b-4c0b-9602-b04f6077e383 | a0b8d027-6900-4b48-a955-c2fde7ad05da
 277403 | You Got Love                        | 2011         | H          |          35978 | Kindred the Family Soul | -n9zAeX16j8 | 10671583-956b-4c0b-9602-b04f6077e383 | 68ddabb6-abf4-4ed0-81b9-b34715e48d34
 301894 | How Do You Want It                  | 2010         | H          |         115641 | Floyd Bocox             | r_zuj8Ab5tE | 10671583-956b-4c0b-9602-b04f6077e383 | 
 460103 | Do You Remember                     | 1991         | H          |             65 | Snoop Dogg              | MCztNiTsmZw | 10671583-956b-4c0b-9602-b04f6077e383 | f90e8b26-9e52-4669-a5c9-e28529c47894
(7 rows)

And the MB ID comes from another song
https://musicbrainz.org/recording/10671583-956b-4c0b-9602-b04f6077e383

Look at the example using the Youtube's content ID name: I C U vs  I See You 
*/


-------------------------------------------------------------------------
-- Example of a duplicated recording with and without Work information

-- https://musicbrainz.org/recording/86e6bf90-0323-4cb6-a97f-2b71f8e3ffdb
-- https://musicbrainz.org/recording/11f38a8d-919b-4adf-83a9-272e87e8c14b

-------------------------------------------------------------------------
-- Number of tracks with MB artist ID
SELECT COUNT(DISTINCT id)
	FROM  ws.records
	WHERE main_artist_musicbrainz_id IS NOT NULL;
/*
 count  
--------
 343498
(1 row)
*/

-- Number of tracks with youtube ID
SELECT COUNT(DISTINCT id)
	FROM  ws.records
	WHERE youtube_id IS NOT NULL;
/*
 count  
--------
 295787
(1 row)
*/




