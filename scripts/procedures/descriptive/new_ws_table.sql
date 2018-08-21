-- NEW WS DATA WITH MB IDS FOR THOSE THAT CAN BE MATCHED DIRECTLY

DROP TABLE IF EXISTS musicbrainz.whosam;

CREATE TABLE musicbrainz.whosam AS
SELECT f.*, g.id AS s_mb_id, g.gid AS s_mb_gid, i.id AS d_mb_id, i.gid AS d_mb_gid
	FROM musicbrainz.whois f
	LEFT JOIN (SELECT DISTINCT e.gid, e.id
                                        FROM (
                                          SELECT DISTINCT  a.gid, a.id
                                          FROM musicbrainz.whois b
                                          INNER JOIN musicbrainz.recording a
                                          ON b.source_track_musicbrainz_id=a.gid
                                          UNION
                                          SELECT DISTINCT d.gid, d.new_id AS id
                                          FROM musicbrainz.whois c
                                          INNER JOIN musicbrainz.recording_gid_redirect d
                                          ON c.source_track_musicbrainz_id=d.gid) e
		  ) g
	ON f.source_track_musicbrainz_id=g.gid
	LEFT JOIN (SELECT DISTINCT h.gid, h.id
		                         FROM (
		                          SELECT DISTINCT  k.gid, k.id
		                          FROM musicbrainz.whois j
		                          INNER JOIN musicbrainz.recording k
		                          ON j.dest_track_musicbrainz_id=k.gid
		                          UNION
		                          SELECT DISTINCT m.gid, m.new_id AS id
		                          FROM musicbrainz.whois l
		                          INNER JOIN musicbrainz.recording_gid_redirect m
		                          ON l.dest_track_musicbrainz_id=m.gid) h
			  ) i
	ON f.dest_track_musicbrainz_id=i.gid;


CREATE INDEX des_gidx ON musicbrainz.whosam (d_mb_gid);
CREATE INDEX des_mb_idx ON musicbrainz.whosam (d_mb_id);
CREATE INDEX sou_gidx ON musicbrainz.whosam (s_mb_gid);
CREATE INDEX sou_mb_idx ON musicbrainz.whosam (s_mb_id);


-- COUNT DESTINATION TRACKS WITH MB ID

SELECT COUNT(DISTINCT a.source_track_id)
	FROM musicbrainz.whosam a
	WHERE a.s_mb_gid IS NOT NULL;
/* count 
-------
 75692
(1 row)
*/

SELECT COUNT(DISTINCT a.dest_track_id)
	FROM musicbrainz.whosam a
	WHERE a.d_mb_gid IS NOT NULL;
/*
 count  
--------
 178110
(1 row)
*/

SELECT COUNT(DISTINCT e.track_id)
	FROM (SELECT DISTINCT a.dest_track_id AS track_id
		FROM musicbrainz.whosam a
		WHERE a.d_mb_gid IS NOT NULL
	      UNION 
	      SELECT DISTINCT b.source_track_id AS track_id
		FROM musicbrainz.whosam b
		WHERE b.s_mb_gid IS NOT NULL
	      ) e;
/*
 count  
--------
 236703
(1 row)
*/

SELECT COUNT(DISTINCT e.track_id)
	FROM (SELECT DISTINCT a.dest_track_id AS track_id
		FROM musicbrainz.whosam a
	      UNION 
	      SELECT DISTINCT b.source_track_id AS track_id
		FROM musicbrainz.whosam b
	      ) e;

/*
 count  
--------
 404827
(1 row)
*/

-------------------------------------------------
-- TABLE INFO WS_TRACK and MB_ID

CREATE TABLE musicbrainz.whosam_tracks AS
	SELECT DISTINCT
			dest_track_id AS track_id,
			dest_track_name AS track_name,
			dest_track_release_year AS track_release_year,
			dest_track_main_genre AS track_main_genre,
			dest_track_main_artist_id AS track_main_artist_id,
			dest_track_main_artist_name AS track_main_artist_name,
			dest_track_youtube_id AS track_youtube_id,
			dest_track_musicbrainz_id AS track_musicbrainz_id, 
			dest_track_main_artist_musicbrainz_id AS track_main_artist_musicbrainz_id,
			d_mb_id AS mb_id, 
			d_mb_gid AS mb_gid
		FROM musicbrainz.whosam
	UNION 
	SELECT DISTINCT
			source_track_id AS track_id,
			source_track_name AS track_name,
			source_track_release_year AS track_release_year,
			source_track_main_genre AS track_main_genre,
			source_track_main_artist_id AS track_main_artist_id,
			source_track_main_artist_name AS track_main_artist_name,
			source_track_youtube_id AS track_youtube_id,
			source_track_musicbrainz_id AS track_musicbrainz_id, 
			source_track_main_artist_musicbrainz_id AS track_main_artist_musicbrainz_id,
			s_mb_id AS mb_id, 
			s_mb_gid AS mb_gid
		FROM musicbrainz.whosam;
/*
SELECT 404828
*/

CREATE INDEX mb_track_idx ON musicbrainz.whosam_tracks (track_musicbrainz_id);
CREATE INDEX mb_artist_idx ON musicbrainz.whosam_tracks (track_main_artist_musicbrainz_id);

SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks;
/*
 count  
--------
 404827
(1 row)
*/


SELECT track_id, COUNT (*)
	FROM  musicbrainz.whosam_tracks
	GROUP BY track_id
	HAVING count(*) > 1;
/*
 track_id | count 
----------+-------
    64015 |     2
(1 row)
*/

SELECT *
	FROM  musicbrainz.whosam_tracks
	WHERE track_id='64015';

/*
Problem with release date 

 track_id |      track_name      | track_release_year | track_main_genre | track_main_artist_id | track_main_artist_name | track_youtube_id |         track_musicbrainz_id         |   track_main_artist_musicbrainz_id   |  mb_id  |                mb_gid                
----------+----------------------+--------------------+------------------+----------------------+------------------------+------------------+--------------------------------------+--------------------------------------+---------+--------------------------------------
    64015 | You're Still the One | 1997               | R                |                 4995 | Shania Twain           | KNZH-emehxA      | 2ac1b488-18fb-4c78-82ab-be34b9c57f32 | faabb55d-3c9e-4c23-8779-732ac2ee2c0d | 1201663 | 2ac1b488-18fb-4c78-82ab-be34b9c57f32
    64015 | You're Still the One | 1998               | R                |                 4995 | Shania Twain           | KNZH-emehxA      | 2ac1b488-18fb-4c78-82ab-be34b9c57f32 | faabb55d-3c9e-4c23-8779-732ac2ee2c0d | 1201663 | 2ac1b488-18fb-4c78-82ab-be34b9c57f32
(2 rows)
*/

DELETE FROM musicbrainz.whosam_tracks
  WHERE track_id = '64015' AND track_release_year = '1998';


-------------------------------------------------------------------------
-- Number of recordings (WITH THE NEW, matched MB ID)
SELECT COUNT(DISTINCT mb_id)
	FROM  musicbrainz.whosam_tracks;
/*
 count  
--------
 232439
(1 row)
*/



SELECT COUNT(DISTINCT mb_gid)
	FROM  musicbrainz.whosam_tracks;
/*
 count  
--------
 232462
(1 row)
*/

/* Note: id is prefered over gid*/


-------------------------------------------------------------------------
-- Number of WS tracks with MB ID
SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_musicbrainz_id IS NOT NULL;
/*
 count  
--------
 236723
(1 row)

236723/404827=0.584751
Percentage of matched songs

404827-236723= 168.104 missing songs
*/


-------------------------------------------------------------------------
-- Number of tracks with youtube ID
SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_youtube_id IS NOT NULL;
/*
 count  
--------
 295787
(1 row)
*/
-- Number of tracks with youtube ID where the MB ID is not present
SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_youtube_id IS NOT NULL AND mb_id IS NULL;
/*
 count  
--------
 115798
(1 row)

From the 168.104 missing songs, using Youtube data, a potential number of 115.798 can be matched.

168104-115798=52306
So, 52306 would remain missing

52306/404827= 0.1292058
Potential percentage of unmatched songs, after using Youtube ID data
*/


-------------------------------------------------------------------------
-- Number of tracks with MB artist ID
SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_main_artist_musicbrainz_id IS NOT NULL;
/*
 count  
--------
 343498
(1 row)
*/
-- Number of tracks with MB artist ID where the MB ID is not present
SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_main_artist_musicbrainz_id IS NOT NULL AND mb_id IS NULL;
/*
 count  
--------
 108036
(1 row)

So, the Youtube's information may be better, but here we can have a first rude approximation
*/

SELECT COUNT(DISTINCT track_id)
	FROM  musicbrainz.whosam_tracks
	WHERE track_main_artist_musicbrainz_id IS NOT NULL AND mb_id IS NULL AND track_youtube_id IS NULL;
/*
 count 
-------
 29864
(1 row)

So, in 29864 songs, the MB ID is the only alternative
*/

-------------------------------------------------------------------------
-- Music_Brainz

-- Artist ID
SELECT a.*
	FROM  musicbrainz.whosam_tracks a
	WHERE a.track_main_artist_musicbrainz_id IS NOT NULL AND a.mb_id IS NULL
	LIMIT 10;

-- Recording
SELECT a.*
	FROM  musicbrainz.recording a
	LIMIT 10;


-- Credit
SELECT a.*
	FROM  musicbrainz.artist_credit a
	LIMIT 10;

SELECT a.*
	FROM  musicbrainz.artist_credit a
	WHERE a.id='2125299'
	LIMIT 10;

-- Credit name

SELECT a.*
	FROM  musicbrainz.artist_credit_name a
	LIMIT 10;

SELECT a.*
	FROM  musicbrainz.artist_credit_name a
	WHERE a.position>0	
	LIMIT 10;

-- Artist
SELECT a.*
	FROM  musicbrainz.artist a
	LIMIT 10;

-- Join Artist ID - WS vs MB

-- ALTER TABLE musicbrainz.whosam_tracks ALTER COLUMN track_main_artist_musicbrainz_id SET DATA TYPE UUID USING (uuid_generate_v4());


SELECT a.*, b.id
	FROM  musicbrainz.whosam_tracks a
	INNER JOIN musicbrainz.artist b
	ON CAST(a.track_main_artist_musicbrainz_id AS UUID) = b.gid
	WHERE a.track_main_artist_musicbrainz_id IS NOT NULL AND a.mb_id IS NULL
	LIMIT 10;


