--------------------------------------------------------------------------
-- PRELIMINARY QUERYS
--------------------------------------------------------------------------


-- List of databases
\t

-- List of tables
\dt

-- Select tables 

SELECT a.* FROM musicbrainz.recording a LIMIT 10 OFFSET 2;

SELECT a.* FROM musicbrainz.recording a 
WHERE a.id=201;

SELECT a.* FROM musicbrainz.artist_credit a 
WHERE a.id=53876;

SELECT a.* FROM musicbrainz.area a LIMIT 20;
