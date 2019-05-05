\connect musicbrainz;
\timing

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- Table with all the artist names od MB
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
\d ws.mb_recording_name

DROP TABLE IF EXISTS ws.mb_recording_name;
CREATE TABLE ws.mb_recording_name AS
SELECT DISTINCT recording, sort_name AS name, UPPER(sort_name) AS uname
	FROM musicbrainz.recording_alias
	WHERE name<>sort_name
UNION 
SELECT DISTINCT recording, name, UPPER(name) AS uname
	FROM musicbrainz.recording_alias
UNION 
SELECT DISTINCT id AS recording, name, UPPER(name) AS uname
	FROM musicbrainz.recording;

/*
SELECT 20,467,261
*/

CREATE INDEX mbrecordingname_unamex1 ON ws.mb_recording_name USING GIN (uname gin_trgm_ops);
CREATE INDEX mbrecordingname_unamex2 ON ws.mb_recording_name USING GIN(to_tsvector('mb_simple', uname));
CREATE INDEX mbrecordingname_unamex3 ON ws.mb_recording_name (uname);
CREATE INDEX mbrecordingname_recordingx ON ws.mb_recording_name (recording);

SELECT * FROM ws.mb_recording_name LIMIT 100;
