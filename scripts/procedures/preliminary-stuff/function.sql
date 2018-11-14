-----------------------------------------------------------------------------------------
-- CREATE SCHEMA ws;

CREATE OR REPLACE FUNCTION ws.dlevestein(IN namevalue VARCHAR, IN threshold float8)
	RETURNS TABLE (
			artist_name VARCHAR, 
			distance float8) 
	AS $$
	BEGIN
		RETURN QUERY SELECT  main_artist_name, 
		levenshtein(upper(main_artist_name), upper(namevalue))/greatest(length(main_artist_name), length(namevalue))::REAL AS dis
	     FROM ws.artists
	     WHERE levenshtein(upper(main_artist_name), upper(namevalue))/greatest(length(main_artist_name), length(namevalue))::REAL  < threshold
	     ORDER BY main_artist_name, dis;
	END;
	$$
	LANGUAGE 'plpgsql';

SELECT * FROM ws.dlevestein('Willie Colon', 0.1);


CREATE OR REPLACE FUNCTION ws.dlevestein(IN namevalue VARCHAR, IN threshold FLOAT8, IN _tablename regclass)
	RETURNS TABLE (
			artist_name VARCHAR, 
			distance float8) 
	AS $$
	BEGIN
		RETURN QUERY
		EXECUTE format('SELECT  main_artist_name, 
		levenshtein(upper(main_artist_name), upper(%2$L))/greatest(length(main_artist_name), length(%2$L))::REAL AS dis
	     FROM %1$s
	     WHERE levenshtein(upper(main_artist_name), upper(%2$L))/greatest(length(main_artist_name), length(%2$L))::REAL  < %3$s
	     ORDER BY main_artist_name, dis', _tablename, namevalue, threshold);
	END;
	$$
	LANGUAGE 'plpgsql';

SELECT * FROM ws.dlevestein('Willie Colon', 0.1, 'ws.artists');



-----------------------------------------------------------------------------------------


-- CREATE SCHEMA ws;

CREATE OR REPLACE FUNCTION ws.get_armbid(IN wsid INT, IN wsname VARCHAR(71), OUT mbid INT, OUT mbname VARCHAR)
	AS $$
	<< wsa >>
		BEGIN
		SELECT wsid AS mbid, wsname AS mbname 
		END;
	SELECT wsid AS mbid, wsname AS mbname
	$$
	LANGUAGE plpgsql;

SELECT * FROM ws.get_armbid(1, 'chris');
