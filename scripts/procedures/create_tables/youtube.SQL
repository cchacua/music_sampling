DROP TABLE IF EXISTS ws.youtube;

-- Create table of whoissampling

CREATE TABLE ws.youtube
(
youtube_id VARCHAR(50),
view_count bigint
);

--------------------------------------------------------------------------
-- CREATE INDEX
--------------------------------------------------------------------------

-- For the destination track
CREATE INDEX youtube_idx ON ws.youtube (youtube_id);


