-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-- ISRC using the link between WS and MB done by WS
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

\d ws.recording_mb

SELECT COUNT(DISTINCT a.wsrecording)
	FROM ws.recording_mb a
	INNER JOIN musicbrainz.isrc b
	ON a.mbrecording=b.recording;
/*
 count 
-------
 50774
(1 row)

Time: 2060,774 ms (00:02,061)

So, from 236.686 ids, there are 50774 that can be found in MB
(This is a preliminary value, as several mbids in the ws database are wrong)
50774/236686=0.2145205
*/

SELECT COUNT(DISTINCT b.isrc)
	FROM ws.recording_mb a
	INNER JOIN musicbrainz.isrc b
	ON a.mbrecording=b.recording;
/*
 count 
-------
 55628
(1 row)

Time: 1159,297 ms (00:01,159)

This is the total of different isrc
*/


SELECT COUNT(DISTINCT a.mbrecording)
	FROM ws.recording_mb a
	INNER JOIN musicbrainz.isrc b
	ON a.mbrecording=b.recording;
/*
 count 
-------
 48904
(1 row)

Time: 247,206 ms
So, there are some mbrecordings with more than one isrc
*/




