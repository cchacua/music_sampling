

-- Merge

-- Merge with destination

SELECT a.gid, a.name, a.length, b.dest_track_name, b.dest_track_musicbrainz_id, b.source_track_name, b.source_track_musicbrainz_id
FROM musicbrainz.whois b
INNER JOIN musicbrainz.recording a
ON b.dest_track_musicbrainz_id=a.gid
LIMIT 10;

-- Merge with source

SELECT a.gid, a.name, a.length, b.dest_track_name, b.dest_track_musicbrainz_id, b.source_track_name, b.source_track_musicbrainz_id
FROM musicbrainz.whois b
INNER JOIN musicbrainz.recording a
ON b.source_track_musicbrainz_id=a.gid
LIMIT 10;
