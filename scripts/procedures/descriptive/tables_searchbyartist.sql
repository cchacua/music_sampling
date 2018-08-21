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
SELECT 108023

There were 108036 songs with MB artist ID and withouth MB recording ID, so, only 13 observations were lost
*/

-------------------------------------------------------------------------
-- Table 2
