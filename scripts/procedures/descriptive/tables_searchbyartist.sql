-------------------------------------------------------------------------
-- Table 1

-- Number of tracks with MB artist ID where the MB ID is not present
DROP TABLE IF EXISTS musicbrainz.whosam_mb_nonmatched;

CREATE TABLE musicbrainz.whosam_mb_nonmatched AS
SELECT DISTINCT a.*, b.id, b.gid, b.name
	FROM  musicbrainz.whosam_tracks a
	INNER JOIN musicbrainz.artist b
	ON CAST(a.track_main_artist_musicbrainz_id AS UUID) = b.gid
	WHERE a.track_main_artist_musicbrainz_id IS NOT NULL AND a.mb_id IS NULL
UNION
SELECT DISTINCT c.*, d.new_id AS id, e.gid, e.name
	FROM  musicbrainz.whosam_tracks c
	INNER JOIN musicbrainz.artist_gid_redirect d
	ON CAST(c.track_main_artist_musicbrainz_id AS UUID) = d.gid
	LEFT JOIN musicbrainz.artist e
	ON d.new_id=e.id
	WHERE c.track_main_artist_musicbrainz_id IS NOT NULL AND c.mb_id IS NULL;

/*
SELECT 108.023

There were 108036 songs with MB artist ID and withouth MB recording ID, so, only 13 observations were lost
*/

CREATE INDEX mb_art_idx ON musicbrainz.whosam_mb_nonmatched (id);

SELECT * FROM musicbrainz.whosam_mb_nonmatched LIMIT 10;

SELECT COUNT(DISTINCT a.id) FROM musicbrainz.whosam_mb_nonmatched a;
/*
This is the number of main artists:
 count 
-------
 38749
(1 row)
*/


-------------------------------------------------------------------------
-- Table 2
DROP TABLE IF EXISTS musicbrainz.wsmb_nm_rec;

CREATE TABLE musicbrainz.wsmb_nm_rec AS
SELECT DISTINCT a.id AS mb_art_id, a.gid AS mb_art_gid, b.name AS main_art_name, c.id AS mb_rec_id, c.gid AS mb_rec_gid, c.artist_credit, c.name AS rec_name 
	FROM (SELECT DISTINCT aa.id, aa.gid FROM musicbrainz.whosam_mb_nonmatched aa) a
	INNER JOIN musicbrainz.artist_credit_name b
	ON a.id=b.artist
	INNER JOIN musicbrainz.recording c
	ON b.artist_credit=c.artist_credit;
/*
SELECT 5.595.160
*/

SELECT * FROM musicbrainz.wsmb_nm_rec LIMIT 10;

