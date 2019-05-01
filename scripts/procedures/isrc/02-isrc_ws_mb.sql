-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- ISRC using the link between WS and MB done by WS
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

\d ws.recording_mb

SELECT COUNT(DISTINCT b.id)
	FROM ws.recording_mb a
	INNER JOIN musicbrainz.isrc b
	ON a.mbid=b.id;
/*
 count 
-------
 32984
(1 row)

Time: 395,487 ms

So, from 236686 ids, there are 32.984 that can be found in MB
(This is a preliminary value, as several mbids in the ws database are wrong)
*/

SELECT COUNT(DISTINCT b.isrc)
	FROM ws.recording_mb a
	INNER JOIN musicbrainz.isrc b
	ON a.mbid=b.id;
/*
 count 
-------
 32811
(1 row)

Time: 372,789 ms
*/
