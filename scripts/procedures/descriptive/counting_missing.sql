SELECT COUNT(e.",type,"_track_id)
                                        FROM (
                                          SELECT ",dis, " b.",type,"_track_id
                                          FROM musicbrainz.whois b
                                          INNER JOIN musicbrainz.recording a
                                          ON b.",type,"_track_musicbrainz_id=a.gid
                                          UNION
                                          SELECT ",dis, " c.",type,"_track_id
                                          FROM musicbrainz.whois c
                                          INNER JOIN musicbrainz.recording_gid_redirect d
                                          ON c.",type,"_track_musicbrainz_id=d.gid) e;"
--------------------------------------------------------------------------------


SELECT COUNT(e.",type,"_track_id)
	FROM musicbrainz.whois g
	LEFT JOIN (
              SELECT ",dis, " b.",type,"_track_id
              	FROM musicbrainz.whois b
                INNER JOIN musicbrainz.recording a
                ON b.",type,"_track_musicbrainz_id=a.gid
                UNION
                SELECT ",dis, " c.",type,"_track_id
                FROM musicbrainz.whois c
                INNER JOIN musicbrainz.recording_gid_redirect d
                ON c.",type,"_track_musicbrainz_id=d.gid) e
	ON g.",type,"_track_id=e.",type,"_track_id
	WHERE e.",type,"_track_id IS NULL AND g.",type,"_track_id IS NOT NULL;

--------------------------------------------------------------------------------

SELECT COUNT(DISTINCT g.source_track_musicbrainz_id)
	FROM musicbrainz.whois g
	LEFT JOIN (
              SELECT DISTINCT b.source_track_id, b.source_track_musicbrainz_id
              	FROM musicbrainz.whois b
                INNER JOIN musicbrainz.recording a
                ON b.source_track_musicbrainz_id=a.gid
                UNION
                SELECT DISTINCT c.source_track_id, c.source_track_musicbrainz_id
                FROM musicbrainz.whois c
                INNER JOIN musicbrainz.recording_gid_redirect d
                ON c.source_track_musicbrainz_id=d.gid) e
	ON g.source_track_musicbrainz_id=e.source_track_musicbrainz_id
	WHERE e.source_track_musicbrainz_id IS NULL AND g.source_track_musicbrainz_id IS NOT NULL;

SELECT DISTINCT g.*
	FROM musicbrainz.whois g
	LEFT JOIN (
              SELECT DISTINCT b.source_track_id, b.source_track_musicbrainz_id
              	FROM musicbrainz.whois b
                INNER JOIN musicbrainz.recording a
                ON b.source_track_musicbrainz_id=a.gid
                UNION
                SELECT DISTINCT c.source_track_id, c.source_track_musicbrainz_id
                FROM musicbrainz.whois c
                INNER JOIN musicbrainz.recording_gid_redirect d
                ON c.source_track_musicbrainz_id=d.gid) e
	ON g.source_track_musicbrainz_id=e.source_track_musicbrainz_id
	WHERE e.source_track_musicbrainz_id IS NULL AND g.source_track_musicbrainz_id IS NOT NULL;

--------------------------------------------------------------------------------

SELECT COUNT(DISTINCT g.dest_track_musicbrainz_id)
	FROM musicbrainz.whois g
	LEFT JOIN (
              SELECT DISTINCT b.dest_track_id, b.dest_track_musicbrainz_id
              	FROM musicbrainz.whois b
                INNER JOIN musicbrainz.recording a
                ON b.dest_track_musicbrainz_id=a.gid
                UNION
                SELECT DISTINCT c.dest_track_id, c.dest_track_musicbrainz_id
                FROM musicbrainz.whois c
                INNER JOIN musicbrainz.recording_gid_redirect d
                ON c.dest_track_musicbrainz_id=d.gid) e
	ON g.dest_track_musicbrainz_id=e.dest_track_musicbrainz_id
	WHERE e.dest_track_musicbrainz_id IS NULL AND g.dest_track_musicbrainz_id IS NOT NULL;

SELECT DISTINCT g.*
	FROM musicbrainz.whois g
	LEFT JOIN (
              SELECT DISTINCT b.dest_track_id, b.dest_track_musicbrainz_id
              	FROM musicbrainz.whois b
                INNER JOIN musicbrainz.recording a
                ON b.dest_track_musicbrainz_id=a.gid
                UNION
                SELECT DISTINCT c.dest_track_id, c.dest_track_musicbrainz_id
                FROM musicbrainz.whois c
                INNER JOIN musicbrainz.recording_gid_redirect d
                ON c.dest_track_musicbrainz_id=d.gid) e
	ON g.dest_track_musicbrainz_id=e.dest_track_musicbrainz_id
	WHERE e.dest_track_musicbrainz_id IS NULL AND g.dest_track_musicbrainz_id IS NOT NULL;
