--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: addgeometrycolumn(character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$ 
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('','',$1,$2,$3,$4,$5) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, integer, character varying, integer) OWNER TO postgres;

--
-- Name: addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STABLE STRICT
    AS $_$ 
DECLARE
	ret  text;
BEGIN
	SELECT AddGeometryColumn('',$1,$2,$3,$4,$5,$6) into ret;
	RETURN ret;
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;

--
-- Name: addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) RETURNS text
    LANGUAGE plpgsql STRICT
    AS $_$
DECLARE
	catalog_name alias for $1;
	schema_name alias for $2;
	table_name alias for $3;
	column_name alias for $4;
	new_srid alias for $5;
	new_type alias for $6;
	new_dim alias for $7;
	rec RECORD;
	sr varchar;
	real_schema name;
	sql text;

BEGIN

	-- Verify geometry type
	IF ( NOT ( (new_type = 'GEOMETRY') OR
			   (new_type = 'GEOMETRYCOLLECTION') OR
			   (new_type = 'POINT') OR
			   (new_type = 'MULTIPOINT') OR
			   (new_type = 'POLYGON') OR
			   (new_type = 'MULTIPOLYGON') OR
			   (new_type = 'LINESTRING') OR
			   (new_type = 'MULTILINESTRING') OR
			   (new_type = 'GEOMETRYCOLLECTIONM') OR
			   (new_type = 'POINTM') OR
			   (new_type = 'MULTIPOINTM') OR
			   (new_type = 'POLYGONM') OR
			   (new_type = 'MULTIPOLYGONM') OR
			   (new_type = 'LINESTRINGM') OR
			   (new_type = 'MULTILINESTRINGM') OR
			   (new_type = 'CIRCULARSTRING') OR
			   (new_type = 'CIRCULARSTRINGM') OR
			   (new_type = 'COMPOUNDCURVE') OR
			   (new_type = 'COMPOUNDCURVEM') OR
			   (new_type = 'CURVEPOLYGON') OR
			   (new_type = 'CURVEPOLYGONM') OR
			   (new_type = 'MULTICURVE') OR
			   (new_type = 'MULTICURVEM') OR
			   (new_type = 'MULTISURFACE') OR
			   (new_type = 'MULTISURFACEM')) )
	THEN
		RAISE EXCEPTION 'Invalid type name - valid ones are:
	POINT, MULTIPOINT,
	LINESTRING, MULTILINESTRING,
	POLYGON, MULTIPOLYGON,
	CIRCULARSTRING, COMPOUNDCURVE, MULTICURVE,
	CURVEPOLYGON, MULTISURFACE,
	GEOMETRY, GEOMETRYCOLLECTION,
	POINTM, MULTIPOINTM,
	LINESTRINGM, MULTILINESTRINGM,
	POLYGONM, MULTIPOLYGONM,
	CIRCULARSTRINGM, COMPOUNDCURVEM, MULTICURVEM
	CURVEPOLYGONM, MULTISURFACEM,
	or GEOMETRYCOLLECTIONM';
		RETURN 'fail';
	END IF;


	-- Verify dimension
	IF ( (new_dim >4) OR (new_dim <0) ) THEN
		RAISE EXCEPTION 'invalid dimension';
		RETURN 'fail';
	END IF;

	IF ( (new_type LIKE '%M') AND (new_dim!=3) ) THEN
		RAISE EXCEPTION 'TypeM needs 3 dimensions';
		RETURN 'fail';
	END IF;


	-- Verify SRID
	IF ( new_srid != -1 ) THEN
		SELECT SRID INTO sr FROM spatial_ref_sys WHERE SRID = new_srid;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'AddGeometryColumns() - invalid SRID';
			RETURN 'fail';
		END IF;
	END IF;


	-- Verify schema
	IF ( schema_name IS NOT NULL AND schema_name != '' ) THEN
		sql := 'SELECT nspname FROM pg_namespace ' ||
			'WHERE text(nspname) = ' || quote_literal(schema_name) ||
			'LIMIT 1';
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Schema % is not a valid schemaname', quote_literal(schema_name);
			RETURN 'fail';
		END IF;
	END IF;

	IF ( real_schema IS NULL ) THEN
		RAISE DEBUG 'Detecting schema';
		sql := 'SELECT n.nspname AS schemaname ' ||
			'FROM pg_catalog.pg_class c ' ||
			  'JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace ' ||
			'WHERE c.relkind = ' || quote_literal('r') ||
			' AND n.nspname NOT IN (' || quote_literal('pg_catalog') || ', ' || quote_literal('pg_toast') || ')' ||
			' AND pg_catalog.pg_table_is_visible(c.oid)' ||
			' AND c.relname = ' || quote_literal(table_name);
		RAISE DEBUG '%', sql;
		EXECUTE sql INTO real_schema;

		IF ( real_schema IS NULL ) THEN
			RAISE EXCEPTION 'Table % does not occur in the search_path', quote_literal(table_name);
			RETURN 'fail';
		END IF;
	END IF;
	

	-- Add geometry column to table
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD COLUMN ' || quote_ident(column_name) ||
		' geometry ';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Delete stale record in geometry_columns (if any)
	sql := 'DELETE FROM geometry_columns WHERE
		f_table_catalog = ' || quote_literal('') ||
		' AND f_table_schema = ' ||
		quote_literal(real_schema) ||
		' AND f_table_name = ' || quote_literal(table_name) ||
		' AND f_geometry_column = ' || quote_literal(column_name);
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add record in geometry_columns
	sql := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema,f_table_name,' ||
										  'f_geometry_column,coord_dimension,srid,type)' ||
		' VALUES (' ||
		quote_literal('') || ',' ||
		quote_literal(real_schema) || ',' ||
		quote_literal(table_name) || ',' ||
		quote_literal(column_name) || ',' ||
		new_dim::text || ',' ||
		new_srid::text || ',' ||
		quote_literal(new_type) || ')';
	RAISE DEBUG '%', sql;
	EXECUTE sql;


	-- Add table CHECKs
	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_srid_' || column_name)
		|| ' CHECK (ST_SRID(' || quote_ident(column_name) ||
		') = ' || new_srid::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	sql := 'ALTER TABLE ' ||
		quote_ident(real_schema) || '.' || quote_ident(table_name)
		|| ' ADD CONSTRAINT '
		|| quote_ident('enforce_dims_' || column_name)
		|| ' CHECK (ST_NDims(' || quote_ident(column_name) ||
		') = ' || new_dim::text || ')' ;
	RAISE DEBUG '%', sql;
	EXECUTE sql;

	IF ( NOT (new_type = 'GEOMETRY')) THEN
		sql := 'ALTER TABLE ' ||
			quote_ident(real_schema) || '.' || quote_ident(table_name) || ' ADD CONSTRAINT ' ||
			quote_ident('enforce_geotype_' || column_name) ||
			' CHECK (GeometryType(' ||
			quote_ident(column_name) || ')=' ||
			quote_literal(new_type) || ' OR (' ||
			quote_ident(column_name) || ') is null)';
		RAISE DEBUG '%', sql;
		EXECUTE sql;
	END IF;

	RETURN
		real_schema || '.' ||
		table_name || '.' || column_name ||
		' SRID:' || new_srid::text ||
		' TYPE:' || new_type ||
		' DIMS:' || new_dim::text || ' ';
END;
$_$;


ALTER FUNCTION public.addgeometrycolumn(character varying, character varying, character varying, character varying, integer, character varying, integer) OWNER TO postgres;

--
-- Name: affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1,  $2, $3, 0,  $4, $5, 0,  0, 0, 1,  $6, $7, 0)$_$;


ALTER FUNCTION public.affine(geometry, double precision, double precision, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: asgml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asgml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, 15, 0)$_$;


ALTER FUNCTION public.asgml(geometry) OWNER TO postgres;

--
-- Name: asgml(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION asgml(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, $2, 0)$_$;


ALTER FUNCTION public.asgml(geometry, integer) OWNER TO postgres;

--
-- Name: askml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, transform($1,4326), 15)$_$;


ALTER FUNCTION public.askml(geometry) OWNER TO postgres;

--
-- Name: askml(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, transform($1,4326), $2)$_$;


ALTER FUNCTION public.askml(geometry, integer) OWNER TO postgres;

--
-- Name: askml(integer, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION askml(integer, geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML($1, transform($2,4326), $3)$_$;


ALTER FUNCTION public.askml(integer, geometry, integer) OWNER TO postgres;

--
-- Name: bdmpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bdmpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$ 
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := multi(BuildArea(mline));

	RETURN geom;
END;
$_$;


ALTER FUNCTION public.bdmpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: bdpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bdpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$ 
DECLARE
	geomtext alias for $1;
	srid alias for $2;
	mline geometry;
	geom geometry;
BEGIN
	mline := MultiLineStringFromText(geomtext, srid);

	IF mline IS NULL
	THEN
		RAISE EXCEPTION 'Input is not a MultiLinestring';
	END IF;

	geom := BuildArea(mline);

	IF GeometryType(geom) != 'POLYGON'
	THEN
		RAISE EXCEPTION 'Input returns more then a single polygon, try using BdMPolyFromText instead';
	END IF;

	RETURN geom;
END;
$_$;


ALTER FUNCTION public.bdpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: find_extent(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_extent(text, text) RETURNS box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	tablename alias for $1;
	columnname alias for $2;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT extent("' || columnname || '") FROM "' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP; 
END;
$_$;


ALTER FUNCTION public.find_extent(text, text) OWNER TO postgres;

--
-- Name: find_extent(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION find_extent(text, text, text) RETURNS box2d
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$
DECLARE
	schemaname alias for $1;
	tablename alias for $2;
	columnname alias for $3;
	myrec RECORD;

BEGIN
	FOR myrec IN EXECUTE 'SELECT extent("' || columnname || '") FROM "' || schemaname || '"."' || tablename || '"' LOOP
		return myrec.extent;
	END LOOP; 
END;
$_$;


ALTER FUNCTION public.find_extent(text, text, text) OWNER TO postgres;

--
-- Name: fix_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION fix_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	mislinked record;
	result text;
	linked integer;
	deleted integer;
	foundschema integer;
BEGIN

	-- Since 7.3 schema support has been added.
	-- Previous postgis versions used to put the database name in
	-- the schema column. This needs to be fixed, so we try to 
	-- set the correct schema for each geometry_colums record
	-- looking at table, column, type and srid.
	UPDATE geometry_columns SET f_table_schema = n.nspname
		FROM pg_namespace n, pg_class c, pg_attribute a,
			pg_constraint sridcheck, pg_constraint typecheck
	        WHERE ( f_table_schema is NULL
		OR f_table_schema = ''
	        OR f_table_schema NOT IN (
	                SELECT nspname::varchar
	                FROM pg_namespace nn, pg_class cc, pg_attribute aa
	                WHERE cc.relnamespace = nn.oid
	                AND cc.relname = f_table_name::name
	                AND aa.attrelid = cc.oid
	                AND aa.attname = f_geometry_column::name))
	        AND f_table_name::name = c.relname
	        AND c.oid = a.attrelid
	        AND c.relnamespace = n.oid
	        AND f_geometry_column::name = a.attname

	        AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(srid(% = %)'
	        AND sridcheck.consrc ~ textcat(' = ', srid::text)

	        AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype(%) = ''%''::text) OR (% IS NULL))'
	        AND typecheck.consrc ~ textcat(' = ''', type::text)

	        AND NOT EXISTS (
	                SELECT oid FROM geometry_columns gc
	                WHERE c.relname::varchar = gc.f_table_name
	                AND n.nspname::varchar = gc.f_table_schema
	                AND a.attname::varchar = gc.f_geometry_column
	        );

	GET DIAGNOSTICS foundschema = ROW_COUNT;

	-- no linkage to system table needed
	return 'fixed:'||foundschema::text;

END;
$$;


ALTER FUNCTION public.fix_geometry_columns() OWNER TO postgres;

--
-- Name: geomcollfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromtext(text) OWNER TO postgres;

--
-- Name: geomcollfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromtext(text, integer) OWNER TO postgres;

--
-- Name: geomcollfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromwkb(bytea) OWNER TO postgres;

--
-- Name: geomcollfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomcollfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromWKB($1, $2)) = 'GEOMETRYCOLLECTION'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.geomcollfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: geomfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT geometryfromtext($1)$_$;


ALTER FUNCTION public.geomfromtext(text) OWNER TO postgres;

--
-- Name: geomfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT geometryfromtext($1, $2)$_$;


ALTER FUNCTION public.geomfromtext(text, integer) OWNER TO postgres;

--
-- Name: geomfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION geomfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT setSRID(GeomFromWKB($1), $2)$_$;


ALTER FUNCTION public.geomfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: linefromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'LINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromtext(text) OWNER TO postgres;

--
-- Name: linefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'LINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromtext(text, integer) OWNER TO postgres;

--
-- Name: linefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromwkb(bytea) OWNER TO postgres;

--
-- Name: linefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: linestringfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1)$_$;


ALTER FUNCTION public.linestringfromtext(text) OWNER TO postgres;

--
-- Name: linestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT LineFromText($1, $2)$_$;


ALTER FUNCTION public.linestringfromtext(text, integer) OWNER TO postgres;

--
-- Name: linestringfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'LINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linestringfromwkb(bytea) OWNER TO postgres;

--
-- Name: linestringfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION linestringfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'LINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.linestringfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: locate_along_measure(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION locate_along_measure(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT locate_between_measures($1, $2, $2) $_$;


ALTER FUNCTION public.locate_along_measure(geometry, double precision) OWNER TO postgres;

--
-- Name: mlinefromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTILINESTRING'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromtext(text) OWNER TO postgres;

--
-- Name: mlinefromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE
	WHEN geometrytype(GeomFromText($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromtext(text, integer) OWNER TO postgres;

--
-- Name: mlinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromwkb(bytea) OWNER TO postgres;

--
-- Name: mlinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mlinefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mlinefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: mpointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromtext(text) OWNER TO postgres;

--
-- Name: mpointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1,$2)) = 'MULTIPOINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromtext(text, integer) OWNER TO postgres;

--
-- Name: mpointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromwkb(bytea) OWNER TO postgres;

--
-- Name: mpointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: mpolyfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'MULTIPOLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromtext(text) OWNER TO postgres;

--
-- Name: mpolyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromtext(text, integer) OWNER TO postgres;

--
-- Name: mpolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromwkb(bytea) OWNER TO postgres;

--
-- Name: mpolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mpolyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.mpolyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multilinefromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinefromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multilinefromwkb(bytea) OWNER TO postgres;

--
-- Name: multilinefromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinefromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTILINESTRING'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multilinefromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multilinestringfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinestringfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_MLineFromText($1)$_$;


ALTER FUNCTION public.multilinestringfromtext(text) OWNER TO postgres;

--
-- Name: multilinestringfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multilinestringfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MLineFromText($1, $2)$_$;


ALTER FUNCTION public.multilinestringfromtext(text, integer) OWNER TO postgres;

--
-- Name: multipointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1)$_$;


ALTER FUNCTION public.multipointfromtext(text) OWNER TO postgres;

--
-- Name: multipointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPointFromText($1, $2)$_$;


ALTER FUNCTION public.multipointfromtext(text, integer) OWNER TO postgres;

--
-- Name: multipointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipointfromwkb(bytea) OWNER TO postgres;

--
-- Name: multipointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'MULTIPOINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multipolyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipolyfromwkb(bytea) OWNER TO postgres;

--
-- Name: multipolyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'MULTIPOLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.multipolyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: multipolygonfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolygonfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1)$_$;


ALTER FUNCTION public.multipolygonfromtext(text) OWNER TO postgres;

--
-- Name: multipolygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION multipolygonfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT MPolyFromText($1, $2)$_$;


ALTER FUNCTION public.multipolygonfromtext(text, integer) OWNER TO postgres;

--
-- Name: pointfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POINT'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromtext(text) OWNER TO postgres;

--
-- Name: pointfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POINT'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromtext(text, integer) OWNER TO postgres;

--
-- Name: pointfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POINT'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromwkb(bytea) OWNER TO postgres;

--
-- Name: pointfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION pointfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'POINT'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.pointfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: polyfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1)) = 'POLYGON'
	THEN GeomFromText($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromtext(text) OWNER TO postgres;

--
-- Name: polyfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromText($1, $2)) = 'POLYGON'
	THEN GeomFromText($1,$2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromtext(text, integer) OWNER TO postgres;

--
-- Name: polyfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromwkb(bytea) OWNER TO postgres;

--
-- Name: polyfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polyfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1, $2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polyfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: polygonfromtext(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromtext(text) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1)$_$;


ALTER FUNCTION public.polygonfromtext(text) OWNER TO postgres;

--
-- Name: polygonfromtext(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromtext(text, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT PolyFromText($1, $2)$_$;


ALTER FUNCTION public.polygonfromtext(text, integer) OWNER TO postgres;

--
-- Name: polygonfromwkb(bytea); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromwkb(bytea) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1)) = 'POLYGON'
	THEN GeomFromWKB($1)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polygonfromwkb(bytea) OWNER TO postgres;

--
-- Name: polygonfromwkb(bytea, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION polygonfromwkb(bytea, integer) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
	SELECT CASE WHEN geometrytype(GeomFromWKB($1,$2)) = 'POLYGON'
	THEN GeomFromWKB($1, $2)
	ELSE NULL END
	$_$;


ALTER FUNCTION public.polygonfromwkb(bytea, integer) OWNER TO postgres;

--
-- Name: populate_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION populate_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted    integer;
	oldcount    integer;
	probed      integer;
	stale       integer;
	gcs         RECORD;
	gc          RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;
	
BEGIN
	SELECT count(*) INTO oldcount FROM geometry_columns;
	inserted := 0;

	EXECUTE 'TRUNCATE geometry_columns';

	-- Count the number of geometry columns in all tables and views
	SELECT count(DISTINCT c.oid) INTO probed
	FROM pg_class c, 
	     pg_attribute a, 
	     pg_type t, 
	     pg_namespace n
	WHERE (c.relkind = 'r' OR c.relkind = 'v')
	AND t.typname = 'geometry'
	AND a.attisdropped = false
	AND a.atttypid = t.oid
	AND a.attrelid = c.oid
	AND c.relnamespace = n.oid
	AND n.nspname NOT ILIKE 'pg_temp%';

	-- Iterate through all non-dropped geometry columns
	RAISE DEBUG 'Processing Tables.....';

	FOR gcs IN 
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
	    FROM pg_class c, 
	         pg_attribute a, 
	         pg_type t, 
	         pg_namespace n
	    WHERE c.relkind = 'r'
	    AND t.typname = 'geometry'
	    AND a.attisdropped = false
	    AND a.atttypid = t.oid
	    AND a.attrelid = c.oid
	    AND c.relnamespace = n.oid
	    AND n.nspname NOT ILIKE 'pg_temp%'
	LOOP
	
	inserted := inserted + populate_geometry_columns(gcs.oid);
	END LOOP;
	
	-- Add views to geometry columns table
	RAISE DEBUG 'Processing Views.....';
	FOR gcs IN 
	SELECT DISTINCT ON (c.oid) c.oid, n.nspname, c.relname
	    FROM pg_class c, 
	         pg_attribute a, 
	         pg_type t, 
	         pg_namespace n
	    WHERE c.relkind = 'v'
	    AND t.typname = 'geometry'
	    AND a.attisdropped = false
	    AND a.atttypid = t.oid
	    AND a.attrelid = c.oid
	    AND c.relnamespace = n.oid
	LOOP            
	    
	inserted := inserted + populate_geometry_columns(gcs.oid);
	END LOOP;

	IF oldcount > inserted THEN
	stale = oldcount-inserted;
	ELSE
	stale = 0;
	END IF;

	RETURN 'probed:' ||probed|| ' inserted:'||inserted|| ' conflicts:'||probed-inserted|| ' deleted:'||stale;
END

$$;


ALTER FUNCTION public.populate_geometry_columns() OWNER TO postgres;

--
-- Name: populate_geometry_columns(oid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION populate_geometry_columns(tbl_oid oid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
	gcs         RECORD;
	gc          RECORD;
	gsrid       integer;
	gndims      integer;
	gtype       text;
	query       text;
	gc_is_valid boolean;
	inserted    integer;
	
BEGIN
	inserted := 0;
	
	-- Iterate through all geometry columns in this table
	FOR gcs IN 
	SELECT n.nspname, c.relname, a.attname
	    FROM pg_class c, 
	         pg_attribute a, 
	         pg_type t, 
	         pg_namespace n
	    WHERE c.relkind = 'r'
	    AND t.typname = 'geometry'
	    AND a.attisdropped = false
	    AND a.atttypid = t.oid
	    AND a.attrelid = c.oid
	    AND c.relnamespace = n.oid
	    AND n.nspname NOT ILIKE 'pg_temp%'
	    AND c.oid = tbl_oid
	LOOP
	
	RAISE DEBUG 'Processing table %.%.%', gcs.nspname, gcs.relname, gcs.attname;

	DELETE FROM geometry_columns 
	  WHERE f_table_schema = quote_ident(gcs.nspname) 
	  AND f_table_name = quote_ident(gcs.relname)
	  AND f_geometry_column = quote_ident(gcs.attname);
	
	gc_is_valid := true;
	
	-- Try to find srid check from system tables (pg_constraint)
	gsrid := 
	    (SELECT replace(replace(split_part(s.consrc, ' = ', 2), ')', ''), '(', '') 
	     FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s 
	     WHERE n.nspname = gcs.nspname 
	     AND c.relname = gcs.relname 
	     AND a.attname = gcs.attname 
	     AND a.attrelid = c.oid
	     AND s.connamespace = n.oid
	     AND s.conrelid = c.oid
	     AND a.attnum = ANY (s.conkey)
	     AND s.consrc LIKE '%srid(% = %');
	IF (gsrid IS NULL) THEN 
	    -- Try to find srid from the geometry itself
	    EXECUTE 'SELECT public.srid(' || quote_ident(gcs.attname) || ') 
	             FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gsrid := gc.srid;
	    
	    -- Try to apply srid check to column
	    IF (gsrid IS NOT NULL) THEN
	        BEGIN
	            EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	                     ADD CONSTRAINT ' || quote_ident('enforce_srid_' || gcs.attname) || ' 
	                     CHECK (srid(' || quote_ident(gcs.attname) || ') = ' || gsrid || ')';
	        EXCEPTION
	            WHEN check_violation THEN
	                RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (srid(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gsrid;
	                gc_is_valid := false;
	        END;
	    END IF;
	END IF;
	
	-- Try to find ndims check from system tables (pg_constraint)
	gndims := 
	    (SELECT replace(split_part(s.consrc, ' = ', 2), ')', '') 
	     FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s 
	     WHERE n.nspname = gcs.nspname 
	     AND c.relname = gcs.relname 
	     AND a.attname = gcs.attname 
	     AND a.attrelid = c.oid
	     AND s.connamespace = n.oid
	     AND s.conrelid = c.oid
	     AND a.attnum = ANY (s.conkey)
	     AND s.consrc LIKE '%ndims(% = %');
	IF (gndims IS NULL) THEN
	    -- Try to find ndims from the geometry itself
	    EXECUTE 'SELECT public.ndims(' || quote_ident(gcs.attname) || ') 
	             FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gndims := gc.ndims;
	    
	    -- Try to apply ndims check to column
	    IF (gndims IS NOT NULL) THEN
	        BEGIN
	            EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	                     ADD CONSTRAINT ' || quote_ident('enforce_dims_' || gcs.attname) || ' 
	                     CHECK (ndims(' || quote_ident(gcs.attname) || ') = '||gndims||')';
	        EXCEPTION
	            WHEN check_violation THEN
	                RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not apply constraint CHECK (ndims(%) = %)', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname), quote_ident(gcs.attname), gndims;
	                gc_is_valid := false;
	        END;
	    END IF;
	END IF;
	
	-- Try to find geotype check from system tables (pg_constraint)
	gtype := 
	    (SELECT replace(split_part(s.consrc, '''', 2), ')', '') 
	     FROM pg_class c, pg_namespace n, pg_attribute a, pg_constraint s 
	     WHERE n.nspname = gcs.nspname 
	     AND c.relname = gcs.relname 
	     AND a.attname = gcs.attname 
	     AND a.attrelid = c.oid
	     AND s.connamespace = n.oid
	     AND s.conrelid = c.oid
	     AND a.attnum = ANY (s.conkey)
	     AND s.consrc LIKE '%geometrytype(% = %');
	IF (gtype IS NULL) THEN
	    -- Try to find geotype from the geometry itself
	    EXECUTE 'SELECT public.geometrytype(' || quote_ident(gcs.attname) || ') 
	             FROM ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gtype := gc.geometrytype;
	    --IF (gtype IS NULL) THEN
	    --    gtype := 'GEOMETRY';
	    --END IF;
	    
	    -- Try to apply geometrytype check to column
	    IF (gtype IS NOT NULL) THEN
	        BEGIN
	            EXECUTE 'ALTER TABLE ONLY ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	            ADD CONSTRAINT ' || quote_ident('enforce_geotype_' || gcs.attname) || ' 
	            CHECK ((geometrytype(' || quote_ident(gcs.attname) || ') = ' || quote_literal(gtype) || ') OR (' || quote_ident(gcs.attname) || ' IS NULL))';
	        EXCEPTION
	            WHEN check_violation THEN
	                -- No geometry check can be applied. This column contains a number of geometry types.
	                RAISE WARNING 'Could not add geometry type check (%) to table column: %.%.%', gtype, quote_ident(gcs.nspname),quote_ident(gcs.relname),quote_ident(gcs.attname);
	        END;
	    END IF;
	END IF;
	        
	IF (gsrid IS NULL) THEN             
	    RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the srid', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSIF (gndims IS NULL) THEN
	    RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the number of dimensions', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSIF (gtype IS NULL) THEN
	    RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine the geometry type', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	ELSE
	    -- Only insert into geometry_columns if table constraints could be applied.
	    IF (gc_is_valid) THEN
	        INSERT INTO geometry_columns (f_table_catalog,f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type) 
	        VALUES ('', gcs.nspname, gcs.relname, gcs.attname, gndims, gsrid, gtype);
	        inserted := inserted + 1;
	    END IF;
	END IF;
	END LOOP;

	-- Add views to geometry columns table
	FOR gcs IN 
	SELECT n.nspname, c.relname, a.attname
	    FROM pg_class c, 
	         pg_attribute a, 
	         pg_type t, 
	         pg_namespace n
	    WHERE c.relkind = 'v'
	    AND t.typname = 'geometry'
	    AND a.attisdropped = false
	    AND a.atttypid = t.oid
	    AND a.attrelid = c.oid
	    AND c.relnamespace = n.oid
	    AND n.nspname NOT ILIKE 'pg_temp%'
	    AND c.oid = tbl_oid
	LOOP            
	    RAISE DEBUG 'Processing view %.%.%', gcs.nspname, gcs.relname, gcs.attname;

	    EXECUTE 'SELECT public.ndims(' || quote_ident(gcs.attname) || ') 
	             FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gndims := gc.ndims;
	    
	    EXECUTE 'SELECT public.srid(' || quote_ident(gcs.attname) || ') 
	             FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gsrid := gc.srid;
	    
	    EXECUTE 'SELECT public.geometrytype(' || quote_ident(gcs.attname) || ') 
	             FROM ' || quote_ident(gcs.nspname) || '.' || quote_ident(gcs.relname) || ' 
	             WHERE ' || quote_ident(gcs.attname) || ' IS NOT NULL LIMIT 1' 
	        INTO gc;
	    gtype := gc.geometrytype;
	    
	    IF (gndims IS NULL) THEN
	        RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine ndims', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	    ELSIF (gsrid IS NULL) THEN
	        RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine srid', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	    ELSIF (gtype IS NULL) THEN
	        RAISE WARNING 'Not inserting ''%'' in ''%.%'' into geometry_columns: could not determine gtype', quote_ident(gcs.attname), quote_ident(gcs.nspname), quote_ident(gcs.relname);
	    ELSE
	        query := 'INSERT INTO geometry_columns (f_table_catalog,f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type) ' ||
	                 'VALUES ('''', ' || quote_literal(gcs.nspname) || ',' || quote_literal(gcs.relname) || ',' || quote_literal(gcs.attname) || ',' || gndims || ',' || gsrid || ',' || quote_literal(gtype) || ')';
	        EXECUTE query;
	        inserted := inserted + 1;
	    END IF;
	END LOOP;
	
	RETURN inserted;
END

$$;


ALTER FUNCTION public.populate_geometry_columns(tbl_oid oid) OWNER TO postgres;

--
-- Name: probe_geometry_columns(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION probe_geometry_columns() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	inserted integer;
	oldcount integer;
	probed integer;
	stale integer;
BEGIN

	SELECT count(*) INTO oldcount FROM geometry_columns;

	SELECT count(*) INTO probed
		FROM pg_class c, pg_attribute a, pg_type t, 
			pg_namespace n,
			pg_constraint sridcheck, pg_constraint typecheck

		WHERE t.typname = 'geometry'
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND sridcheck.connamespace = n.oid
		AND typecheck.connamespace = n.oid
		AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(srid('||a.attname||') = %)'
		AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype('||a.attname||') = ''%''::text) OR (% IS NULL))'
		;

	INSERT INTO geometry_columns SELECT
		''::varchar as f_table_catalogue,
		n.nspname::varchar as f_table_schema,
		c.relname::varchar as f_table_name,
		a.attname::varchar as f_geometry_column,
		2 as coord_dimension,
		trim(both  ' =)' from 
			replace(replace(split_part(
				sridcheck.consrc, ' = ', 2), ')', ''), '(', ''))::integer AS srid,
		trim(both ' =)''' from substr(typecheck.consrc, 
			strpos(typecheck.consrc, '='),
			strpos(typecheck.consrc, '::')-
			strpos(typecheck.consrc, '=')
			))::varchar as type
		FROM pg_class c, pg_attribute a, pg_type t, 
			pg_namespace n,
			pg_constraint sridcheck, pg_constraint typecheck
		WHERE t.typname = 'geometry'
		AND a.atttypid = t.oid
		AND a.attrelid = c.oid
		AND c.relnamespace = n.oid
		AND sridcheck.connamespace = n.oid
		AND typecheck.connamespace = n.oid
		AND sridcheck.conrelid = c.oid
		AND sridcheck.consrc LIKE '(st_srid('||a.attname||') = %)'
		AND typecheck.conrelid = c.oid
		AND typecheck.consrc LIKE
		'((geometrytype('||a.attname||') = ''%''::text) OR (% IS NULL))'

	        AND NOT EXISTS (
	                SELECT oid FROM geometry_columns gc
	                WHERE c.relname::varchar = gc.f_table_name
	                AND n.nspname::varchar = gc.f_table_schema
	                AND a.attname::varchar = gc.f_geometry_column
	        );

	GET DIAGNOSTICS inserted = ROW_COUNT;

	IF oldcount > probed THEN
		stale = oldcount-probed;
	ELSE
		stale = 0;
	END IF;

	RETURN 'probed:'||probed::text||
		' inserted:'||inserted::text||
		' conflicts:'||(probed-inserted)::text||
		' stale:'||stale::text;
END

$$;


ALTER FUNCTION public.probe_geometry_columns() OWNER TO postgres;

--
-- Name: rename_geometry_table_constraints(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rename_geometry_table_constraints() RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT 'rename_geometry_table_constraint() is obsoleted'::text
$$;


ALTER FUNCTION public.rename_geometry_table_constraints() OWNER TO postgres;

--
-- Name: rotate(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotate(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT rotateZ($1, $2)$_$;


ALTER FUNCTION public.rotate(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatex(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatex(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1, 1, 0, 0, 0, cos($2), -sin($2), 0, sin($2), cos($2), 0, 0, 0)$_$;


ALTER FUNCTION public.rotatex(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatey(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatey(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1,  cos($2), 0, sin($2),  0, 1, 0,  -sin($2), 0, cos($2), 0,  0, 0)$_$;


ALTER FUNCTION public.rotatey(geometry, double precision) OWNER TO postgres;

--
-- Name: rotatez(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION rotatez(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1,  cos($2), -sin($2), 0,  sin($2), cos($2), 0,  0, 0, 1,  0, 0, 0)$_$;


ALTER FUNCTION public.rotatez(geometry, double precision) OWNER TO postgres;

--
-- Name: scale(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION scale(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT scale($1, $2, $3, 1)$_$;


ALTER FUNCTION public.scale(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: scale(geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION scale(geometry, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1,  $2, 0, 0,  0, $3, 0,  0, 0, $4,  0, 0, 0)$_$;


ALTER FUNCTION public.scale(geometry, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: se_envelopesintersect(geometry, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_envelopesintersect(geometry, geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ 
	SELECT $1 && $2
	$_$;


ALTER FUNCTION public.se_envelopesintersect(geometry, geometry) OWNER TO postgres;

--
-- Name: se_is3d(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_is3d(geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ 
	SELECT CASE ST_zmflag($1)
	       WHEN 0 THEN false
	       WHEN 1 THEN false
	       WHEN 2 THEN true
	       WHEN 3 THEN true
	       ELSE false
	   END
	$_$;


ALTER FUNCTION public.se_is3d(geometry) OWNER TO postgres;

--
-- Name: se_ismeasured(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_ismeasured(geometry) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ 
	SELECT CASE ST_zmflag($1)
	       WHEN 0 THEN false
	       WHEN 1 THEN true
	       WHEN 2 THEN false
	       WHEN 3 THEN true
	       ELSE false
	   END
	$_$;


ALTER FUNCTION public.se_ismeasured(geometry) OWNER TO postgres;

--
-- Name: se_locatealong(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION se_locatealong(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$ SELECT locate_between_measures($1, $2, $2) $_$;


ALTER FUNCTION public.se_locatealong(geometry, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT SnapToGrid($1, 0, 0, $2, $2)$_$;


ALTER FUNCTION public.snaptogrid(geometry, double precision) OWNER TO postgres;

--
-- Name: snaptogrid(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION snaptogrid(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT SnapToGrid($1, 0, 0, $2, $3)$_$;


ALTER FUNCTION public.snaptogrid(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: st_asgeojson(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgeojson(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGeoJson(1, $1, 15, 0)$_$;


ALTER FUNCTION public.st_asgeojson(geometry) OWNER TO postgres;

--
-- Name: st_asgeojson(integer, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgeojson(integer, geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGeoJson($1, $2, 15, 0)$_$;


ALTER FUNCTION public.st_asgeojson(integer, geometry) OWNER TO postgres;

--
-- Name: st_asgeojson(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgeojson(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGeoJson(1, $1, $2, 0)$_$;


ALTER FUNCTION public.st_asgeojson(geometry, integer) OWNER TO postgres;

--
-- Name: st_asgeojson(integer, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgeojson(integer, geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGeoJson($1, $2, $3, 0)$_$;


ALTER FUNCTION public.st_asgeojson(integer, geometry, integer) OWNER TO postgres;

--
-- Name: st_asgml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, 15, 0)$_$;


ALTER FUNCTION public.st_asgml(geometry) OWNER TO postgres;

--
-- Name: st_asgml(integer, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgml(integer, geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML($1, $2, 15, 0)$_$;


ALTER FUNCTION public.st_asgml(integer, geometry) OWNER TO postgres;

--
-- Name: st_asgml(geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgml(geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML(2, $1, $2, 0)$_$;


ALTER FUNCTION public.st_asgml(geometry, integer) OWNER TO postgres;

--
-- Name: st_asgml(integer, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgml(integer, geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML($1, $2, $3, 0)$_$;


ALTER FUNCTION public.st_asgml(integer, geometry, integer) OWNER TO postgres;

--
-- Name: st_asgml(integer, geometry, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_asgml(integer, geometry, integer, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsGML($1, $2, $3, $4)$_$;


ALTER FUNCTION public.st_asgml(integer, geometry, integer, integer) OWNER TO postgres;

--
-- Name: st_askml(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_askml(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML(2, ST_Transform($1,4326), 15)$_$;


ALTER FUNCTION public.st_askml(geometry) OWNER TO postgres;

--
-- Name: st_askml(integer, geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_askml(integer, geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML($1, ST_Transform($2,4326), 15)$_$;


ALTER FUNCTION public.st_askml(integer, geometry) OWNER TO postgres;

--
-- Name: st_askml(integer, geometry, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_askml(integer, geometry, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT _ST_AsKML($1, ST_Transform($2,4326), $3)$_$;


ALTER FUNCTION public.st_askml(integer, geometry, integer) OWNER TO postgres;

--
-- Name: st_geohash(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_geohash(geometry) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_GeoHash($1, 0)$_$;


ALTER FUNCTION public.st_geohash(geometry) OWNER TO postgres;

--
-- Name: st_minimumboundingcircle(geometry); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION st_minimumboundingcircle(geometry) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT ST_MinimumBoundingCircle($1, 48)$_$;


ALTER FUNCTION public.st_minimumboundingcircle(geometry) OWNER TO postgres;

--
-- Name: translate(geometry, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION translate(geometry, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT translate($1, $2, $3, 0)$_$;


ALTER FUNCTION public.translate(geometry, double precision, double precision) OWNER TO postgres;

--
-- Name: translate(geometry, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION translate(geometry, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1, 1, 0, 0, 0, 1, 0, 0, 0, 1, $2, $3, $4)$_$;


ALTER FUNCTION public.translate(geometry, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: transscale(geometry, double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transscale(geometry, double precision, double precision, double precision, double precision) RETURNS geometry
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT affine($1,  $4, 0, 0,  0, $5, 0, 
		0, 0, 1,  $2 * $4, $3 * $5, 0)$_$;


ALTER FUNCTION public.transscale(geometry, double precision, double precision, double precision, double precision) OWNER TO postgres;

--
-- Name: accum(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE accum(geometry) (
    SFUNC = pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_accum_finalfn
);


ALTER AGGREGATE public.accum(geometry) OWNER TO postgres;

--
-- Name: collect(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE collect(geometry) (
    SFUNC = pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_collect_finalfn
);


ALTER AGGREGATE public.collect(geometry) OWNER TO postgres;

--
-- Name: makeline(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE makeline(geometry) (
    SFUNC = pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_makeline_finalfn
);


ALTER AGGREGATE public.makeline(geometry) OWNER TO postgres;

--
-- Name: memcollect(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE memcollect(geometry) (
    SFUNC = public.st_collect,
    STYPE = geometry
);


ALTER AGGREGATE public.memcollect(geometry) OWNER TO postgres;

--
-- Name: polygonize(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE polygonize(geometry) (
    SFUNC = pgis_geometry_accum_transfn,
    STYPE = pgis_abs,
    FINALFUNC = pgis_geometry_polygonize_finalfn
);


ALTER AGGREGATE public.polygonize(geometry) OWNER TO postgres;

--
-- Name: st_extent3d(geometry); Type: AGGREGATE; Schema: public; Owner: postgres
--

CREATE AGGREGATE st_extent3d(geometry) (
    SFUNC = public.st_combine_bbox,
    STYPE = box3d
);


ALTER AGGREGATE public.st_extent3d(geometry) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: administrators; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE administrators (
    id integer NOT NULL,
    admin_key character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.administrators OWNER TO paul;

--
-- Name: administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE administrators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.administrators_id_seq OWNER TO paul;

--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE administrators_id_seq OWNED BY administrators.id;


--
-- Name: forums; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE forums (
    id integer NOT NULL,
    forum_name character varying(255),
    forum_url character varying(255),
    forum_permissions character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.forums OWNER TO paul;

--
-- Name: forums_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE forums_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forums_id_seq OWNER TO paul;

--
-- Name: forums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE forums_id_seq OWNED BY forums.id;


--
-- Name: half_blocks; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE half_blocks (
    id integer NOT NULL,
    half_block_id character varying(255),
    boundary_t character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fill_color character varying(255),
    the_geom geometry,
    CONSTRAINT enforce_dims_the_geom CHECK ((st_ndims(the_geom) = 2)),
    CONSTRAINT enforce_geotype_the_geom CHECK (((geometrytype(the_geom) = 'MULTIPOLYGON'::text) OR (the_geom IS NULL))),
    CONSTRAINT enforce_srid_the_geom CHECK ((st_srid(the_geom) = 4326))
);


ALTER TABLE public.half_blocks OWNER TO paul;

--
-- Name: half_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE half_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.half_blocks_id_seq OWNER TO paul;

--
-- Name: half_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE half_blocks_id_seq OWNED BY half_blocks.id;


--
-- Name: map_layers; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE map_layers (
    id integer NOT NULL,
    name character varying(255),
    description text,
    layer_mapfile_text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    draw_order integer DEFAULT 50
);


ALTER TABLE public.map_layers OWNER TO paul;

--
-- Name: map_layers_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE map_layers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.map_layers_id_seq OWNER TO paul;

--
-- Name: map_layers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE map_layers_id_seq OWNED BY map_layers.id;


--
-- Name: mapped_lines; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE mapped_lines (
    id integer NOT NULL,
    end_label character varying(255),
    data character varying(255),
    owner_id character varying(255),
    map_layer_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    geometry geometry,
    CONSTRAINT enforce_dims_geometry CHECK ((st_ndims(geometry) = 2)),
    CONSTRAINT enforce_geotype_geometry CHECK (((geometrytype(geometry) = 'LINESTRING'::text) OR (geometry IS NULL))),
    CONSTRAINT enforce_srid_geometry CHECK ((st_srid(geometry) = 4326))
);


ALTER TABLE public.mapped_lines OWNER TO paul;

--
-- Name: mapped_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE mapped_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mapped_lines_id_seq OWNER TO paul;

--
-- Name: mapped_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE mapped_lines_id_seq OWNED BY mapped_lines.id;


--
-- Name: neighbors; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE neighbors (
    id integer NOT NULL,
    first_name1 character varying(255),
    last_name1 character varying(255),
    email_1 character varying(255),
    first_name2 character varying(255),
    last_name2 character varying(255),
    email_2 character varying(255),
    address character varying(255),
    zip character varying(255),
    half_block_id character varying(255),
    phone_1 character varying(255),
    phone_2 character varying(255),
    email_list character varying(255),
    block_captain character varying(255),
    volunteer text,
    resident character varying(255),
    professional character varying(255),
    interest_expertise text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    alias character varying(255),
    years character varying(255),
    sidewalks character varying(255),
    unit character varying(255),
    improvements text,
    why_walk text,
    dont_walk text,
    signup_date date,
    user_id integer,
    location geometry,
    CONSTRAINT enforce_dims_location CHECK ((st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((geometrytype(location) = 'POINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((st_srid(location) = 4326))
);


ALTER TABLE public.neighbors OWNER TO paul;

--
-- Name: neighbors_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE neighbors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.neighbors_id_seq OWNER TO paul;

--
-- Name: neighbors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE neighbors_id_seq OWNED BY neighbors.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying(255),
    short_desc text,
    forum_url character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_boundary geometry,
    CONSTRAINT enforce_dims_project_boundary CHECK ((st_ndims(project_boundary) = 2)),
    CONSTRAINT enforce_geotype_project_boundary CHECK (((geometrytype(project_boundary) = 'POLYGON'::text) OR (project_boundary IS NULL))),
    CONSTRAINT enforce_srid_project_boundary CHECK ((st_srid(project_boundary) = 4326))
);


ALTER TABLE public.projects OWNER TO paul;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO paul;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: projects_users; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE projects_users (
    project_id integer,
    user_id integer
);


ALTER TABLE public.projects_users OWNER TO paul;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE public.roles OWNER TO paul;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO paul;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE roles_users (
    role_id integer,
    user_id integer
);


ALTER TABLE public.roles_users OWNER TO paul;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO paul;

--
-- Name: theme_map_layers; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE theme_map_layers (
    id integer NOT NULL,
    theme_map_id integer,
    map_layer_id integer,
    line_color character varying(255),
    fill_color character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_base_layer boolean DEFAULT false,
    opacity integer,
    line_width integer,
    is_interactive boolean DEFAULT false
);


ALTER TABLE public.theme_map_layers OWNER TO paul;

--
-- Name: theme_map_layers_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE theme_map_layers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.theme_map_layers_id_seq OWNER TO paul;

--
-- Name: theme_map_layers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE theme_map_layers_id_seq OWNED BY theme_map_layers.id;


--
-- Name: theme_maps; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE theme_maps (
    id integer NOT NULL,
    name character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    slug character varying(255),
    is_interactive boolean DEFAULT false
);


ALTER TABLE public.theme_maps OWNER TO paul;

--
-- Name: theme_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE theme_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.theme_maps_id_seq OWNER TO paul;

--
-- Name: theme_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE theme_maps_id_seq OWNED BY theme_maps.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(40),
    name character varying(100) DEFAULT ''::character varying,
    email character varying(100),
    crypted_password character varying(40),
    salt character varying(40),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_token character varying(40),
    remember_token_expires_at timestamp without time zone,
    activation_code character varying(40),
    activated_at timestamp without time zone,
    neighbor_id integer
);


ALTER TABLE public.users OWNER TO paul;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO paul;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: walk_surveys; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE walk_surveys (
    id integer NOT NULL,
    neighbor_id character varying(255),
    frequency text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    route geometry,
    CONSTRAINT enforce_dims_route CHECK ((st_ndims(route) = 2)),
    CONSTRAINT enforce_geotype_route CHECK (((geometrytype(route) = 'LINESTRING'::text) OR (route IS NULL))),
    CONSTRAINT enforce_srid_route CHECK ((st_srid(route) = 4326))
);


ALTER TABLE public.walk_surveys OWNER TO paul;

--
-- Name: walk_surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: paul
--

CREATE SEQUENCE walk_surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.walk_surveys_id_seq OWNER TO paul;

--
-- Name: walk_surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: paul
--

ALTER SEQUENCE walk_surveys_id_seq OWNED BY walk_surveys.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY administrators ALTER COLUMN id SET DEFAULT nextval('administrators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY forums ALTER COLUMN id SET DEFAULT nextval('forums_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY half_blocks ALTER COLUMN id SET DEFAULT nextval('half_blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY map_layers ALTER COLUMN id SET DEFAULT nextval('map_layers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY mapped_lines ALTER COLUMN id SET DEFAULT nextval('mapped_lines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY neighbors ALTER COLUMN id SET DEFAULT nextval('neighbors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY theme_map_layers ALTER COLUMN id SET DEFAULT nextval('theme_map_layers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY theme_maps ALTER COLUMN id SET DEFAULT nextval('theme_maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: paul
--

ALTER TABLE ONLY walk_surveys ALTER COLUMN id SET DEFAULT nextval('walk_surveys_id_seq'::regclass);


--
-- Data for Name: administrators; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY administrators (id, admin_key, created_at, updated_at) FROM stdin;
\.


--
-- Name: administrators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('administrators_id_seq', 1, false);


--
-- Data for Name: forums; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY forums (id, forum_name, forum_url, forum_permissions, created_at, updated_at) FROM stdin;
\.


--
-- Name: forums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('forums_id_seq', 1, false);


--
-- Data for Name: half_blocks; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY half_blocks (id, half_block_id, boundary_t, created_at, updated_at, fill_color, the_geom) FROM stdin;
339	431	\N	\N	\N	194 167 132	0106000020E6100000010000000103000000010000000600000041F1621F5F4F33413F316D0277D90F41564395F6674F3341A1A94DC1F2ED0F419B3B1F57225033415E76860ECBED0F414DB5688BFC4F3341ED1AE8BA42D90F4141F1621F5F4F33413F316D0277D90F4141F1621F5F4F33413F316D0277D90F41
149	251	\N	\N	\N	207 242 39	0106000020E61000000100000001030000000100000005000000784592B284473341BBE8730873730F416D8B4D439347334146F0C28411880F41EC775E352F483341B67985A3F1870F416C5146E52448334101020DC054730F41784592B284473341BBE8730873730F41
63	165	\N	\N	\N	157 55 194	0106000020E6100000010000000103000000010000000500000027048B8EEA4D3341D4C22B6C3D720F41C7FC7F6EE14D3341DD0FC0F1A35D0F41CFFCCBBF3D4D33413728ED5CC45D0F417B68B516474D3341A59ED1525C720F4127048B8EEA4D3341D4C22B6C3D720F41
386	489	\N	\N	\N	228 221 200	0106000020E610000001000000010300000001000000050000003FA1D241AB4C33419EF3F99ED39B0F4140929BE6A24C33416DA3F9A608870F4147AE4AF2034C33413848AD2529870F4128F8A0E30E4C33418A7D02BEF19B0F413FA1D241AB4C33419EF3F99ED39B0F41
196	298	\N	\N	\N	235 171 94	0106000020E61000000100000001030000000100000005000000F7A15023EE54334180E8BD1CD92E0F41422EDAEB8557334152064544632E0F411619D5FE825733411C1F6A8F0A2A0F4129EAE418EB543341FC6471C56E2A0F41F7A15023EE54334180E8BD1CD92E0F41
15	116	\N	\N	\N	128 80 136	0106000020E61000000100000001030000000100000005000000357DF5CE905733416D3355F627470F410D5E397E1F5A33416D4239ACAC460F410476A6B71D5A3341B92C5026A0420F411D3704218F57334100394AA1E8420F41357DF5CE905733416D3355F627470F41
340	432	\N	\N	\N	195 62 133	0106000020E6100000010000000103000000010000000500000048E287F9674F33416BA4BB95F9ED0F410BC2B2D9704F33416230D20E45011041E25F21F3195033410196BD0231011041DE8FA0012250334119906612D3ED0F4148E287F9674F33416BA4BB95F9ED0F41
150	252	\N	\N	\N	208 137 40	0106000020E610000001000000010300000001000000050000005DA442791F4A3341570507308C870F41BEA293C3144A3341C9E8AF03F7720F41D28058286C4933414B3DFDE216730F416E9BF4687549334120B21FF4AE870F415DA442791F4A3341570507308C870F41
64	166	\N	\N	\N	157 206 195	0106000020E6100000010000000103000000010000000500000003D91B63D84D334128C02A1639490F41579EB2F3D34D33417BB0B6F6353F0F41A7A5ADF32F4D3341786CAA0A583F0F41B9D40882344D33419BF867DB63490F4103D91B63D84D334128C02A1639490F41
387	490	\N	\N	\N	229 116 202	0106000020E61000000100000001030000000100000005000000FBC1A15E924C334110685E4EE65D0F41BEB56C328A4C334183F45E4E90490F414818C75DF44B33419D8CFC68B7490F41014366D6EF4B334180FA387F065E0F41FBC1A15E924C334110685E4EE65D0F41
197	299	\N	\N	\N	236 66 96	0106000020E61000000100000001030000000100000005000000DE578E9C56523341953689E94E2F0F41F7A15023EE54334180E8BD1CD92E0F4129EAE418EB543341FC6471C56E2A0F41C8E2B62E55523341A51DD4AED22A0F41DE578E9C56523341953689E94E2F0F41
16	117	\N	\N	\N	128 231 137	0106000020E610000001000000010300000001000000040000004983C907D04A33416751F5583AB10F410295B2352E493341F75095E593B10F419380CE41D44A3341E53C931320BB0F414983C907D04A33416751F5583AB10F41
65	167	\N	\N	\N	158 101 196	0106000020E610000001000000010300000001000000050000000462C8DDFC4D33413D515296929B0F41BC3821A6F34D33413DB2A1CFC3860F4114ADC566504D3341BF79022FE5860F4183BAA6D5594D3341386AF8FDB19B0F410462C8DDFC4D33413D515296929B0F41
388	491	\N	\N	\N	230 11 203	0106000020E6100000010000000103000000010000000500000040929BE6A24C33416DA3F9A608870F416092CEA49A4C3341EFF2E0EB7C720F41A888F71FF94B3341982A33749B720F4147AE4AF2034C33413848AD2529870F4140929BE6A24C33416DA3F9A608870F41
198	300	\N	\N	\N	236 217 97	0106000020E6100000010000000103000000010000000500000050FAC99CB84F3341085682DCC52F0F41DE578E9C56523341953689E94E2F0F41C8E2B62E55523341A51DD4AED22A0F41681A80D5B54F33415D67BF04382B0F4150FAC99CB84F3341085682DCC52F0F41
17	118	\N	\N	\N	129 126 139	0106000020E61000000100000001030000000100000005000000EEC70A11C557334176E99B5F51CB0F41FC5D0DE529553341F6248D54D4CB0F41EBD23D4C2B55334122981A79A3CF0F41DA9FC099C6573341158D7E8B32CF0F41EEC70A11C557334176E99B5F51CB0F41
66	168	\N	\N	\N	158 252 197	0106000020E610000001000000010300000001000000050000004A114F18654D3341938F844086B40F41ABD289B0D14A334184AC26F91CB50F419BCD4F63D34A334136C1491117B90F41E09A4DF0664D33413F56DAFF96B80F414A114F18654D3341938F844086B40F41
201	303	\N	\N	\N	238 158 100	0106000020E610000001000000010300000001000000050000001D327E95034833417C87392524310F417B8F7972984A3341427F78D1AE300F41780D5BB3954A33413DDD8F13FE2B0F41BEAEF8FD004833417B4256CE612C0F411D327E95034833417C87392524310F41
389	492	\N	\N	\N	230 162 204	0106000020E6100000010000000103000000010000000500000082C9F6320A553341960A40D9C7750F41EB9D18BDA2573341FC82508080740F41625FA51DA1573341ABA500D265700F414F603B6608553341F7717508E5700F4182C9F6320A553341960A40D9C7750F41
199	301	\N	\N	\N	237 112 98	0106000020E61000000100000001030000000100000005000000111C9C41284D3341E1DE6B633A300F4150FAC99CB84F3341085682DCC52F0F41681A80D5B54F33415D67BF04382B0F41493BBB3F254D3341C23B2F209B2B0F41111C9C41284D3341E1DE6B633A300F41
18	119	\N	\N	\N	130 21 140	0106000020E61000000100000001030000000100000005000000A43F296F5B523341DBF375F8223C0F41EEA14664A75333410A49C08EC33B0F41D190F300A2533341C7A48BD423330F415C9111EB575233419AA5F7CF68330F41A43F296F5B523341DBF375F8223C0F41
67	169	\N	\N	\N	159 147 199	0106000020E61000000100000001030000000100000005000000F35A572C7D453341D29B7D3EF54E0F410842ED67124833413A139AF85F4E0F4100A95B54104833416720827F394A0F41EBCAED3E7B4533410F2AB22DD14A0F41F35A572C7D453341D29B7D3EF54E0F41
202	304	\N	\N	\N	119 189 239	0106000020E61000000100000001030000000100000005000000EC5E861E6E453341111F519499310F411D327E95034833417C87392524310F41BEAEF8FD004833417B4256CE612C0F415F7150626A453341A1F982D2C52C0F41EC5E861E6E453341111F519499310F41
390	493	\N	\N	\N	231 57 205	0106000020E61000000100000001030000000100000006000000EB9D18BDA2573341FC82508080740F4182C9F6320A553341960A40D9C7750F41F64BAD1E0C5533418534BCC5FE7A0F410C2C1D1AA557334154D01E9A7A7A0F41F88BA39FA457334130F83DDC44790F41EB9D18BDA2573341FC82508080740F41
200	302	\N	\N	\N	238 7 99	0106000020E610000001000000010300000001000000050000007B8F7972984A3341427F78D1AE300F41111C9C41284D3341E1DE6B633A300F41493BBB3F254D3341C23B2F209B2B0F41780D5BB3954A33413DDD8F13FE2B0F417B8F7972984A3341427F78D1AE300F41
19	120	\N	\N	\N	130 172 141	0106000020E61000000100000001030000000100000005000000FC5D0DE529553341F6248D54D4CB0F41622F62879552334117E47FF355CC0F41E8AB0A099752334151F9B43513D00F41EBD23D4C2B55334122981A79A3CF0F41FC5D0DE529553341F6248D54D4CB0F41
68	170	\N	\N	\N	160 42 200	0106000020E610000001000000010300000001000000050000000842ED67124833413A139AF85F4E0F416C343F91A54A33412B956B2ACB4D0F4113F573CAA34A334118A69D30A2490F4100A95B54104833416720827F394A0F410842ED67124833413A139AF85F4E0F41
203	305	\N	\N	\N	120 84 240	0106000020E610000001000000010300000001000000050000005447379175453341D07293F79D3E0F41B81589350A48334162ADBDCFFD3D0F41B126C02A08483341B1282AE5E8390F41FB442EAA73453341F867389A873A0F415447379175453341D07293F79D3E0F41
20	121	\N	\N	\N	131 67 142	0106000020E61000000100000001030000000100000005000000779B38EDF34F33416033902BDACC0F41885A482EF54D3341AD27346C3ECD0F410D3F41F4934E334100F604EBD5D00F41057A514CF54F3341E8EA23E58BD00F41779B38EDF34F33416033902BDACC0F41
251	343	\N	\N	\N	142 191 28	0106000020E61000000100000001030000000100000005000000E7369F6FC9513341108B9DE2DD5C0F41049B089CD05133410135CCC180710F41C2E1FBE2705233414680917562710F419C1E24926852334145F7035EBE5C0F41E7369F6FC9513341108B9DE2DD5C0F41
204	306	\N	\N	\N	120 235 241	0106000020E61000000100000001030000000100000005000000B81589350A48334162ADBDCFFD3D0F413DA1548D9E4A3341700F75BA5D3D0F41AF0CADCF9C4A3341C7985F274A390F41B126C02A08483341B1282AE5E8390F41B81589350A48334162ADBDCFFD3D0F41
252	344	\N	\N	\N	143 86 30	0106000020E6100000010000000103000000010000000500000021FF074AC2513341EA6BB6A24E480F41E7369F6FC9513341108B9DE2DD5C0F419C1E24926852334145F7035EBE5C0F41398A434960523341F45B010C2E480F4121FF074AC2513341EA6BB6A24E480F41
69	171	\N	\N	\N	160 193 201	0106000020E61000000100000001030000000100000005000000807096DE2B4F3341A8D4967F625D0F4152C4EE97234F3341263D52A5E2480F412AF1AA21794E334168E15F220F490F41E3AB2287824E33417CB9B309845D0F41807096DE2B4F3341A8D4967F625D0F41
205	306	\N	\N	\N	120 235 241	0106000020E61000000100000001030000000100000005000000D3AB3E370E483341ACC6AFF2FF450F41B36CAD407945334188BE67EF88460F41EBCAED3E7B4533410F2AB22DD14A0F4100A95B54104833416720827F394A0F41D3AB3E370E483341ACC6AFF2FF450F41
253	345	\N	\N	\N	143 237 31	0106000020E61000000100000001030000000100000005000000454EDF9D95503341FB3145083A860F416A1564119250334196F1DAF8BC710F417E034A27D24F3341B5B71840E1710F419CDE49C3D94F33417F0D656F60860F41454EDF9D95503341FB3145083A860F41
70	172	\N	\N	\N	161 88 202	0106000020E61000000100000001030000000100000005000000BEB56C328A4C334183F45E4E90490F41FBC1A15E924C334110685E4EE65D0F41CFFCCBBF3D4D33413728ED5CC45D0F41B9D40882344D33419BF867DB63490F41BEB56C328A4C334183F45E4E90490F41
206	308	\N	\N	\N	122 25 243	0106000020E61000000100000001030000000100000005000000F2D5CC02A24A3341F27CF03377450F41D3AB3E370E483341ACC6AFF2FF450F4100A95B54104833416720827F394A0F4113F573CAA34A334118A69D30A2490F41F2D5CC02A24A3341F27CF03377450F41
254	346	\N	\N	\N	144 132 32	0106000020E61000000100000001030000000100000006000000C1186CEF8A503341243D1EDB8E480F414F047D56875033417D2FCEE6C9330F410B26092ABB4F33411E720092F4330F410628C5DFC24F33414F965313B9480F416A807651D44F33418ED8D585B4480F41C1186CEF8A503341243D1EDB8E480F41
207	309	\N	\N	\N	122 176 244	0106000020E61000000100000001030000000100000005000000B36CAD407945334188BE67EF88460F41D3AB3E370E483341ACC6AFF2FF450F417D341E2E0C4833411BD08358EE410F41F0DD015E774533413907D3F27B420F41B36CAD407945334188BE67EF88460F41
255	347	\N	\N	\N	145 27 33	0106000020E610000001000000010300000001000000050000006A1564119250334196F1DAF8BC710F41D21ABC7E8E503341BF260A431C5D0F41625BC97FCA4F3341DC2A9A14435D0F417E034A27D24F3341B5B71840E1710F416A1564119250334196F1DAF8BC710F41
208	310	\N	\N	\N	123 71 246	0106000020E61000000100000001030000000100000005000000D3AB3E370E483341ACC6AFF2FF450F41F2D5CC02A24A3341F27CF03377450F417DDCFA43A04A33411BAC1DE660410F417D341E2E0C4833411BD08358EE410F41D3AB3E370E483341ACC6AFF2FF450F41
256	348	\N	\N	\N	145 178 34	0106000020E61000000100000001030000000100000007000000741EDD9D9A5033411522A5FB17A30F41BD63123A99503341172833D7119B0F41C54A127FE14F33419D70923B359B0F4139BA1AB9E24F3341E0BFD71E839E0F41AA6684240E5033416386543585A00F410CD12AF55150334137C128FA7CA20F41741EDD9D9A5033411522A5FB17A30F41
209	311	\N	\N	\N	123 222 247	0106000020E61000000100000001030000000100000006000000E76F0290184833415D1F9D2AAE5A0F417182D4D882453341817360D3255B0F41187C26BD844533418ED07E5B365F0F4104356EDFD9463341514AA05C085F0F416F3EAC9D1A4833411BD903D6C85E0F41E76F0290184833415D1F9D2AAE5A0F41
257	349	\N	\N	\N	146 73 36	0106000020E61000000100000001030000000100000005000000BD63123A99503341172833D7119B0F41454EDF9D95503341FB3145083A860F419CDE49C3D94F33417F0D656F60860F41C54A127FE14F33419D70923B359B0F41BD63123A99503341172833D7119B0F41
210	312	\N	\N	\N	124 117 248	0106000020E610000001000000010300000001000000060000000C603CDFAA4A33417D12871F375A0F41E76F0290184833415D1F9D2AAE5A0F416F3EAC9D1A4833411BD903D6C85E0F4134F46C100A4A3341F97558B5665E0F4107C21A9BAC4A3341E5D70184465E0F410C603CDFAA4A33417D12871F375A0F41
258	350	\N	\N	\N	146 224 37	0106000020E61000000100000001030000000100000006000000D21ABC7E8E503341BF260A431C5D0F41C1186CEF8A503341243D1EDB8E480F416A807651D44F33418ED8D585B4480F410628C5DFC24F33414F965313B9480F41625BC97FCA4F3341DC2A9A14435D0F41D21ABC7E8E503341BF260A431C5D0F41
259	351	\N	\N	\N	147 119 38	0106000020E610000001000000010300000001000000050000005DA442791F4A3341570507308C870F41EC60BD462A4A33419667E9174F9C0F41761CF30BC74A334168CD08E5309C0F414DC4472DBE4A33414E3C78BE6B870F415DA442791F4A3341570507308C870F41
260	352	\N	\N	\N	148 14 39	0106000020E61000000100000001030000000100000005000000BEA293C3144A3341C9E8AF03F7720F415DA442791F4A3341570507308C870F414DC4472DBE4A33414E3C78BE6B870F4109DEFC63B54A3341B4F68BA6D8720F41BEA293C3144A3341C9E8AF03F7720F41
311	403	\N	\N	\N	178 35 99	0106000020E610000001000000010300000001000000050000001019ED04DD553341A9DFE7595DE80F41091B8131E05533411F7F526C75F90F414D52D590815633419BB5D3876BF90F410636B08080563341E671BD3358E80F411019ED04DD553341A9DFE7595DE80F41
121	223	\N	\N	\N	191 110 6	0106000020E61000000100000001030000000100000005000000D2490443A44F33410768D9BE6A0E0F411D489CFF4B523341C2241684FF0D0F417B3F05994A52334113BAF10B9A090F411DACD198A14F3341F58092950C0A0F41D2490443A44F33410768D9BE6A0E0F41
312	404	\N	\N	\N	178 186 100	0106000020E61000000100000001030000000100000005000000EF57B2F9D9553341F0C627E0F8D70F411019ED04DD553341A9DFE7595DE80F410636B08080563341E671BD3358E80F416BA8D5797F563341B1D73A1DDAD70F41EF57B2F9D9553341F0C627E0F8D70F41
122	224	\N	\N	\N	192 5 7	0106000020E610000001000000010300000001000000050000001D489CFF4B523341C2241684FF0D0F41CA60363DD7543341C2CA1EC8980D0F4191D1A731D454334142EE7DCA2C090F417B3F05994A52334113BAF10B9A090F411D489CFF4B523341C2241684FF0D0F41
313	405	\N	\N	\N	179 81 101	0106000020E610000001000000010300000001000000050000003E9EC6642F573341E55926756700104115FD50192D573341C0BEDF0361F90F414D52D590815633419BB5D3876BF90F41EB68BC0982563341B77DD7C3800010413E9EC6642F573341E559267567001041
123	225	\N	\N	\N	192 156 9	0106000020E61000000100000001030000000100000005000000CA60363DD7543341C2CA1EC8980D0F41C4228C926F57334108B169FB2F0D0F41AA5EDF936C5733413392570CBD080F4191D1A731D454334142EE7DCA2C090F41CA60363DD7543341C2CA1EC8980D0F41
361	453	\N	\N	\N	207 161 158	0106000020E61000000100000001030000000100000008000000F81429CC98523341CCC079F372D40F41A66E94F1F84F33411C63C22FEED40F414DB5688BFC4F3341ED1AE8BA42D90F4157BE077CAB503341087F7B0602D90F412F65FB0C55513341647B6F88DFD80F414EEE2381F5513341F4BCF5DCBED80F41D33D7BCB9A523341396E90129DD80F41F81429CC98523341CCC079F372D40F41
171	273	\N	\N	\N	220 236 65	0106000020E61000000100000001030000000100000005000000D146162A75573341DC35159B7E150F41340C22A2065A33410A55618E1A150F41D1E6C739045A33416612F16DB4100F41BD5BC73972573341D48EA30321110F41D146162A75573341DC35159B7E150F41
314	406	\N	\N	\N	179 232 103	0106000020E610000001000000010300000001000000050000004E768BFDBE593341282643AF38F90F41828E79C4C05933413AB107DF24001041C408808D705A3341F53406A415001041B6748C896D5A3341555503FC2DF90F414E768BFDBE593341282643AF38F90F41
124	226	\N	\N	\N	193 51 10	0106000020E61000000100000001030000000100000005000000340C22A2065A33410A55618E1A150F41D146162A75573341DC35159B7E150F418B718DCD7757334149F1270B6A190F41F1E121C5085A33417D7236F801190F41340C22A2065A33410A55618E1A150F41
362	454	\N	\N	\N	208 56 159	0106000020E61000000100000001030000000100000007000000C547854BEF4F33413525B35560C00F413C04859FF04F3341BFA70D7E93BC0F417F5ED13C464B33415EA4662AB4BD0F416F8718512D4C334188E93B6AD2C20F41E4FC0E91674C33413E8C554D1FC10F410ED02406994D3341516D77C1DEC00F41C547854BEF4F33413525B35560C00F41
172	274	\N	\N	\N	221 131 66	0106000020E61000000100000001030000000100000005000000401CE4805A453341CF0F5AE13F180F415EF5C7CFF5473341D0C75855DA170F418642D48AF34733416D2E1D9BAF130F4199D7394E5745334112E644E11D140F41401CE4805A453341CF0F5AE13F180F41
315	407	\N	\N	\N	180 127 104	0106000020E610000001000000010300000001000000050000006617B7AA7A58334157501B2041001041912D1B6B78583341F4E550B44CF90F413DEC2954D0573341736A3A0257F90F41C8B511ABD157334142D994C44F0010416617B7AA7A58334157501B2041001041
125	227	\N	\N	\N	193 202 11	0106000020E610000001000000010300000001000000050000005EF5C7CFF5473341D0C75855DA170F41401CE4805A453341CF0F5AE13F180F41C295A99F5D453341C9B3C52B481C0F416456CAFFF7473341B5D9469BDE1B0F415EF5C7CFF5473341D0C75855DA170F41
363	455	\N	\N	\N	208 207 160	0106000020E610000001000000010300000001000000060000003C04859FF04F3341BFA70D7E93BC0F41C547854BEF4F33413525B35560C00F4162BF9D7C905233417A760E15D2BF0F4180DEE0678D523341FE680D72B5BB0F413C04859FF04F3341CF1C61E0FDBB0F413C04859FF04F3341BFA70D7E93BC0F41
173	275	\N	\N	\N	222 26 67	0106000020E610000001000000010300000001000000050000005EF5C7CFF5473341D0C75855DA170F41C11081AD894A3341632D42EB75170F41A9E0E937874A33418CCB9BBE42130F418642D48AF34733416D2E1D9BAF130F415EF5C7CFF5473341D0C75855DA170F41
316	408	\N	\N	\N	181 22 105	0106000020E61000000100000001030000000100000005000000091B8131E05533411F7F526C75F90F4143A6F7A0E155334153D0B22E98001041EB68BC0982563341B77DD7C3800010414D52D590815633419BB5D3876BF90F41091B8131E05533411F7F526C75F90F41
126	228	\N	\N	\N	194 97 12	0106000020E61000000100000001030000000100000005000000C11081AD894A3341632D42EB75170F415EF5C7CFF5473341D0C75855DA170F416456CAFFF7473341B5D9469BDE1B0F41925934058C4A3341F47D7A0C761B0F41C11081AD894A3341632D42EB75170F41
41	143	\N	\N	\N	144 61 168	0106000020E61000000100000001030000000100000005000000B4551DDDDF4A33414D2CA4E34DD60F41D2228514364F3341436464EC42D50F410D3F41F4934E334100F604EBD5D00F4117AA42DCDD4A33412DA6A7F49CD10F41B4551DDDDF4A33414D2CA4E34DD60F41
364	456	\N	\N	\N	209 102 161	0106000020E610000001000000010300000001000000050000000E541A35EE4F334180B8F05019B80F413C04859FF04F3341CF1C61E0FDBB0F4180DEE0678D523341FE680D72B5BB0F41388FBB2B8D5233418258320897B70F410E541A35EE4F334180B8F05019B80F41
174	276	\N	\N	\N	222 177 69	0106000020E61000000100000001030000000100000005000000C11081AD894A3341632D42EB75170F417C8678E3174D334109217B5D12170F41A5447B22154D33412F736ED5D6120F41A9E0E937874A33418CCB9BBE42130F41C11081AD894A3341632D42EB75170F41
317	409	\N	\N	\N	181 173 106	0106000020E61000000100000001030000000100000005000000869683B8BA5933418242F32D3EE80F410332FD82B6593341AF94875581D70F4113BE93B718593341AF2E12178AD70F4113BE93B71859334133392F4843E80F41869683B8BA5933418242F32D3EE80F41
127	229	\N	\N	\N	194 248 13	0106000020E610000001000000010300000001000000050000007C8678E3174D334109217B5D12170F41C11081AD894A3341632D42EB75170F41925934058C4A3341F47D7A0C761B0F41E5D7207B1A4D334106022F5F0E1B0F417C8678E3174D334109217B5D12170F41
365	457	\N	\N	\N	209 253 163	0106000020E61000000100000001030000000100000008000000A71CFA43E94F33411792709A22B00F413C5287A9EB4F33416E8AD352FFB30F41E3D5B7808B523341300AF41E73B30F413339C9F089523341D11DAF6E92AF0F41A607BD3BE6513341BEB8D484B5AF0F414A0AEBD74551334166A6F7E4D7AF0F41D9ABD8FCA3503341DA8D8795FAAF0F41A71CFA43E94F33411792709A22B00F41
175	277	\N	\N	\N	223 72 70	0106000020E610000001000000010300000001000000050000007C8678E3174D334109217B5D12170F4147CCBE4DA94F33415FBDDF52AE160F4157BB81B3A64F334196430C526A120F41A5447B22154D33412F736ED5D6120F417C8678E3174D334109217B5D12170F41
318	410	\N	\N	\N	182 68 107	0106000020E610000001000000010300000001000000050000004E768BFDBE593341282643AF38F90F41869683B8BA5933418242F32D3EE80F4113BE93B71859334133392F4843E80F4113BE93B7185933417597ABE042F90F414E768BFDBE593341282643AF38F90F41
128	230	\N	\N	\N	195 143 14	0106000020E6100000010000000103000000010000000500000047CCBE4DA94F33415FBDDF52AE160F417C8678E3174D334109217B5D12170F41E5D7207B1A4D334106022F5F0E1B0F411B3A92B9AB4F334119B30341A61A0F4147CCBE4DA94F33415FBDDF52AE160F41
42	144	\N	\N	\N	144 212 169	0106000020E61000000100000001030000000100000005000000A9DB77E32C553341C354A807F5D30F41B8623649C8573341F55E07B775D30F41DA9FC099C6573341158D7E8B32CF0F41EBD23D4C2B55334122981A79A3CF0F41A9DB77E32C553341C354A807F5D30F41
366	458	\N	\N	\N	210 148 164	0106000020E610000001000000010300000001000000050000003C5287A9EB4F33416E8AD352FFB30F410E541A35EE4F334180B8F05019B80F41388FBB2B8D5233418258320897B70F41E3D5B7808B523341300AF41E73B30F413C5287A9EB4F33416E8AD352FFB30F41
176	278	\N	\N	\N	223 223 71	0106000020E6100000010000000103000000010000000500000047CCBE4DA94F33415FBDDF52AE160F4185BDFCA24E5233415150564047160F4122F238444D523341EC0E8E57FA110F4157BB81B3A64F334196430C526A120F4147CCBE4DA94F33415FBDDF52AE160F41
319	411	\N	\N	\N	182 219 109	0106000020E61000000100000001030000000100000005000000828E79C4C05933413AB107DF240010414E768BFDBE593341282643AF38F90F4113BE93B7185933417597ABE042F90F4113BE93B7185933416BF2786E33001041828E79C4C05933413AB107DF24001041
129	231	\N	\N	\N	196 38 16	0106000020E6100000010000000103000000010000000500000085BDFCA24E5233415150564047160F4147CCBE4DA94F33415FBDDF52AE160F411B3A92B9AB4F334119B30341A61A0F417F5F63E54F52334167E242233B1A0F4185BDFCA24E5233415150564047160F41
43	145	\N	\N	\N	145 107 170	0106000020E61000000100000001030000000100000005000000F81429CC98523341CCC079F372D40F41A9DB77E32C553341C354A807F5D30F41EBD23D4C2B55334122981A79A3CF0F41E8AB0A099752334151F9B43513D00F41F81429CC98523341CCC079F372D40F41
367	459	\N	\N	\N	211 43 165	0106000020E61000000100000001030000000100000005000000FF91A3CBF04F33419D7EA4016BC40F4168A34122925233417F0449A7E8C30F4162BF9D7C905233417A760E15D2BF0F41C547854BEF4F33413525B35560C00F41FF91A3CBF04F33419D7EA4016BC40F41
177	279	\N	\N	\N	224 118 72	0106000020E6100000010000000103000000010000000500000085BDFCA24E5233415150564047160F41EE4A2BF3DC543341250392AEE3150F41461C69F7D9543341C52EC3A18E110F4122F238444D523341EC0E8E57FA110F4185BDFCA24E5233415150564047160F41
320	412	\N	\N	\N	183 114 110	0106000020E6100000010000000103000000010000000500000003FE711C735833416ED6767F48E80F41912D1B6B78583341F4E550B44CF90F4113BE93B7185933417597ABE042F90F4113BE93B71859334133392F4843E80F4103FE711C735833416ED6767F48E80F41
130	232	\N	\N	\N	196 189 17	0106000020E61000000100000001030000000100000005000000EE4A2BF3DC543341250392AEE3150F4185BDFCA24E5233415150564047160F417F5F63E54F52334167E242233B1A0F41F5440BA9DF5433413A141941D3190F41EE4A2BF3DC543341250392AEE3150F41
91	193	\N	\N	\N	173 187 227	0106000020E61000000100000001030000000100000009000000D76113AB49463341BCF9F7BB290210416E248F1FA2463341869C7FAA9700104116C0905D2247334100341B5C51EF0F4118D9FF138C4733418E2BC66CA7DB0F41E85464644C4633418AB6A923DDDB0F41A376EDF31B46334168476EEBC4DB0F410225CA5FC645334179640977E5DB0F41FEB79022E34533418F9E308730021041D76113AB49463341BCF9F7BB29021041
44	146	\N	\N	\N	146 2 171	0106000020E61000000100000001030000000100000005000000E70B45814A5A33419C7C9626C0A80F4187726491B757334182EB3BF92DA90F410C42F2A7B9573341C598BBDE75AE0F41C32B5DC44C5A33415754329BE8AD0F41E70B45814A5A33419C7C9626C0A80F41
368	460	\N	\N	\N	211 194 166	0106000020E610000001000000010300000001000000050000005FC652009A4D334177C99FEDDEC40F41FF91A3CBF04F33419D7EA4016BC40F41C547854BEF4F33413525B35560C00F410ED02406994D3341516D77C1DEC00F415FC652009A4D334177C99FEDDEC40F41
178	280	\N	\N	\N	225 13 73	0106000020E61000000100000001030000000100000005000000EE4A2BF3DC543341250392AEE3150F41D146162A75573341DC35159B7E150F41BD5BC73972573341D48EA30321110F41461C69F7D9543341C52EC3A18E110F41EE4A2BF3DC543341250392AEE3150F41
92	194	\N	\N	\N	174 82 228	0106000020E610000001000000010300000001000000050000001D327E95034833417C87392524310F41EC5E861E6E453341111F519499310F411220FA9A71453341601B31F01A360F4180696BFE054833412F69B6ED90350F411D327E95034833417C87392524310F41
45	147	\N	\N	\N	146 153 173	0106000020E6100000010000000103000000010000000500000087726491B757334182EB3BF92DA90F414CE2994A1D553341E15808059DA90F41E00F45481F5533419915C1B004AF0F410C42F2A7B9573341C598BBDE75AE0F4187726491B757334182EB3BF92DA90F41
369	461	\N	\N	\N	212 89 167	0106000020E61000000100000001030000000100000005000000CD195C67F24F33417FA46707C0C80F41BE7DC0E09352334179884BEB3CC80F4168A34122925233417F0449A7E8C30F41FF91A3CBF04F33419D7EA4016BC40F41CD195C67F24F33417FA46707C0C80F41
179	281	\N	\N	\N	225 164 74	0106000020E610000001000000010300000001000000050000002BA67AB97A57334114583D20C11D0F41D2FF22260B5A3341BF96DAAB5A1D0F41F1E121C5085A33417D7236F801190F418B718DCD7757334149F1270B6A190F412BA67AB97A57334114583D20C11D0F41
93	195	\N	\N	\N	174 233 229	0106000020E610000001000000010300000001000000050000007B8F7972984A3341427F78D1AE300F411D327E95034833417C87392524310F4180696BFE054833412F69B6ED90350F4155279DFD9A4A3341F110AFCA06350F417B8F7972984A3341427F78D1AE300F41
46	148	\N	\N	\N	147 48 174	0106000020E61000000100000001030000000100000006000000454EDF9D95503341FB3145083A860F41BD63123A99503341172833D7119B0F4102D63C1337513341A43B2A6FF39A0F41D7705F0B385133414BB362E2CC980F414FDA42ED30513341744449481A860F41454EDF9D95503341FB3145083A860F41
180	282	\N	\N	\N	226 59 76	0106000020E610000001000000010300000001000000050000005FF2F9F26045334128EA6B5D94200F417F54E657FA473341528CA2822C200F416456CAFFF7473341B5D9469BDE1B0F41C295A99F5D453341C9B3C52B481C0F415FF2F9F26045334128EA6B5D94200F41
94	196	\N	\N	\N	175 128 230	0106000020E61000000100000001030000000100000005000000111C9C41284D3341E1DE6B633A300F417B8F7972984A3341427F78D1AE300F4155279DFD9A4A3341F110AFCA06350F41B6C2A7072B4D33417FD1E2B07D340F41111C9C41284D3341E1DE6B633A300F41
370	462	\N	\N	\N	212 240 169	0106000020E61000000100000001030000000100000005000000622F62879552334117E47FF355CC0F41779B38EDF34F33416033902BDACC0F41057A514CF54F3341E8EA23E58BD00F41E8AB0A099752334151F9B43513D00F41622F62879552334117E47FF355CC0F41
95	197	\N	\N	\N	176 23 232	0106000020E6100000010000000103000000010000000500000050FAC99CB84F3341085682DCC52F0F41111C9C41284D3341E1DE6B633A300F41B6C2A7072B4D33417FD1E2B07D340F410B26092ABB4F33411E720092F4330F4150FAC99CB84F3341085682DCC52F0F41
47	149	\N	\N	\N	147 199 175	0106000020E61000000100000001030000000100000005000000D94125B133533341749C8B75919A0F41897D26DF26533341196E8DABB3850F41F6CCBE207952334170E23D30D7850F418E8A5988815233413BE92FC7B39A0F41D94125B133533341749C8B75919A0F41
421	525	\N	\N	\N	250 25 243	0106000020E61000000100000001030000000100000005000000CE350556BE573341CC3BC350A1BA0F41323FB497BB593341DF0A47734FBA0F41AF356A79BA5933415BF843C22FB60F41194825DEBC57334190E70E3A95B60F41CE350556BE573341CC3BC350A1BA0F41
96	198	\N	\N	\N	176 174 233	0106000020E61000000100000001030000000100000005000000DE578E9C56523341953689E94E2F0F4150FAC99CB84F3341085682DCC52F0F410B26092ABB4F33411E720092F4330F415C9111EB575233419AA5F7CF68330F41DE578E9C56523341953689E94E2F0F41
231	323	\N	\N	\N	130 243 5	0106000020E61000000100000001030000000100000007000000D2A1D6E6A04A3341C78F5842DE420F41E0A556F77F4B3341E48929D7B9420F41D9C24A1F7B4B334192A5BBCFB23F0F41BA9B659FF64B33416A1B2726993F0F4187ED370BF94B33414F4A00A3BD340F4155279DFD9A4A3341F110AFCA06350F41D2A1D6E6A04A3341C78F5842DE420F41
48	150	\N	\N	\N	148 94 176	0106000020E6100000010000000103000000010000000500000040929BE6A24C33416DA3F9A608870F413FA1D241AB4C33419EF3F99ED39B0F4183BAA6D5594D3341386AF8FDB19B0F4114ADC566504D3341BF79022FE5860F4140929BE6A24C33416DA3F9A608870F41
422	526	\N	\N	\N	250 176 244	0106000020E61000000100000001030000000100000005000000DDA94E16C05733416E4BDB8BB9BE0F415D4DE7B2BC593341EF478BBF63BE0F41323FB497BB593341DF0A47734FBA0F41CE350556BE573341CC3BC350A1BA0F41DDA94E16C05733416E4BDB8BB9BE0F41
97	199	\N	\N	\N	177 69 234	0106000020E61000000100000001030000000100000005000000F7A15023EE54334180E8BD1CD92E0F41DE578E9C56523341953689E94E2F0F415C9111EB575233419AA5F7CF68330F41BA86C2E7F054334119AF76D7DD320F41F7A15023EE54334180E8BD1CD92E0F41
232	324	\N	\N	\N	131 138 6	0106000020E61000000100000001030000000100000005000000579EB2F3D34D33417BB0B6F6353F0F41061ED924CF4D33410D42DC645B340F41B6C2A7072B4D33417FD1E2B07D340F41A7A5ADF32F4D3341786CAA0A583F0F41579EB2F3D34D33417BB0B6F6353F0F41
49	151	\N	\N	\N	148 245 177	0106000020E610000001000000010300000001000000050000006D8B4D439347334146F0C28411880F4112A0CDE7A1473341209146FDCB9C0F412C71989539483341F5E779C5AE9C0F41EC775E352F483341B67985A3F1870F416D8B4D439347334146F0C28411880F41
423	527	\N	\N	\N	251 71 245	0106000020E610000001000000010300000001000000050000009FBD64FABE593341FB3B195ECBC60F41C5BEA59F575A334180449DF3A9C60F416B8B81F3535A3341AE72BC3B4ABE0F415D4DE7B2BC593341EF478BBF63BE0F419FBD64FABE593341FB3B195ECBC60F41
98	200	\N	\N	\N	177 220 235	0106000020E61000000100000001030000000100000005000000422EDAEB8557334152064544632E0F41F7A15023EE54334180E8BD1CD92E0F41BA86C2E7F054334119AF76D7DD320F4144E94E92885733419B35A02553320F41422EDAEB8557334152064544632E0F41
233	325	\N	\N	\N	132 33 7	0106000020E61000000100000001030000000100000005000000ECABC8A2444B334118A30A46E5490F41C4795A64414B3341E3BA810EC4420F41D2A1D6E6A04A3341C78F5842DE420F4167E001F9A34A334163F968340F4A0F41ECABC8A2444B334118A30A46E5490F41
50	152	\N	\N	\N	149 140 179	0106000020E61000000100000001030000000100000005000000A55AA068AF573341B11774728B940F4186C6FD65415A3341FED2AC59FC930F41AB168C1E3F5A3341316FE9F9C98E0F415573D554AD5733413A3EBC884A8F0F41A55AA068AF573341B11774728B940F41
424	528	\N	\N	\N	251 222 246	0106000020E610000001000000010300000001000000050000004350C5C2C157334146675A23F5C20F41163F97D2BD593341A6A2569888C20F415D4DE7B2BC593341EF478BBF63BE0F41DDA94E16C05733416E4BDB8BB9BE0F414350C5C2C157334146675A23F5C20F41
281	373	\N	\N	\N	160 113 64	0106000020E6100000010000000103000000010000000500000082457D4CAB5733412B35DF92268A0F416E8B06DC3C5A3341FE8A89D3A2890F410155E97F3A5A3341413DFE5141840F413E40D92CA9573341F8BF58B2C7840F4182457D4CAB5733412B35DF92268A0F41
99	201	\N	\N	\N	178 115 236	0106000020E610000001000000010300000001000000050000002F983339145A3341FB13B61AEF2D0F41422EDAEB8557334152064544632E0F4144E94E92885733419B35A02553320F415BA4A255165A3341ABE99A85CA310F412F983339145A3341FB13B61AEF2D0F41
234	325	\N	\N	\N	132 33 7	0106000020E6100000010000000103000000010000000500000040C6C4056A4B33413E802480119C0F41AC3DC591604B334105A5D58B4A870F414DC4472DBE4A33414E3C78BE6B870F41761CF30BC74A334168CD08E5309C0F4140C6C4056A4B33413E802480119C0F41
425	529	\N	\N	\N	252 117 247	0106000020E61000000100000001030000000100000005000000E6141673C3573341748FC2783AC70F419FBD64FABE593341FB3B195ECBC60F41163F97D2BD593341A6A2569888C20F414350C5C2C157334146675A23F5C20F41E6141673C3573341748FC2783AC70F41
282	374	\N	\N	\N	161 8 65	0106000020E61000000100000001030000000100000005000000791BE4E411553341C59289E4AB8A0F4182457D4CAB5733412B35DF92268A0F413E40D92CA9573341F8BF58B2C7840F413EBD72EB0F553341B6BFC2B14F850F41791BE4E411553341C59289E4AB8A0F41
100	202	\N	\N	\N	179 10 237	0106000020E610000001000000010300000001000000050000002BA67AB97A57334114583D20C11D0F41F97E20A5E2543341B0857EC6281E0F416DDCDA5EE554334118015AF11D220F415F13FA657D573341674B4AFBB9210F412BA67AB97A57334114583D20C11D0F41
235	327	\N	\N	\N	133 79 10	0106000020E61000000100000001030000000100000005000000AC3DC591604B334105A5D58B4A870F4156E68D36574B3341315B880FBA720F4109DEFC63B54A3341B4F68BA6D8720F414DC4472DBE4A33414E3C78BE6B870F41AC3DC591604B334105A5D58B4A870F41
426	530	\N	\N	\N	253 12 249	0106000020E61000000100000001030000000100000005000000841FE735C15933415D39E2CE06CF0F4131AE9D3F5B5A33415822C2E9EDCE0F41C5BEA59F575A334180449DF3A9C60F419FBD64FABE593341FB3B195ECBC60F41841FE735C15933415D39E2CE06CF0F41
283	375	\N	\N	\N	161 159 66	0106000020E610000001000000010300000001000000050000008DD015A061493341CD4FAF11885E0F41D28058286C4933414B3DFDE216730F41BEA293C3144A3341C9E8AF03F7720F4134F46C100A4A3341F97558B5665E0F418DD015A061493341CD4FAF11885E0F41
236	328	\N	\N	\N	133 230 11	0106000020E6100000010000000103000000010000000500000056E68D36574B3341315B880FBA720F419AA9F9D94D4B33413ADE6294265E0F4107C21A9BAC4A3341E5D70184465E0F4109DEFC63B54A3341B4F68BA6D8720F4156E68D36574B3341315B880FBA720F41
427	531	\N	\N	\N	253 163 250	0106000020E61000000100000001030000000100000005000000EEC70A11C557334176E99B5F51CB0F4109B19C09C05933416FD36A7CB3CA0F419FBD64FABE593341FB3B195ECBC60F41E6141673C3573341748FC2783AC70F41EEC70A11C557334176E99B5F51CB0F41
284	376	\N	\N	\N	162 54 67	0106000020E6100000010000000103000000010000000500000087726491B757334182EB3BF92DA90F41E70B45814A5A33419C7C9626C0A80F41C798E02F485A334179C6AC1777A30F41A4DEE57FB5573341410F67DFF2A30F4187726491B757334182EB3BF92DA90F41
237	329	\N	\N	\N	134 125 12	0106000020E610000001000000010300000001000000050000004B555B96734B33414BE40E4B17B10F4140C6C4056A4B33413E802480119C0F41761CF30BC74A334168CD08E5309C0F414983C907D04A33416851F5583AB10F414B555B96734B33414BE40E4B17B10F41
428	532	\N	\N	\N	254 58 251	0106000020E61000000100000001030000000100000006000000DA9FC099C6573341158D7E8B32CF0F41618D0C1275593341820F5AD023CF0F41841FE735C15933415D39E2CE06CF0F4109B19C09C05933416FD36A7CB3CA0F41EEC70A11C557334176E99B5F51CB0F41DA9FC099C6573341158D7E8B32CF0F41
285	377	\N	\N	\N	162 205 68	0106000020E610000001000000010300000001000000050000004CE2994A1D553341E15808059DA90F4187726491B757334182EB3BF92DA90F41A4DEE57FB5573341410F67DFF2A30F4154E08D621B55334131016F0C70A40F414CE2994A1D553341E15808059DA90F41
238	330	\N	\N	\N	135 20 13	0106000020E610000001000000010300000001000000050000009AA9F9D94D4B33413ADE6294265E0F41ECABC8A2444B334118A30A46E5490F4167E001F9A34A334163F968340F4A0F4107C21A9BAC4A3341E5D70184465E0F419AA9F9D94D4B33413ADE6294265E0F41
286	378	\N	\N	\N	163 100 70	0106000020E6100000010000000103000000010000000500000034AD0C88B35733415ABF8BA1F89E0F4135C1CAFE455A3341746E78B3779E0F4171B044B0435A334166451B2F35990F41467FC772B1573341D14C29FBB3990F4134AD0C88B35733415ABF8BA1F89E0F41
239	331	\N	\N	\N	135 171 14	0106000020E610000001000000010300000001000000060000006DE13BF9DE513341BA518617D39A0F4151DD57B9D75133411C64232FF8850F414FDA42ED30513341744449481A860F41D7705F0B385133414BB362E2CC980F4102D63C1337513341A43B2A6FF39A0F416DE13BF9DE513341BA518617D39A0F41
287	379	\N	\N	\N	163 251 71	0106000020E61000000100000001030000000100000005000000131B1E8F19553341157DFE077B9F0F4134AD0C88B35733415ABF8BA1F89E0F41467FC772B1573341D14C29FBB3990F41C26C8F9D17553341443EA33D349A0F41131B1E8F19553341157DFE077B9F0F41
240	332	\N	\N	\N	136 66 15	0106000020E6100000010000000103000000010000000500000051DD57B9D75133411C64232FF8850F41049B089CD05133410135CCC180710F414524D821295133417F0E766AA0710F414FDA42ED30513341744449481A860F4151DD57B9D75133411C64232FF8850F41
288	380	\N	\N	\N	164 146 72	0106000020E61000000100000001030000000100000005000000E3D5B7808B523341300AF41E73B30F418DB61D0914543341BE475B2A29B30F4176382470F45333414BD77BBD44AF0F413339C9F089523341D11DAF6E92AF0F41E3D5B7808B523341300AF41E73B30F41
101	203	\N	\N	\N	179 161 239	0106000020E61000000100000001030000000100000005000000F97E20A5E2543341B0857EC6281E0F415E147D46515233416EF7A5608F1E0F41D91035885252334113756D1F81220F416DDCDA5EE554334118015AF11D220F41F97E20A5E2543341B0857EC6281E0F41
289	381	\N	\N	\N	165 41 73	0106000020E610000001000000010300000001000000050000008DB61D0914543341BE475B2A29B30F4114533EBC205533410187768AF6B20F41E00F45481F5533419915C1B004AF0F4176382470F45333414BD77BBD44AF0F418DB61D0914543341BE475B2A29B30F41
102	204	\N	\N	\N	180 56 240	0106000020E610000001000000010300000001000000050000005E147D46515233416EF7A5608F1E0F41CDE0A15CAE4F3341A480CAB7F81E0F41A3404CC2B04F33411E600C8DE6220F41D91035885252334113756D1F81220F415E147D46515233416EF7A5608F1E0F41
290	382	\N	\N	\N	165 192 74	0106000020E6100000010000000103000000010000000500000014533EBC205533410187768AF6B20F419638123EBB5733412F6391F778B20F410C42F2A7B9573341C598BBDE75AE0F41E00F45481F5533419915C1B004AF0F4114533EBC205533410187768AF6B20F41
103	205	\N	\N	\N	180 207 241	0106000020E61000000100000001030000000100000005000000CDE0A15CAE4F3341A480CAB7F81E0F4145A7054A1D4D33417A2214465F1F0F4121D512D61F4D3341B5124C7149230F41A3404CC2B04F33411E600C8DE6220F41CDE0A15CAE4F3341A480CAB7F81E0F41
341	433	\N	\N	\N	195 213 134	0106000020E61000000100000001030000000100000005000000ECA44862804D33410A0225875EEE0F41C7975197854D3341CD7A4B4C7F01104191207BDF2A4E3341158712B46B011041206C2F40234E3341424C81CF3CEE0F41ECA44862804D33410A0225875EEE0F41
151	253	\N	\N	\N	209 32 41	0106000020E61000000100000001030000000100000005000000127C63FFCB4833411A7F8C2935730F41804B99ACD648334185C56267CF870F416E9BF4687549334120B21FF4AE870F41D28058286C4933414B3DFDE216730F41127C63FFCB4833411A7F8C2935730F41
104	206	\N	\N	\N	181 102 242	0106000020E6100000010000000103000000010000000500000045A7054A1D4D33417A2214465F1F0F419E58558B8E4A334185DC5A77C51F0F41D28312D4904A3341DABBBF0BAC230F4121D512D61F4D3341B5124C7149230F4145A7054A1D4D33417A2214465F1F0F41
342	434	\N	\N	\N	196 108 136	0106000020E61000000100000001030000000100000005000000A86B0B3C7B4D3341DA2CA410F9D90F4121734B61804D33414FC8419C5AEE0F417F4C603E234E334135CC9FEB37EE0F4158A310B11B4E3341EA8E4AF0CDD90F41A86B0B3C7B4D3341DA2CA410F9D90F41
152	254	\N	\N	\N	209 183 43	0106000020E610000001000000010300000001000000050000009D542A783C4F334115B32C9780860F417879DA30344F3341C218521CFF710F414C900AFE8B4E3341BA53E2E71E720F41701A5E6A954E3341ECBBC1BDA2860F419D542A783C4F334115B32C9780860F41
105	207	\N	\N	\N	181 253 243	0106000020E610000001000000010300000001000000050000009E58558B8E4A334185DC5A77C51F0F417F54E657FA473341528CA2822C200F416434C275FC4733412212C9740F240F41D28312D4904A3341DABBBF0BAC230F419E58558B8E4A334185DC5A77C51F0F41
343	435	\N	\N	\N	197 3 137	0106000020E61000000100000001030000000100000005000000206C2F40234E3341424C81CF3CEE0F4191207BDF2A4E3341158712B46B01104117827C76D04E3341B7B9801258011041C7549482C74E33413F2210CE1AEE0F41206C2F40234E3341424C81CF3CEE0F41
153	255	\N	\N	\N	210 78 44	0106000020E61000000100000001030000000100000005000000BC3821A6F34D33413DB2A1CFC3860F4127048B8EEA4D3341D4C22B6C3D720F417B68B516474D3341A59ED1525C720F4114ADC566504D3341BF79022FE5860F41BC3821A6F34D33413DB2A1CFC3860F41
106	208	\N	\N	\N	182 148 244	0106000020E610000001000000010300000001000000050000007F54E657FA473341528CA2822C200F415FF2F9F26045334128EA6B5D94200F419D1AE5F1634533414008A07D73240F416434C275FC4733412212C9740F240F417F54E657FA473341528CA2822C200F41
391	494	\N	\N	\N	231 208 206	0106000020E610000001000000010300000001000000050000000462C8DDFC4D33413D515296929B0F410A698027064E3341E21F5F258AB00F41FEB7CB99A84E33412414665467B00F41A276F6F99E4E334134C91F5C739B0F410462C8DDFC4D33413D515296929B0F41
21	123	\N	\N	\N	132 113 144	0106000020E61000000100000001030000000100000005000000A7A5ADF32F4D3341786CAA0A583F0F41BA9B659FF64B33416A1B2726993F0F414818C75DF44B33419D8CFC68B7490F41B9D40882344D33419BF867DB63490F41A7A5ADF32F4D3341786CAA0A583F0F41
344	436	\N	\N	\N	197 154 138	0106000020E6100000010000000103000000010000000500000058A310B11B4E3341EA8E4AF0CDD90F417F4C603E234E334135CC9FEB37EE0F4114970680C74E334108DA0AEF14EE0F41C153269BBE4E33416BC8DD26A2D90F4158A310B11B4E3341EA8E4AF0CDD90F41
154	256	\N	\N	\N	210 229 45	0106000020E61000000100000001030000000100000005000000F88BA39FA457334130F83DDC44790F41D9605686355A334193EA5F4EE9780F41D989FC6A335A33419D2341791B740F41EB9D18BDA2573341FC82508080740F41F88BA39FA457334130F83DDC44790F41
107	209	\N	\N	\N	183 43 246	0106000020E61000000100000001030000000100000005000000D2FF22260B5A3341BF96DAAB5A1D0F412BA67AB97A57334114583D20C11D0F415F13FA657D573341674B4AFBB9210F4112DBB6540D5A3341A461333D57210F41D2FF22260B5A3341BF96DAAB5A1D0F41
392	495	\N	\N	\N	232 103 207	0106000020E61000000100000001030000000100000005000000C7FC7F6EE14D3341DD0FC0F1A35D0F4127048B8EEA4D3341D4C22B6C3D720F414C900AFE8B4E3341BA53E2E71E720F41E3AB2287824E33417CB9B309845D0F41C7FC7F6EE14D3341DD0FC0F1A35D0F41
22	124	\N	\N	\N	133 8 146	0106000020E61000000100000001030000000100000005000000B8623649C8573341F55E07B775D30F41A9DB77E32C553341C354A807F5D30F41899CABFE2F553341F27F407818D80F41980C3820CA573341743C16A89CD70F41B8623649C8573341F55E07B775D30F41
345	437	\N	\N	\N	198 49 139	0106000020E610000001000000010300000001000000050000002EDFC4042B4C334124282F6E53DA0F41041E24F0344C334107C52335A1EE0F41E957EC19DC4C3341F9BB0E9A7DEE0F418211BB56D34C33412CE0CF3026DA0F412EDFC4042B4C334124282F6E53DA0F41
155	257	\N	\N	\N	211 124 46	0106000020E6100000010000000103000000010000000500000035C1CAFE455A3341746E78B3779E0F4134AD0C88B35733415ABF8BA1F89E0F41A4DEE57FB5573341410F67DFF2A30F41C798E02F485A334179C6AC1777A30F4135C1CAFE455A3341746E78B3779E0F41
108	210	\N	\N	\N	183 194 247	0106000020E6100000010000000103000000010000000500000093580D46E8543341BC32C52255260F4160D1FF3980573341ADD79A8DED250F415F13FA657D573341674B4AFBB9210F416DDCDA5EE554334118015AF11D220F4193580D46E8543341BC32C52255260F41
393	496	\N	\N	\N	232 254 209	0106000020E61000000100000001030000000100000005000000579EB2F3D34D33417BB0B6F6353F0F4103D91B63D84D334128C02A1639490F412AF1AA21794E334168E15F220F490F41683C4A8C744E3341715AD697143F0F41579EB2F3D34D33417BB0B6F6353F0F41
23	125	\N	\N	\N	133 159 147	0106000020E61000000100000001030000000100000005000000A9DB77E32C553341C354A807F5D30F41F81429CC98523341CCC079F372D40F41D33D7BCB9A523341396E90129DD80F41899CABFE2F553341F27F407818D80F41A9DB77E32C553341C354A807F5D30F41
346	438	\N	\N	\N	198 200 140	0106000020E61000000100000001030000000100000005000000815A16F1344C3341FF94F724A3EE0F4144B2F7083F4C33414A9B1B03A6011041065B6EFFE44C3341C2B23856920110414911301BDC4C33413A5C8F8980EE0F41815A16F1344C3341FF94F724A3EE0F41
156	258	\N	\N	\N	212 19 47	0106000020E6100000010000000103000000010000000500000034AD0C88B35733415ABF8BA1F89E0F41131B1E8F19553341157DFE077B9F0F4154E08D621B55334131016F0C70A40F41A4DEE57FB5573341410F67DFF2A30F4134AD0C88B35733415ABF8BA1F89E0F41
109	211	\N	\N	\N	184 89 248	0106000020E61000000100000001030000000100000005000000B26247E15352334162CCC829BC260F4193580D46E8543341BC32C52255260F416DDCDA5EE554334118015AF11D220F41D91035885252334113756D1F81220F41B26247E15352334162CCC829BC260F41
394	497	\N	\N	\N	233 149 210	0106000020E61000000100000001030000000100000005000000BC3821A6F34D33413DB2A1CFC3860F410462C8DDFC4D33413D515296929B0F41A276F6F99E4E334134C91F5C739B0F41701A5E6A954E3341ECBBC1BDA2860F41BC3821A6F34D33413DB2A1CFC3860F41
24	126	\N	\N	\N	134 54 148	0106000020E61000000100000001030000000100000004000000D2228514364F3341436464EC42D50F41057A514CF54F3341E8EA23E58BD00F410D3F41F4934E334100F604EBD5D00F41D2228514364F3341436464EC42D50F41
347	439	\N	\N	\N	199 95 141	0106000020E610000001000000010300000001000000050000008211BB56D34C33412CE0CF3026DA0F41E957EC19DC4C3341F9BB0E9A7DEE0F4121734B61804D33414FC8419C5AEE0F41A86B0B3C7B4D3341DA2CA410F9D90F418211BB56D34C33412CE0CF3026DA0F41
157	259	\N	\N	\N	212 170 49	0106000020E610000001000000010300000001000000060000001CCF445A7F543341D27C853F6D850F4168B8D98C8F54334161387A734E9A0F41C26C8F9D17553341443EA33D349A0F41F9AFF94313553341A79377CBC18F0F413EBD72EB0F553341B6BFC2B14F850F411CCF445A7F543341D27C853F6D850F41
110	212	\N	\N	\N	184 240 249	0106000020E6100000010000000103000000010000000500000036FB3259B34F3341C000911525270F41B26247E15352334162CCC829BC260F41D91035885252334113756D1F81220F41A3404CC2B04F33411E600C8DE6220F4136FB3259B34F3341C000911525270F41
71	173	\N	\N	\N	161 239 203	0106000020E61000000100000001030000000100000005000000C1186CEF8A503341243D1EDB8E480F41D21ABC7E8E503341BF260A431C5D0F4175D17147215133415084A930FF5C0F411456777419513341026AA87571480F41C1186CEF8A503341243D1EDB8E480F41
395	498	\N	\N	\N	234 44 211	0106000020E6100000010000000103000000010000000500000003D91B63D84D334128C02A1639490F41C7FC7F6EE14D3341DD0FC0F1A35D0F41E3AB2287824E33417CB9B309845D0F412AF1AA21794E334168E15F220F490F4103D91B63D84D334128C02A1639490F41
348	440	\N	\N	\N	199 246 143	0106000020E610000001000000010300000001000000050000004911301BDC4C33413A5C8F8980EE0F41065B6EFFE44C3341C2B2385692011041C7975197854D3341CD7A4B4C7F011041ECA44862804D33410A0225875EEE0F414911301BDC4C33413A5C8F8980EE0F41
158	260	\N	\N	\N	213 65 50	0106000020E61000000100000001030000000100000005000000685C176B3F543341A7A1EFEE02330F410623C4874F543341DFA8A7E5C7470F41BAC51172F7543341272F3C43A5470F41BA86C2E7F054334119AF76D7DD320F41685C176B3F543341A7A1EFEE02330F41
72	174	\N	\N	\N	162 134 204	0106000020E61000000100000001030000000100000005000000BAC51172F7543341272F3C43A5470F41357DF5CE905733416D3355F627470F411D3704218F57334100394AA1E8420F41924F910BF654334157C9C44532430F41BAC51172F7543341272F3C43A5470F41
25	127	\N	\N	\N	134 205 149	0106000020E6100000010000000103000000010000000600000083156A0F9B4D334124C20BB534C90F410ED02406994D3341516D77C1DEC00F41E4FC0E91674C33413E8C554D1FC10F416F8718512D4C334188E93B6AD2C20F41A3560B8F454D33419D33345A45C90F4183156A0F9B4D334124C20BB534C90F41
349	441	\N	\N	\N	200 141 144	0106000020E610000001000000010300000001000000050000008ADF79DC994B3341ECC30C98B9011041974E397C934B3341D8F1DC91C4EE0F41E9734EB7F04A33417A8B5444E6EE0F4153092AD1F24A3341EEE1C165CD0110418ADF79DC994B3341ECC30C98B9011041
159	261	\N	\N	\N	213 216 51	0106000020E6100000010000000103000000010000000500000068B8D98C8F54334161387A734E9A0F417CAA50B39F5433411046CE0820AF0F41E00F45481F5533419915C1B004AF0F41C26C8F9D17553341443EA33D349A0F4168B8D98C8F54334161387A734E9A0F41
73	175	\N	\N	\N	163 29 206	0106000020E61000000100000001030000000100000005000000C7FC7F6EE14D3341DD0FC0F1A35D0F4103D91B63D84D334128C02A1639490F41B9D40882344D33419BF867DB63490F41CFFCCBBF3D4D33413728ED5CC45D0F41C7FC7F6EE14D3341DD0FC0F1A35D0F41
396	499	\N	\N	\N	234 195 212	0106000020E6100000010000000103000000010000000500000027048B8EEA4D3341D4C22B6C3D720F41BC3821A6F34D33413DB2A1CFC3860F41701A5E6A954E3341ECBBC1BDA2860F414C900AFE8B4E3341BA53E2E71E720F4127048B8EEA4D3341D4C22B6C3D720F41
26	128	\N	\N	\N	135 100 150	0106000020E61000000100000001030000000100000005000000D30F5AFA98543341A3F97C7C89C30F4168A34122925233417F0449A7E8C30F41BE7DC0E09352334179884BEB3CC80F413E37ABBBBB543341756F587CD1C70F41D30F5AFA98543341A3F97C7C89C30F41
350	442	\N	\N	\N	201 36 145	0106000020E61000000100000001030000000100000006000000D48EEC7B934B33418686E898C3EE0F418792833B8C4B33418408DB246FDA0F418792833B8C4B33418408DB246FDA0F417E4BE204E64A334105BAE51BB5DA0F41E9734EB7F04A33417A8B5444E6EE0F41D48EEC7B934B33418686E898C3EE0F41
160	262	\N	\N	\N	214 111 52	0106000020E610000001000000010300000001000000060000008E29937D5F543341EA1486C25A5C0F412ADF23836F543341412F10EF01710F414F603B6608553341F7717508E5700F417FB6D2A306553341A348182C9D6C0F418C98F9E7FF543341F3FBFBFC3A5C0F418E29937D5F543341EA1486C25A5C0F41
74	176	\N	\N	\N	163 180 207	0106000020E610000001000000010300000001000000050000006555D94F1A5333419A6EA36E42710F410618E5A00D53334138E01CAD9D5C0F419C1E24926852334145F7035EBE5C0F41C2E1FBE2705233414680917562710F416555D94F1A5333419A6EA36E42710F41
397	500	\N	\N	\N	235 90 213	0106000020E61000000100000001030000000100000005000000061ED924CF4D33410D42DC645B340F41579EB2F3D34D33417BB0B6F6353F0F41683C4A8C744E3341715AD697143F0F41E73AF08F6F4E3341A7BF8DDE39340F41061ED924CF4D33410D42DC645B340F41
27	129	\N	\N	\N	135 251 151	0106000020E610000001000000010300000001000000050000004350C5C2C157334146675A23F5C20F41E8CF87CD26553341DA6BF8786FC30F410B07076328553341FB1B5755BCC70F41E6141673C3573341748FC2783AC70F414350C5C2C157334146675A23F5C20F41
75	177	\N	\N	\N	164 75 208	0106000020E610000001000000010300000001000000050000000618E5A00D53334138E01CAD9D5C0F41534737FE00533341CADC35E60C480F41398A434960523341F45B010C2E480F419C1E24926852334145F7035EBE5C0F410618E5A00D53334138E01CAD9D5C0F41
398	501	\N	\N	\N	235 241 214	0106000020E6100000010000000103000000010000000500000089780A61394633412E70D1A9B1730F4115D0DBCE2D4633412F69C28F1F5F0F41187C26BD844533418ED07E5B365F0F41E489B8548E4533415B7548FFD1730F4189780A61394633412E70D1A9B1730F41
28	130	\N	\N	\N	136 146 153	0106000020E610000001000000010300000001000000060000005AA3B97FDA4A3341A19B73DEBDC90F41A3560B8F454D33419D33345A45C90F416F8718512D4C334188E93B6AD2C20F417F5ED13C464B33415EA4662AB4BD0F419380CE41D44A3341E53C931320BB0F415AA3B97FDA4A3341A19B73DEBDC90F41
76	178	\N	\N	\N	164 226 209	0106000020E61000000100000001030000000100000005000000F80047D59D5733418893578318680F41DA68F0F6045533410A3BA2AE89680F417FB6D2A306553341A348182C9D6C0F41033A3C6D9F5733416B8EF13E206C0F41F80047D59D5733418893578318680F41
401	505	\N	\N	\N	238 77 219	0106000020E6100000010000000103000000010000000500000085B30C5F574633416DF0B99822A10F418AE565FD44463341913893DA55880F41A9E7AFF19745334111EABB3A79880F41BB820C82A1453341F013B161059D0F4185B30C5F574633416DF0B99822A10F41
211	313	\N	\N	\N	125 12 249	0106000020E6100000010000000103000000010000000500000020EEC5147F45334156CD0D9C0E530F4110239678144833416F5530A180520F410842ED67124833413A139AF85F4E0F41F35A572C7D453341D29B7D3EF54E0F4120EEC5147F45334156CD0D9C0E530F41
399	502	\N	\N	\N	236 136 216	0106000020E610000001000000010300000001000000050000008AE565FD44463341913893DA55880F4189780A61394633412E70D1A9B1730F41E489B8548E4533415B7548FFD1730F41A9E7AFF19745334111EABB3A79880F418AE565FD44463341913893DA55880F41
29	131	\N	\N	\N	137 41 154	0106000020E61000000100000001030000000100000005000000ABD289B0D14A334184AC26F91CB50F414A114F18654D3341938F844086B40F41E9108059634D334173E1FF09ADB00F414983C907D04A33416851F5583AB10F41ABD289B0D14A334184AC26F91CB50F41
77	179	\N	\N	\N	165 121 210	0106000020E6100000010000000103000000010000000500000095E076F52D5A33411C2C03D5A8670F41F80047D59D5733418893578318680F41033A3C6D9F5733416B8EF13E206C0F417C64D4B42F5A3341F6F00BEBA46B0F4195E076F52D5A33411C2C03D5A8670F41
402	506	\N	\N	\N	238 228 220	0106000020E610000001000000010300000001000000060000008AE565FD44463341913893DA55880F4185B30C5F574633416DF0B99822A10F41730D219BE74633417D7425E565A40F41CA810821E646334108292B29F09C0F41B5A07306E246334188404DC035880F418AE565FD44463341913893DA55880F41
212	314	\N	\N	\N	125 163 250	0106000020E6100000010000000103000000010000000500000010239678144833416F5530A180520F418578A257A74A33419E1CBC30F3510F416C343F91A54A33412B956B2ACB4D0F410842ED67124833413A139AF85F4E0F4110239678144833416F5530A180520F41
400	504	\N	\N	\N	237 182 218	0106000020E61000000100000001030000000100000007000000FFD4D3A4634633410AA9CE66B1B10F4185B30C5F574633416DF0B99822A10F41BB820C82A1453341F013B161059D0F41D0272EF8A945334178BEF92D33AF0F4106FDF2261346334176B538A2BEB10F41FFD4D3A4634633410AA9CE66B1B10F41FFD4D3A4634633410AA9CE66B1B10F41
403	507	\N	\N	\N	239 123 222	0106000020E61000000100000001030000000100000005000000784592B284473341BBE8730873730F41374E923076473341B4AFE666E95E0F4104356EDFD9463341514AA05C085F0F41635777F0DD463341B972518E92730F41784592B284473341BBE8730873730F41
30	132	\N	\N	\N	137 192 155	0106000020E610000001000000010300000001000000050000008DB61D0914543341BE475B2A29B30F41E3D5B7808B523341300AF41E73B30F41388FBB2B8D5233418258320897B70F417569276135543341019951A944B70F418DB61D0914543341BE475B2A29B30F41
78	180	\N	\N	\N	166 16 212	0106000020E610000001000000010300000001000000050000006E8B06DC3C5A3341FE8A89D3A2890F4182457D4CAB5733412B35DF92268A0F415573D554AD5733413A3EBC884A8F0F41AB168C1E3F5A3341316FE9F9C98E0F416E8B06DC3C5A3341FE8A89D3A2890F41
213	315	\N	\N	\N	126 58 251	0106000020E610000001000000010300000001000000050000000EE9737F16483341D0CBB2B68D560F41DB005B1EA94A3341BD18B7FE1B560F418578A257A74A33419E1CBC30F3510F4110239678144833416F5530A180520F410EE9737F16483341D0CBB2B68D560F41
404	508	\N	\N	\N	240 18 223	0106000020E61000000100000001030000000100000005000000F15D3C63AA4733410BC171ECCDA80F4112A0CDE7A1473341209146FDCB9C0F41CA810821E646334108292B29F09C0F41730D219BE74633417D7425E565A40F41F15D3C63AA4733410BC171ECCDA80F41
261	353	\N	\N	\N	148 165 40	0106000020E61000000100000001030000000100000005000000EC60BD462A4A33419667E9174F9C0F41FE0A7A3A354A3341044380865BB10F414983C907D04A33416751F5583AB10F41761CF30BC74A334168CD08E5309C0F41EC60BD462A4A33419667E9174F9C0F41
79	181	\N	\N	\N	166 167 213	0106000020E6100000010000000103000000010000000500000082457D4CAB5733412B35DF92268A0F41791BE4E411553341C59289E4AB8A0F4183816CC8135533412E97D69BCC8F0F415573D554AD5733413A3EBC884A8F0F4182457D4CAB5733412B35DF92268A0F41
214	316	\N	\N	\N	126 209 253	0106000020E61000000100000001030000000100000005000000897F92EA8045334198348EF1FF560F410EE9737F16483341D0CBB2B68D560F4110239678144833416F5530A180520F4120EEC5147F45334156CD0D9C0E530F41897F92EA8045334198348EF1FF560F41
405	509	\N	\N	\N	240 169 224	0106000020E6100000010000000103000000010000000500000012A0CDE7A1473341209146FDCB9C0F416D8B4D439347334146F0C28411880F41B5A07306E246334188404DC035880F41CA810821E646334108292B29F09C0F4112A0CDE7A1473341209146FDCB9C0F41
262	354	\N	\N	\N	149 60 41	0106000020E6100000010000000103000000010000000500000034F46C100A4A3341F97558B5665E0F41BEA293C3144A3341C9E8AF03F7720F4109DEFC63B54A3341B4F68BA6D8720F4107C21A9BAC4A3341E5D70184465E0F4134F46C100A4A3341F97558B5665E0F41
215	317	\N	\N	\N	127 104 254	0106000020E610000001000000010300000001000000050000003DA1548D9E4A3341700F75BA5D3D0F41B81589350A48334162ADBDCFFD3D0F417D341E2E0C4833411BD08358EE410F417DDCFA43A04A33411BAC1DE660410F413DA1548D9E4A3341700F75BA5D3D0F41
406	510	\N	\N	\N	241 64 225	0106000020E610000001000000010300000001000000050000006D8B4D439347334146F0C28411880F41784592B284473341BBE8730873730F41635777F0DD463341B972518E92730F41B5A07306E246334188404DC035880F416D8B4D439347334146F0C28411880F41
263	355	\N	\N	\N	149 211 43	0106000020E61000000100000001030000000100000005000000E76F0290184833415D1F9D2AAE5A0F410C603CDFAA4A33417D12871F375A0F41DB005B1EA94A3341BD18B7FE1B560F410EE9737F16483341D0CBB2B68D560F41E76F0290184833415D1F9D2AAE5A0F41
80	182	\N	\N	\N	167 62 214	0106000020E61000000100000001030000000100000005000000A1B56993315A334132C50D30E86F0F41625FA51DA1573341ABA500D265700F41EB9D18BDA2573341FC82508080740F41D989FC6A335A33419D2341791B740F41A1B56993315A334132C50D30E86F0F41
216	318	\N	\N	\N	127 255 255	0106000020E61000000100000001030000000100000005000000B81589350A48334162ADBDCFFD3D0F415447379175453341D07293F79D3E0F41F0DD015E774533413907D3F27B420F417D341E2E0C4833411BD08358EE410F41B81589350A48334162ADBDCFFD3D0F41
407	511	\N	\N	\N	241 215 226	0106000020E61000000100000001030000000100000005000000127C63FFCB4833411A7F8C2935730F412614DC58C14833415FF441D0A75E0F416F3EAC9D1A4833411BD903D6C85E0F416C5146E52448334101020DC054730F41127C63FFCB4833411A7F8C2935730F41
264	356	\N	\N	\N	150 106 44	0106000020E610000001000000010300000001000000050000007182D4D882453341817360D3255B0F41E76F0290184833415D1F9D2AAE5A0F410EE9737F16483341D0CBB2B68D560F41897F92EA8045334198348EF1FF560F417182D4D882453341817360D3255B0F41
217	319	\N	\N	\N	128 151 0	0106000020E61000000100000001030000000100000005000000AC3DC591604B334105A5D58B4A870F4140C6C4056A4B33413E802480119C0F4128F8A0E30E4C33418A7D02BEF19B0F4147AE4AF2034C33413848AD2529870F41AC3DC591604B334105A5D58B4A870F41
408	512	\N	\N	\N	242 110 227	0106000020E610000001000000010300000001000000050000007B188E89EB483341FB52C6C711B00F413A70E06CE1483341F6A3AB708E9C0F412C71989539483341F5E779C5AE9C0F41F550915B414833418BF46E3A38AC0F417B188E89EB483341FB52C6C711B00F41
265	357	\N	\N	\N	151 1 45	0106000020E610000001000000010300000001000000050000005FBAF93F185A3341243F839928360F41178F68468A5733418DB8580DA2360F4134A700E58B573341E18F6C91BA3A0F41EB4796111A5A334127677C4A4E3A0F415FBAF93F185A3341243F839928360F41
218	471	\N	\N	\N	218 63 179	0106000020E6100000010000000103000000010000000500000056E68D36574B3341315B880FBA720F41AC3DC591604B334105A5D58B4A870F4147AE4AF2034C33413848AD2529870F41A888F71FF94B3341982A33749B720F4156E68D36574B3341315B880FBA720F41
409	513	\N	\N	\N	243 5 229	0106000020E610000001000000010300000001000000050000003A70E06CE1483341F6A3AB708E9C0F41804B99ACD648334185C56267CF870F41EC775E352F483341B67985A3F1870F412C71989539483341F5E779C5AE9C0F413A70E06CE1483341F6A3AB708E9C0F41
266	358	\N	\N	\N	151 152 46	0106000020E61000000100000001030000000100000005000000178F68468A5733418DB8580DA2360F41F18C103EF2543341CF6F5A5F1D370F410AD6E283F3543341F201C888283B0F4134A700E58B573341E18F6C91BA3A0F41178F68468A5733418DB8580DA2360F41
219	472	\N	\N	\N	218 214 180	0106000020E610000001000000010300000001000000060000009AA9F9D94D4B33413ADE6294265E0F4156E68D36574B3341315B880FBA720F41A888F71FF94B3341982A33749B720F417F0B6860EF4B3341C8E3399F17600F41014366D6EF4B334180FA387F065E0F419AA9F9D94D4B33413ADE6294265E0F41
410	514	\N	\N	\N	243 156 230	0106000020E61000000100000001030000000100000005000000804B99ACD648334185C56267CF870F41127C63FFCB4833411A7F8C2935730F416C5146E52448334101020DC054730F41EC775E352F483341B67985A3F1870F41804B99ACD648334185C56267CF870F41
267	359	\N	\N	\N	152 47 47	0106000020E61000000100000001030000000100000005000000FAE390D61B5A3341560B652D573E0F419B4341868D5733417C638ACED93E0F411D3704218F57334100394AA1E8420F410476A6B71D5A3341B92C5026A0420F41FAE390D61B5A3341560B652D573E0F41
220	473	\N	\N	\N	219 109 182	0106000020E61000000100000001030000000100000007000000C4795A64414B3341E3BA810EC4420F41ECABC8A2444B334118A30A46E5490F414818C75DF44B33419D8CFC68B7490F41BA9B659FF64B33416A1B2726993F0F41D9C24A1F7B4B334192A5BBCFB23F0F41E0A556F77F4B3341E48929D7B9420F41C4795A64414B3341E3BA810EC4420F41
268	360	\N	\N	\N	152 198 48	0106000020E610000001000000010300000001000000050000009B4341868D5733417C638ACED93E0F41F1A92ED7F4543341413DB1815E3F0F41924F910BF654334157C9C44532430F411D3704218F57334100394AA1E8420F419B4341868D5733417C638ACED93E0F41
269	361	\N	\N	\N	153 93 50	0106000020E610000001000000010300000001000000050000000D5E397E1F5A33416D4239ACAC460F41357DF5CE905733416D3355F627470F418356E55092573341A733EA00F84A0F41129C1329215A33415EF242FC794A0F410D5E397E1F5A33416D4239ACAC460F41
270	362	\N	\N	\N	153 244 51	0106000020E61000000100000001030000000100000005000000357DF5CE905733416D3355F627470F41BAC51172F7543341272F3C43A5470F415E705A04F95433414D5D9B08784B0F418356E55092573341A733EA00F84A0F41357DF5CE905733416D3355F627470F41
321	413	\N	\N	\N	184 9 111	0106000020E6100000010000000103000000010000000500000050A082E66D583341B6D1989193D70F4103FE711C735833416ED6767F48E80F4113BE93B71859334133392F4843E80F4113BE93B718593341AF2E12178AD70F4150A082E66D583341B6D1989193D70F41
131	233	\N	\N	\N	197 84 18	0106000020E61000000100000001030000000100000005000000D146162A75573341DC35159B7E150F41EE4A2BF3DC543341250392AEE3150F41F5440BA9DF5433413A141941D3190F418B718DCD7757334149F1270B6A190F41D146162A75573341DC35159B7E150F41
322	414	\N	\N	\N	184 160 112	0106000020E61000000100000001030000000100000005000000912D1B6B78583341F4E550B44CF90F416617B7AA7A58334157501B204100104113BE93B7185933416BF2786E3300104113BE93B7185933417597ABE042F90F41912D1B6B78583341F4E550B44CF90F41
132	234	\N	\N	\N	197 235 19	0106000020E61000000100000001030000000100000005000000178F68468A5733418DB8580DA2360F415FBAF93F185A3341243F839928360F415BA4A255165A3341ABE99A85CA310F4144E94E92885733419B35A02553320F41178F68468A5733418DB8580DA2360F41
323	415	\N	\N	\N	185 55 113	0106000020E610000001000000010300000001000000050000000122DBB42257334187DF50C6BBD70F41A71FB8D42757334170DD92EE52E80F41B3491432CD57334106513DB94DE80F41980C3820CA573341743C16A89CD70F410122DBB42257334187DF50C6BBD70F41
133	235	\N	\N	\N	198 130 20	0106000020E61000000100000001030000000100000005000000F18C103EF2543341CF6F5A5F1D370F41178F68468A5733418DB8580DA2360F4144E94E92885733419B35A02553320F41BA86C2E7F054334119AF76D7DD320F41F18C103EF2543341CF6F5A5F1D370F41
371	463	\N	\N	\N	213 135 170	0106000020E61000000100000001030000000100000005000000A66E94F1F84F33411C63C22FEED40F41F81429CC98523341CCC079F372D40F41E8AB0A099752334151F9B43513D00F41057A514CF54F3341E8EA23E58BD00F41A66E94F1F84F33411C63C22FEED40F41
181	283	\N	\N	\N	226 210 77	0106000020E610000001000000010300000001000000050000007F54E657FA473341528CA2822C200F419E58558B8E4A334185DC5A77C51F0F41925934058C4A3341F47D7A0C761B0F416456CAFFF7473341B5D9469BDE1B0F417F54E657FA473341528CA2822C200F41
324	416	\N	\N	\N	185 206 114	0106000020E61000000100000001030000000100000005000000A71FB8D42757334170DD92EE52E80F4115FD50192D573341C0BEDF0361F90F413DEC2954D0573341736A3A0257F90F41B3491432CD57334106513DB94DE80F41A71FB8D42757334170DD92EE52E80F41
134	236	\N	\N	\N	199 25 21	0106000020E610000001000000010300000001000000050000009B4341868D5733417C638ACED93E0F41FAE390D61B5A3341560B652D573E0F41EB4796111A5A334127677C4A4E3A0F4134A700E58B573341E18F6C91BA3A0F419B4341868D5733417C638ACED93E0F41
372	464	\N	\N	\N	214 30 171	0106000020E61000000100000001030000000100000005000000779B38EDF34F33416033902BDACC0F41622F62879552334117E47FF355CC0F41BE7DC0E09352334179884BEB3CC80F41CD195C67F24F33417FA46707C0C80F41779B38EDF34F33416033902BDACC0F41
182	284	\N	\N	\N	227 105 78	0106000020E610000001000000010300000001000000050000009E58558B8E4A334185DC5A77C51F0F4145A7054A1D4D33417A2214465F1F0F41E5D7207B1A4D334106022F5F0E1B0F41925934058C4A3341F47D7A0C761B0F419E58558B8E4A334185DC5A77C51F0F41
325	417	\N	\N	\N	186 101 116	0106000020E6100000010000000103000000010000000500000015FD50192D573341C0BEDF0361F90F413E9EC6642F573341E559267567001041C8B511ABD157334142D994C44F0010413DEC2954D0573341736A3A0257F90F4115FD50192D573341C0BEDF0361F90F41
135	237	\N	\N	\N	199 176 23	0106000020E61000000100000001030000000100000005000000F1A92ED7F4543341413DB1815E3F0F419B4341868D5733417C638ACED93E0F4134A700E58B573341E18F6C91BA3A0F410AD6E283F3543341F201C888283B0F41F1A92ED7F4543341413DB1815E3F0F41
373	465	\N	\N	\N	214 181 172	0106000020E610000001000000010300000001000000050000008B950F41DC4A3341A2F03D10DACD0F41885A482EF54D3341AD27346C3ECD0F41A3560B8F454D33419D33345A45C90F415AA3B97FDA4A3341A19B73DEBDC90F418B950F41DC4A3341A2F03D10DACD0F41
183	285	\N	\N	\N	228 0 79	0106000020E6100000010000000103000000010000000500000045A7054A1D4D33417A2214465F1F0F41CDE0A15CAE4F3341A480CAB7F81E0F411B3A92B9AB4F334119B30341A61A0F41E5D7207B1A4D334106022F5F0E1B0F4145A7054A1D4D33417A2214465F1F0F41
326	418	\N	\N	\N	186 252 117	0106000020E61000000100000001030000000100000005000000091B8131E05533411F7F526C75F90F411019ED04DD553341A9DFE7595DE80F41850453F6335533415BE602AD62E80F412A4B5421385533418BCFD1B97FF90F41091B8131E05533411F7F526C75F90F41
136	238	\N	\N	\N	200 71 24	0106000020E610000001000000010300000001000000050000000623C4874F543341DFA8A7E5C7470F41685C176B3F543341A7A1EFEE02330F41D190F300A2533341C7A48BD423330F41A343F9FAAE533341049C2A03E9470F410623C4874F543341DFA8A7E5C7470F41
51	153	\N	\N	\N	150 35 180	0106000020E6100000010000000103000000010000000500000042653ABD15553341AFE1CB361C950F41A55AA068AF573341B11774728B940F415573D554AD5733413A3EBC884A8F0F4183816CC8135533412E97D69BCC8F0F4142653ABD15553341AFE1CB361C950F41
374	466	\N	\N	\N	215 76 173	0106000020E61000000100000001030000000100000005000000FC5D0DE529553341F6248D54D4CB0F41EEC70A11C557334176E99B5F51CB0F41E6141673C3573341748FC2783AC70F410B07076328553341FB1B5755BCC70F41FC5D0DE529553341F6248D54D4CB0F41
184	286	\N	\N	\N	228 151 80	0106000020E61000000100000001030000000100000005000000CDE0A15CAE4F3341A480CAB7F81E0F415E147D46515233416EF7A5608F1E0F417F5F63E54F52334167E242233B1A0F411B3A92B9AB4F334119B30341A61A0F41CDE0A15CAE4F3341A480CAB7F81E0F41
327	419	\N	\N	\N	187 147 118	0106000020E610000001000000010300000001000000050000001019ED04DD553341A9DFE7595DE80F41EF57B2F9D9553341F0C627E0F8D70F41899CABFE2F553341F27F407818D80F41850453F6335533415BE602AD62E80F411019ED04DD553341A9DFE7595DE80F41
137	239	\N	\N	\N	200 222 25	0106000020E61000000100000001030000000100000005000000E8CF87CD26553341DA6BF8786FC30F41D30F5AFA98543341A3F97C7C89C30F413E37ABBBBB543341756F587CD1C70F410B07076328553341FB1B5755BCC70F41E8CF87CD26553341DA6BF8786FC30F41
52	154	\N	\N	\N	150 186 181	0106000020E61000000100000001030000000100000005000000FE0A7A3A354A3341044380865BB10F41EC60BD462A4A33419667E9174F9C0F411DC409BC7E493341182E3823709C0F41B940BE3288493341B97F2C9C80B10F41FE0A7A3A354A3341044380865BB10F41
375	467	\N	\N	\N	215 227 174	0106000020E61000000100000001030000000100000005000000622F62879552334117E47FF355CC0F41FC5D0DE529553341F6248D54D4CB0F410B07076328553341FB1B5755BCC70F41BE7DC0E09352334179884BEB3CC80F41622F62879552334117E47FF355CC0F41
185	287	\N	\N	\N	229 46 82	0106000020E610000001000000010300000001000000050000005E147D46515233416EF7A5608F1E0F41F97E20A5E2543341B0857EC6281E0F41F5440BA9DF5433413A141941D3190F417F5F63E54F52334167E242233B1A0F415E147D46515233416EF7A5608F1E0F41
328	420	\N	\N	\N	188 42 119	0106000020E6100000010000000103000000010000000500000043A6F7A0E155334153D0B22E98001041091B8131E05533411F7F526C75F90F412A4B5421385533418BCFD1B97FF90F415637B50C3A553341C79582A5B000104143A6F7A0E155334153D0B22E98001041
138	240	\N	\N	\N	201 117 26	0106000020E6100000010000000103000000010000000500000014533EBC205533410187768AF6B20F418DB61D0914543341BE475B2A29B30F417569276135543341019951A944B70F413B2443412255334166598AAA16B70F4114533EBC205533410187768AF6B20F41
53	155	\N	\N	\N	151 81 182	0106000020E610000001000000010300000001000000050000002614DC58C14833415FF441D0A75E0F41127C63FFCB4833411A7F8C2935730F41D28058286C4933414B3DFDE216730F418DD015A061493341CD4FAF11885E0F412614DC58C14833415FF441D0A75E0F41
376	468	\N	\N	\N	216 122 176	0106000020E61000000100000001030000000100000005000000885A482EF54D3341AD27346C3ECD0F41779B38EDF34F33416033902BDACC0F41CD195C67F24F33417FA46707C0C80F41A3560B8F454D33419D33345A45C90F41885A482EF54D3341AD27346C3ECD0F41
186	288	\N	\N	\N	229 197 83	0106000020E61000000100000001030000000100000005000000F97E20A5E2543341B0857EC6281E0F412BA67AB97A57334114583D20C11D0F418B718DCD7757334149F1270B6A190F41F5440BA9DF5433413A141941D3190F41F97E20A5E2543341B0857EC6281E0F41
329	421	\N	\N	\N	188 193 120	0106000020E61000000100000001030000000100000005000000A28BCFB386543341BEA3CD6B3AD80F41883715348D5433410EB10BE3E8EC0F4195435D4534553341E4D4C64CC6EC0F41899CABFE2F553341F27F407818D80F41A28BCFB386543341BEA3CD6B3AD80F41
139	241	\N	\N	\N	202 12 27	0106000020E61000000100000001030000000100000005000000E38085632255334138F9B22F1EBB0F4111CB006E625433417039C75E2EBB0F4156345A8B77543341C99C6F296BBF0F41A12D3C45255533410EDDA27346BF0F41E38085632255334138F9B22F1EBB0F41
54	156	\N	\N	\N	151 232 183	0106000020E61000000100000001030000000100000005000000B126C02A08483341B1282AE5E8390F41AF0CADCF9C4A3341C7985F274A390F4155279DFD9A4A3341F110AFCA06350F4180696BFE054833412F69B6ED90350F41B126C02A08483341B1282AE5E8390F41
377	469	\N	\N	\N	217 17 177	0106000020E61000000100000001030000000100000006000000D94125B133533341749C8B75919A0F4116C6B78040533341642D044E6BAF0F4176382470F45333414BD77BBD44AF0F4124330926EF5333418535ECEF9DAE0F4108535E8AE253334141002CC76F9A0F41D94125B133533341749C8B75919A0F41
187	289	\N	\N	\N	230 92 84	0106000020E6100000010000000103000000010000000500000060D1FF3980573341ADD79A8DED250F4193580D46E8543341BC32C52255260F4129EAE418EB543341FC6471C56E2A0F411619D5FE825733411C1F6A8F0A2A0F4160D1FF3980573341ADD79A8DED250F41
330	422	\N	\N	\N	189 88 121	0106000020E61000000100000001030000000100000005000000883715348D5433410EB10BE3E8EC0F41B0A1AAAF935433410B4DFC37C40010415637B50C3A553341C79582A5B000104195435D4534553341E4D4C64CC6EC0F41883715348D5433410EB10BE3E8EC0F41
140	242	\N	\N	\N	202 163 29	0106000020E610000001000000010300000001000000060000007CAA50B39F5433411046CE0820AF0F4168B8D98C8F54334161387A734E9A0F4108535E8AE253334141002CC76F9A0F4124330926EF5333418535ECEF9DAE0F4176382470F45333414BD77BBD44AF0F417CAA50B39F5433411046CE0820AF0F41
55	157	\N	\N	\N	152 127 184	0106000020E61000000100000001030000000100000005000000EC60BD462A4A33419667E9174F9C0F415DA442791F4A3341570507308C870F416E9BF4687549334120B21FF4AE870F411DC409BC7E493341182E3823709C0F41EC60BD462A4A33419667E9174F9C0F41
378	470	\N	\N	\N	217 168 178	0106000020E61000000100000001030000000100000005000000897D26DF26533341196E8DABB3850F41D94125B133533341749C8B75919A0F4108535E8AE253334141002CC76F9A0F411E3CB67FD55333415953A1F88F850F41897D26DF26533341196E8DABB3850F41
188	290	\N	\N	\N	230 243 85	0106000020E6100000010000000103000000010000000500000093580D46E8543341BC32C52255260F41B26247E15352334162CCC829BC260F41C8E2B62E55523341A51DD4AED22A0F4129EAE418EB543341FC6471C56E2A0F4193580D46E8543341BC32C52255260F41
56	158	\N	\N	\N	153 22 186	0106000020E610000001000000010300000001000000060000003A70E06CE1483341F6A3AB708E9C0F417B188E89EB483341FB52C6C711B00F410295B2352E493341F75095E593B10F41B940BE3288493341B97F2C9C80B10F411DC409BC7E493341182E3823709C0F413A70E06CE1483341F6A3AB708E9C0F41
379	481	\N	\N	\N	224 37 191	0106000020E610000001000000010300000001000000050000000618E5A00D53334138E01CAD9D5C0F416555D94F1A5333419A6EA36E42710F41F1E5D6BBC85333418525E97521710F417F9F1ED5BB533341F563762C7B5C0F410618E5A00D53334138E01CAD9D5C0F41
189	291	\N	\N	\N	231 138 86	0106000020E61000000100000001030000000100000005000000B26247E15352334162CCC829BC260F4136FB3259B34F3341C000911525270F41681A80D5B54F33415D67BF04382B0F41C8E2B62E55523341A51DD4AED22A0F41B26247E15352334162CCC829BC260F41
57	159	\N	\N	\N	153 173 187	0106000020E61000000100000001030000000100000005000000804B99ACD648334185C56267CF870F413A70E06CE1483341F6A3AB708E9C0F411DC409BC7E493341182E3823709C0F416E9BF4687549334120B21FF4AE870F41804B99ACD648334185C56267CF870F41
380	482	\N	\N	\N	224 188 192	0106000020E61000000100000001030000000100000005000000534737FE00533341CADC35E60C480F410618E5A00D53334138E01CAD9D5C0F417F9F1ED5BB533341F563762C7B5C0F41A343F9FAAE533341049C2A03E9470F41534737FE00533341CADC35E60C480F41
190	292	\N	\N	\N	232 33 87	0106000020E6100000010000000103000000010000000500000036FB3259B34F3341C000911525270F411E10569B224D33418BDAB98A8B270F41493BBB3F254D3341C23B2F209B2B0F41681A80D5B54F33415D67BF04382B0F4136FB3259B34F3341C000911525270F41
58	160	\N	\N	\N	154 68 188	0106000020E610000001000000010300000001000000050000006B947E544D4F3341C96D2C0644B00F41A60350E0444F3341ADE40A67539B0F41A276F6F99E4E334134C91F5C739B0F41FEB7CB99A84E33412414665467B00F416B947E544D4F3341C96D2C0644B00F41
241	333	\N	\N	\N	136 217 17	0106000020E6100000010000000103000000010000000500000021FF074AC2513341EA6BB6A24E480F417D95BD11BB513341CF4B509789330F417329A98C11513341E32C8C04AD330F411456777419513341026AA87571480F4121FF074AC2513341EA6BB6A24E480F41
59	161	\N	\N	\N	154 219 189	0106000020E610000001000000010300000001000000050000007879DA30344F3341C218521CFF710F41807096DE2B4F3341A8D4967F625D0F41E3AB2287824E33417CB9B309845D0F414C900AFE8B4E3341BA53E2E71E720F417879DA30344F3341C218521CFF710F41
242	334	\N	\N	\N	137 112 18	0106000020E61000000100000001030000000100000005000000049B089CD05133410135CCC180710F41E7369F6FC9513341108B9DE2DD5C0F4175D17147215133415084A930FF5C0F414524D821295133417F0E766AA0710F41049B089CD05133410135CCC180710F41
60	162	\N	\N	\N	155 114 190	0106000020E610000001000000010300000001000000050000008BF93A941F4F33417E2CE00DF13E0F41683C4A8C744E3341715AD697143F0F412AF1AA21794E334168E15F220F490F4152C4EE97234F3341263D52A5E2480F418BF93A941F4F33417E2CE00DF13E0F41
243	335	\N	\N	\N	138 7 19	0106000020E61000000100000001030000000100000007000000D9ABD8FCA3503341DA8D8795FAAF0F41741EDD9D9A5033411522A5FB17A30F410CD12AF55150334137C128FA7CA20F41AA6684240E5033416386543585A00F4139BA1AB9E24F3341E0BFD71E839E0F41A71CFA43E94F33411792709A22B00F41D9ABD8FCA3503341DA8D8795FAAF0F41
291	383	\N	\N	\N	166 87 76	0106000020E6100000010000000103000000010000000500000080DEE0678D523341FE680D72B5BB0F4111CB006E625433417039C75E2EBB0F417569276135543341019951A944B70F41388FBB2B8D5233418258320897B70F4180DEE0678D523341FE680D72B5BB0F41
244	336	\N	\N	\N	138 158 20	0106000020E61000000100000001030000000100000005000000E7369F6FC9513341108B9DE2DD5C0F4121FF074AC2513341EA6BB6A24E480F411456777419513341026AA87571480F4175D17147215133415084A930FF5C0F41E7369F6FC9513341108B9DE2DD5C0F41
292	384	\N	\N	\N	166 238 77	0106000020E6100000010000000103000000010000000500000011CB006E625433417039C75E2EBB0F41E38085632255334138F9B22F1EBB0F413B2443412255334166598AAA16B70F417569276135543341019951A944B70F4111CB006E625433417039C75E2EBB0F41
245	337	\N	\N	\N	139 53 21	0106000020E61000000100000001030000000100000006000000A607BD3BE6513341BEB8D484B5AF0F416DE13BF9DE513341BA518617D39A0F4102D63C1337513341A43B2A6FF39A0F41537F599F35513341048F928F2C9E0F414A0AEBD74551334166A6F7E4D7AF0F41A607BD3BE6513341BEB8D484B5AF0F41
293	385	\N	\N	\N	167 133 78	0106000020E61000000100000001030000000100000005000000E38085632255334138F9B22F1EBB0F41CE350556BE573341CC3BC350A1BA0F41194825DEBC57334190E70E3A95B60F413B2443412255334166598AAA16B70F41E38085632255334138F9B22F1EBB0F41
246	338	\N	\N	\N	139 204 23	0106000020E610000001000000010300000001000000070000004A0AEBD74551334166A6F7E4D7AF0F41537F599F35513341048F928F2C9E0F4130101E671D513341D2B612B6D2A00F41597A89DAE050334137C128FA7CA20F41741EDD9D9A5033411522A5FB17A30F41D9ABD8FCA3503341DA8D8795FAAF0F414A0AEBD74551334166A6F7E4D7AF0F41
294	386	\N	\N	\N	168 28 79	0106000020E6100000010000000103000000010000000500000068A34122925233417F0449A7E8C30F41D30F5AFA98543341A3F97C7C89C30F4156345A8B77543341C99C6F296BBF0F4162BF9D7C905233417A760E15D2BF0F4168A34122925233417F0449A7E8C30F41
247	339	\N	\N	\N	140 99 24	0106000020E610000001000000010300000001000000050000006DE13BF9DE513341BA518617D39A0F41A607BD3BE6513341BEB8D484B5AF0F413339C9F089523341D11DAF6E92AF0F418E8A5988815233413BE92FC7B39A0F416DE13BF9DE513341BA518617D39A0F41
295	387	\N	\N	\N	168 179 80	0106000020E61000000100000001030000000100000005000000D30F5AFA98543341A3F97C7C89C30F41E8CF87CD26553341DA6BF8786FC30F41A12D3C45255533410EDDA27346BF0F4156345A8B77543341C99C6F296BBF0F41D30F5AFA98543341A3F97C7C89C30F41
248	340	\N	\N	\N	140 250 25	0106000020E6100000010000000103000000010000000500000051DD57B9D75133411C64232FF8850F416DE13BF9DE513341BA518617D39A0F418E8A5988815233413BE92FC7B39A0F41F6CCBE207952334170E23D30D7850F4151DD57B9D75133411C64232FF8850F41
296	388	\N	\N	\N	169 74 81	0106000020E61000000100000001030000000100000005000000E8CF87CD26553341DA6BF8786FC30F414350C5C2C157334146675A23F5C20F41DDA94E16C05733416E4BDB8BB9BE0F41A12D3C45255533410EDDA27346BF0F41E8CF87CD26553341DA6BF8786FC30F41
249	341	\N	\N	\N	141 145 26	0106000020E61000000100000001030000000100000005000000049B089CD05133410135CCC180710F4151DD57B9D75133411C64232FF8850F41F6CCBE207952334170E23D30D7850F41C2E1FBE2705233414680917562710F41049B089CD05133410135CCC180710F41
297	389	\N	\N	\N	169 225 83	0106000020E61000000100000001030000000100000008000000B8DCAB6D9647334140D2F8FFCBC70F4165F793D9224833411E101FC1EFD50F414828D2939247334104892DEF71DA0F4118D9FF138C4733418E2BC66CA7DB0F41A35B623CC3483341D332B72473DB0F41FA31BEC09B4833412965A066B0CE0F412440429A984733410D98B935CDC70F41B8DCAB6D9647334140D2F8FFCBC70F41
250	342	\N	\N	\N	142 40 27	0106000020E610000001000000010300000001000000050000007D95BD11BB513341CF4B509789330F4121FF074AC2513341EA6BB6A24E480F41398A434960523341F45B010C2E480F415C9111EB575233419AA5F7CF68330F417D95BD11BB513341CF4B509789330F41
298	390	\N	\N	\N	170 120 84	0106000020E6100000010000000103000000010000000600000056E05A0DEC483341786EB90CFD011041E269219A004933417C9D1DB911F00F4116C0905D2247334100341B5C51EF0F416E248F1FA2463341869C7FAA97001041D76113AB49463341BCF9F7BB2902104156E05A0DEC483341786EB90CFD011041
301	393	\N	\N	\N	172 61 87	0106000020E61000000100000001030000000100000005000000836EF33FFD513341594A60AF70ED0F414D47EBF90452334118C3CBC80A011041EA9B6446A75233413CC64026FE00104101275DEAA052334163D965CD4EED0F41836EF33FFD513341594A60AF70ED0F41
111	213	\N	\N	\N	185 135 250	0106000020E610000001000000010300000001000000050000001E10569B224D33418BDAB98A8B270F4136FB3259B34F3341C000911525270F41A3404CC2B04F33411E600C8DE6220F4121D512D61F4D3341B5124C7149230F411E10569B224D33418BDAB98A8B270F41
299	391	\N	\N	\N	171 15 85	0106000020E61000000100000001030000000100000009000000ACD65E095A4733414C7AFA63AAC70F41B8DCAB6D9647334140D2F8FFCBC70F41B8DCAB6D9647334140D2F8FFCBC70F412440429A984733410D98B935CDC70F41C9D59BC9544733410BD0DD26BFC10F411B052782E24733410F19FF73F4BC0F412892C784A8463341C80613BE5BB50F4133C296138246334140373D3432C70F41ACD65E095A4733414C7AFA63AAC70F41
302	394	\N	\N	\N	172 212 88	0106000020E610000001000000010300000001000000050000007CD1562AEA533341F9F5C2A30AED0F417B43F53AF3533341E81B8A18D7001041B0A1AAAF935433410B4DFC37C4001041883715348D5433410EB10BE3E8EC0F417CD1562AEA533341F9F5C2A30AED0F41
112	214	\N	\N	\N	186 30 252	0106000020E610000001000000010300000001000000050000002E908654934A334182BD5FC5F1270F411E10569B224D33418BDAB98A8B270F4121D512D61F4D3341B5124C7149230F41D28312D4904A3341DABBBF0BAC230F412E908654934A334182BD5FC5F1270F41
300	392	\N	\N	\N	171 166 86	0106000020E61000000100000001030000000100000009000000E269219A004933417C9D1DB911F00F41D33E7953E2493341C1C35D1449EF0F4157A3D715DF4933415AE0CE25B2EB0F4122BBC01B05493341349BE41C10E80F41454220B7C3483341EAB6761509E50F41A35B623CC3483341D332B72473DB0F4118D9FF138C4733418E2BC66CA7DB0F4116C0905D2247334100341B5C51EF0F41E269219A004933417C9D1DB911F00F41
303	395	\N	\N	\N	173 107 90	0106000020E6100000010000000103000000010000000600000033FBEA8F764A33416597D420DC0110411BAC34AF6A4A33416F75C20302EF0F411B08A525214A33412C661A3D11EF0F41D33E7953E2493341C1C35D1449EF0F41F5200DE2F4493341483B8780EB01104133FBEA8F764A33416597D420DC011041
113	215	\N	\N	\N	186 181 253	0106000020E61000000100000001030000000100000005000000325065CBFE473341AE5C0FD258280F412E908654934A334182BD5FC5F1270F41D28312D4904A3341DABBBF0BAC230F416434C275FC4733412212C9740F240F41325065CBFE473341AE5C0FD258280F41
304	396	\N	\N	\N	174 2 91	0106000020E6100000010000000103000000010000000500000027A9F2BC73493341E68E260FF40110412D81576271493341C788ED78ADEF0F41E269219A004933417C9D1DB911F00F4156E05A0DEC483341786EB90CFD01104127A9F2BC73493341E68E260FF4011041
114	216	\N	\N	\N	187 76 254	0106000020E61000000100000001030000000100000005000000577EB64567453341AEF20556C0280F41325065CBFE473341AE5C0FD258280F416434C275FC4733412212C9740F240F419D1AE5F1634533414008A07D73240F41577EB64567453341AEF20556C0280F41
351	443	\N	\N	\N	201 187 146	0106000020E61000000100000001030000000100000005000000974E397C934B3341D8F1DC91C4EE0F418ADF79DC994B3341ECC30C98B901104144B2F7083F4C33414A9B1B03A6011041815A16F1344C3341FF94F724A3EE0F41974E397C934B3341D8F1DC91C4EE0F41
161	263	\N	\N	\N	215 6 53	0106000020E610000001000000010300000001000000050000000623C4874F543341DFA8A7E5C7470F418E29937D5F543341EA1486C25A5C0F418C98F9E7FF543341F3FBFBFC3A5C0F41BAC51172F7543341272F3C43A5470F410623C4874F543341DFA8A7E5C7470F41
305	397	\N	\N	\N	174 153 92	0106000020E61000000100000001030000000100000009000000E9734EB7F04A33417A8B5444E6EE0F417E4BE204E64A334105BAE51BB5DA0F41A35B623CC3483341D332B72473DB0F41454220B7C3483341EAB6761509E50F4122BBC01B05493341349BE41C10E80F4157A3D715DF4933415AE0CE25B2EB0F41D33E7953E2493341C1C35D1449EF0F411B08A525214A33412C661A3D11EF0F41E9734EB7F04A33417A8B5444E6EE0F41
115	217	\N	\N	\N	187 227 255	0106000020E6100000010000000103000000010000000500000060D1FF3980573341ADD79A8DED250F410D617A9F0F5A33417D1E2C4E87250F4112DBB6540D5A3341A461333D57210F415F13FA657D573341674B4AFBB9210F4160D1FF3980573341ADD79A8DED250F41
352	444	\N	\N	\N	202 82 147	0106000020E610000001000000010300000001000000050000008792833B8C4B33418408DB246FDA0F41D48EEC7B934B33418686E898C3EE0F41041E24F0344C334107C52335A1EE0F412EDFC4042B4C334124282F6E53DA0F418792833B8C4B33418408DB246FDA0F41
162	264	\N	\N	\N	215 157 54	0106000020E610000001000000010300000001000000060000002ADF23836F543341412F10EF01710F411CCF445A7F543341D27C853F6D850F413EBD72EB0F553341B6BFC2B14F850F41F64BAD1E0C5533418534BCC5FE7A0F414F603B6608553341F7717508E5700F412ADF23836F543341412F10EF01710F41
306	398	\N	\N	\N	175 48 93	0106000020E61000000100000001030000000100000005000000C7549482C74E33413F2210CE1AEE0F4117827C76D04E3341B7B98012580110410BC2B2D9704F33416230D20E4501104148E287F9674F33416BA4BB95F9ED0F41C7549482C74E33413F2210CE1AEE0F41
116	218	\N	\N	\N	188 123 0	0106000020E61000000100000001030000000100000005000000C4228C926F57334108B169FB2F0D0F41A07F1714025A334134AB091AC80C0F4144EDEAA0FF5933411CF8CC334E080F41AA5EDF936C5733413392570CBD080F41C4228C926F57334108B169FB2F0D0F41
353	445	\N	\N	\N	202 233 149	0106000020E610000001000000010300000001000000050000001BAC34AF6A4A33416F75C20302EF0F4133FBEA8F764A33416597D420DC01104153092AD1F24A3341EEE1C165CD011041E9734EB7F04A33417A8B5444E6EE0F411BAC34AF6A4A33416F75C20302EF0F41
163	265	\N	\N	\N	216 52 56	0106000020E61000000100000001030000000100000005000000C4228C926F57334108B169FB2F0D0F41CA60363DD7543341C2CA1EC8980D0F41461C69F7D9543341C52EC3A18E110F41BD5BC73972573341D48EA30321110F41C4228C926F57334108B169FB2F0D0F41
307	399	\N	\N	\N	175 199 94	0106000020E61000000100000001030000000100000005000000A71FB8D42757334170DD92EE52E80F410122DBB42257334187DF50C6BBD70F416BA8D5797F563341B1D73A1DDAD70F410636B08080563341E671BD3358E80F41A71FB8D42757334170DD92EE52E80F41
117	219	\N	\N	\N	189 18 1	0106000020E6100000010000000103000000010000000600000043A86F2754453341704B083A0B100F41D8A48D55F1473341B1F196A9A10F0F41ABACC3FFEE4733414DBCF504580B0F41C8BD1E5E4C4533411025587CC90B0F41CFA02A3651453341B66D75BD3D0C0F4143A86F2754453341704B083A0B100F41
31	133	\N	\N	\N	138 87 156	0106000020E610000001000000010300000001000000050000009638123EBB5733412F6391F778B20F4114533EBC205533410187768AF6B20F413B2443412255334166598AAA16B70F41194825DEBC57334190E70E3A95B60F419638123EBB5733412F6391F778B20F41
354	446	\N	\N	\N	203 128 150	0106000020E610000001000000010300000001000000050000002D81576271493341C788ED78ADEF0F4127A9F2BC73493341E68E260FF4011041F5200DE2F4493341483B8780EB011041D33E7953E2493341C1C35D1449EF0F412D81576271493341C788ED78ADEF0F41
164	266	\N	\N	\N	216 203 57	0106000020E61000000100000001030000000100000005000000CA60363DD7543341C2CA1EC8980D0F411D489CFF4B523341C2241684FF0D0F4122F238444D523341EC0E8E57FA110F41461C69F7D9543341C52EC3A18E110F41CA60363DD7543341C2CA1EC8980D0F41
308	400	\N	\N	\N	176 94 96	0106000020E610000001000000010300000001000000050000000332FD82B6593341AF94875581D70F41869683B8BA5933418242F32D3EE80F41DA46A238665A3341DAAF24C738E80F41BCF154FE5E5A3341B1E02BFC77D70F410332FD82B6593341AF94875581D70F41
118	220	\N	\N	\N	189 169 3	0106000020E61000000100000001030000000100000005000000D8A48D55F1473341B1F196A9A10F0F413083F2DA844A33415A0C399F390F0F411CF02F54824A334145D86920E90A0F41ABACC3FFEE4733414DBCF504580B0F41D8A48D55F1473341B1F196A9A10F0F41
32	134	\N	\N	\N	138 238 157	0106000020E61000000100000001030000000100000005000000FF91A3CBF04F33419D7EA4016BC40F415FC652009A4D334177C99FEDDEC40F4183156A0F9B4D334124C20BB534C90F41CD195C67F24F33417FA46707C0C80F41FF91A3CBF04F33419D7EA4016BC40F41
355	447	\N	\N	\N	204 23 151	0106000020E610000001000000010300000001000000070000002C365CA3575133410A3B7DF892ED0F412F65FB0C55513341647B6F88DFD80F4157BE077CAB503341087F7B0602D90F4157BE077CAB503341087F7B0602D90F4157BE077CAB503341087F7B0602D90F41C4A15BE4B65033413349BC3FB4ED0F412C365CA3575133410A3B7DF892ED0F41
165	267	\N	\N	\N	217 98 58	0106000020E610000001000000010300000001000000050000001D489CFF4B523341C2241684FF0D0F41D2490443A44F33410768D9BE6A0E0F4157BB81B3A64F334196430C526A120F4122F238444D523341EC0E8E57FA110F411D489CFF4B523341C2241684FF0D0F41
309	401	\N	\N	\N	176 245 97	0106000020E61000000100000001030000000100000005000000912D1B6B78583341F4E550B44CF90F4103FE711C735833416ED6767F48E80F41B3491432CD57334106513DB94DE80F413DEC2954D0573341736A3A0257F90F41912D1B6B78583341F4E550B44CF90F41
119	221	\N	\N	\N	190 64 4	0106000020E610000001000000010300000001000000050000003083F2DA844A33415A0C399F390F0F4121D16885124D33416FA05081D20E0F41B58E5FB20F4D3341EBA2903C7B0A0F411CF02F54824A334145D86920E90A0F413083F2DA844A33415A0C399F390F0F41
33	135	\N	\N	\N	139 133 159	0106000020E6100000010000000103000000010000000500000011CB006E625433417039C75E2EBB0F4180DEE0678D523341FE680D72B5BB0F4162BF9D7C905233417A760E15D2BF0F4156345A8B77543341C99C6F296BBF0F4111CB006E625433417039C75E2EBB0F41
356	448	\N	\N	\N	204 174 152	0106000020E610000001000000010300000001000000050000002F65FB0C55513341647B6F88DFD80F412C365CA3575133410A3B7DF892ED0F41836EF33FFD513341594A60AF70ED0F414EEE2381F5513341F4BCF5DCBED80F412F65FB0C55513341647B6F88DFD80F41
166	268	\N	\N	\N	217 249 59	0106000020E61000000100000001030000000100000005000000D2490443A44F33410768D9BE6A0E0F4121D16885124D33416FA05081D20E0F41A5447B22154D33412F736ED5D6120F4157BB81B3A64F334196430C526A120F41D2490443A44F33410768D9BE6A0E0F41
310	402	\N	\N	\N	177 140 98	0106000020E6100000010000000103000000010000000500000003FE711C735833416ED6767F48E80F4150A082E66D583341B6D1989193D70F41980C3820CA573341743C16A89CD70F41B3491432CD57334106513DB94DE80F4103FE711C735833416ED6767F48E80F41
120	222	\N	\N	\N	190 215 5	0106000020E6100000010000000103000000010000000500000021D16885124D33416FA05081D20E0F41D2490443A44F33410768D9BE6A0E0F411DACD198A14F3341F58092950C0A0F41B58E5FB20F4D3341EBA2903C7B0A0F4121D16885124D33416FA05081D20E0F41
81	183	\N	\N	\N	167 213 215	0106000020E6100000010000000103000000010000000500000008AF744E975733413181B9F996570F417D89C136FE54334187C572F31C580F418C98F9E7FF543341F3FBFBFC3A5C0F41B67C20F09857334141D0EE45B75B0F4108AF744E975733413181B9F996570F41
34	136	\N	\N	\N	140 28 160	0106000020E61000000100000001030000000100000005000000CE350556BE573341CC3BC350A1BA0F41E38085632255334138F9B22F1EBB0F41A12D3C45255533410EDDA27346BF0F41DDA94E16C05733416E4BDB8BB9BE0F41CE350556BE573341CC3BC350A1BA0F41
357	449	\N	\N	\N	205 69 153	0106000020E6100000010000000103000000010000000D0000007E4BE204E64A334105BAE51BB5DA0F418792833B8C4B33418408DB246FDA0F412EDFC4042B4C334124282F6E53DA0F418211BB56D34C33412CE0CF3026DA0F41A86B0B3C7B4D3341DA2CA410F9D90F4158A310B11B4E3341EA8E4AF0CDD90F41C153269BBE4E33416BC8DD26A2D90F4141F1621F5F4F33413F316D0277D90F414DB5688BFC4F3341ED1AE8BA42D90F41D2228514364F3341436464EC42D50F41B4551DDDDF4A33414D2CA4E34DD60F41B4551DDDDF4A33414D2CA4E34DD60F417E4BE204E64A334105BAE51BB5DA0F41
167	269	\N	\N	\N	218 144 60	0106000020E6100000010000000103000000010000000500000021D16885124D33416FA05081D20E0F413083F2DA844A33415A0C399F390F0F41A9E0E937874A33418CCB9BBE42130F41A5447B22154D33412F736ED5D6120F4121D16885124D33416FA05081D20E0F41
82	184	\N	\N	\N	168 108 216	0106000020E610000001000000010300000001000000050000009F9268AF265A3341BFABEDF412570F4108AF744E975733413181B9F996570F41B67C20F09857334141D0EE45B75B0F41A5489C7F285A3341C3631B6F355B0F419F9268AF265A3341BFABEDF412570F41
35	137	\N	\N	\N	140 179 161	0106000020E610000001000000010300000001000000050000004CFA0B4E2A5A33417BAB97E2535F0F41CFD7CB8D9A573341F07C4B73CD5F0F418554732F9C573341FA4E96B4ED630F41A7A0231F2C5A3341A4DD846478630F414CFA0B4E2A5A33417BAB97E2535F0F41
358	450	\N	\N	\N	205 220 154	0106000020E610000001000000010300000001000000070000003C5287A9EB4F33416E8AD352FFB30F41A71CFA43E94F33411792709A22B00F416B947E544D4F3341C96D2C0644B00F41FEB7CB99A84E33412414665467B00F41E9108059634D334173E1FF09ADB00F414A114F18654D3341938F844086B40F413C5287A9EB4F33416E8AD352FFB30F41
168	270	\N	\N	\N	219 39 61	0106000020E610000001000000010300000001000000050000003083F2DA844A33415A0C399F390F0F41D8A48D55F1473341B1F196A9A10F0F418642D48AF34733416D2E1D9BAF130F41A9E0E937874A33418CCB9BBE42130F413083F2DA844A33415A0C399F390F0F41
83	185	\N	\N	\N	169 3 217	0106000020E61000000100000001030000000100000005000000532F460894573341233CFC324F4F0F41059EC5CAFA543341C1B884A6C94F0F41164AC18FFC543341E33846C617540F413C3A71B295573341D68B69FC84530F41532F460894573341233CFC324F4F0F41
359	451	\N	\N	\N	206 115 156	0106000020E610000001000000010300000001000000080000003C04859FF04F3341CF1C61E0FDBB0F410E541A35EE4F334180B8F05019B80F41E09A4DF0664D33413F56DAFF96B80F419BCD4F63D34A334136C1491117B90F419380CE41D44A3341E53C931320BB0F417F5ED13C464B33415EA4662AB4BD0F413C04859FF04F3341BFA70D7E93BC0F413C04859FF04F3341CF1C61E0FDBB0F41
169	271	\N	\N	\N	219 190 63	0106000020E61000000100000001030000000100000005000000D8A48D55F1473341B1F196A9A10F0F4143A86F2754453341704B083A0B100F4199D7394E5745334112E644E11D140F418642D48AF34733416D2E1D9BAF130F41D8A48D55F1473341B1F196A9A10F0F41
84	186	\N	\N	\N	169 154 219	0106000020E610000001000000010300000001000000050000003A42C912235A3341FC260FA0D64E0F41532F460894573341233CFC324F4F0F413C3A71B295573341D68B69FC84530F41E85DECE0245A334176BCE964F4520F413A42C912235A3341FC260FA0D64E0F41
36	138	\N	\N	\N	141 74 162	0106000020E61000000100000001030000000100000007000000BD63123A99503341172833D7119B0F41741EDD9D9A5033411522A5FB17A30F41597A89DAE050334137C128FA7CA20F4130101E671D513341D2B612B6D2A00F41537F599F35513341048F928F2C9E0F4102D63C1337513341A43B2A6FF39A0F41BD63123A99503341172833D7119B0F41
360	452	\N	\N	\N	207 10 157	0106000020E610000001000000010300000001000000050000000E541A35EE4F334180B8F05019B80F413C5287A9EB4F33416E8AD352FFB30F414A114F18654D3341938F844086B40F41E09A4DF0664D33413F56DAFF96B80F410E541A35EE4F334180B8F05019B80F41
170	272	\N	\N	\N	220 85 64	0106000020E61000000100000001030000000100000005000000A07F1714025A334134AB091AC80C0F41C4228C926F57334108B169FB2F0D0F41BD5BC73972573341D48EA30321110F41D1E6C739045A33416612F16DB4100F41A07F1714025A334134AB091AC80C0F41
85	187	\N	\N	\N	170 49 220	0106000020E61000000100000001030000000100000005000000869683B8BA5933418242F32D3EE80F414E768BFDBE593341282643AF38F90F41B6748C896D5A3341555503FC2DF90F41DA46A238665A3341DAAF24C738E80F41869683B8BA5933418242F32D3EE80F41
37	139	\N	\N	\N	141 225 163	0106000020E61000000100000001030000000100000005000000CFD7CB8D9A573341F07C4B73CD5F0F41FEBC7E9201553341CF3911BA48600F4121CCD54203553341ECC42BA064640F418554732F9C573341FA4E96B4ED630F41CFD7CB8D9A573341F07C4B73CD5F0F41
411	515	\N	\N	\N	244 51 231	0106000020E61000000100000001030000000100000005000000CD72EEF40D55334184A69C70FB7F0F4111DCF106A75733418B42DEFA587F0F410C2C1D1AA557334154D01E9A7A7A0F41F64BAD1E0C5533418534BCC5FE7A0F41CD72EEF40D55334184A69C70FB7F0F41
86	188	\N	\N	\N	170 200 221	0106000020E6100000010000000103000000010000000500000015FD50192D573341C0BEDF0361F90F41A71FB8D42757334170DD92EE52E80F410636B08080563341E671BD3358E80F414D52D590815633419BB5D3876BF90F4115FD50192D573341C0BEDF0361F90F41
221	474	\N	\N	\N	220 4 183	0106000020E6100000010000000103000000010000000500000040C6C4056A4B33413E802480119C0F414B555B96734B33414BE40E4B17B10F41028C22F3194C3341456A3AA3F3B00F4128F8A0E30E4C33418A7D02BEF19B0F4140C6C4056A4B33413E802480119C0F41
38	140	\N	\N	\N	142 120 164	0106000020E6100000010000000103000000010000000500000016C6B78040533341642D044E6BAF0F41D94125B133533341749C8B75919A0F418E8A5988815233413BE92FC7B39A0F413339C9F089523341D11DAF6E92AF0F4116C6B78040533341642D044E6BAF0F41
412	516	\N	\N	\N	244 202 232	0106000020E6100000010000000103000000010000000600000011DCF106A75733418B42DEFA587F0F41CF9C4B26385A3341005FA082E57E0F41D9605686355A334193EA5F4EE9780F41F88BA39FA457334130F83DDC44790F410C2C1D1AA557334154D01E9A7A7A0F4111DCF106A75733418B42DEFA587F0F41
87	189	\N	\N	\N	171 95 222	0106000020E61000000100000001030000000100000005000000F5C9B014E1533341551EE4A25BD80F417CD1562AEA533341F9F5C2A30AED0F41883715348D5433410EB10BE3E8EC0F41A28BCFB386543341BEA3CD6B3AD80F41F5C9B014E1533341551EE4A25BD80F41
222	475	\N	\N	\N	220 155 184	0106000020E61000000100000001030000000100000005000000ECABC8A2444B334118A30A46E5490F419AA9F9D94D4B33413ADE6294265E0F41014366D6EF4B334180FA387F065E0F414818C75DF44B33419D8CFC68B7490F41ECABC8A2444B334118A30A46E5490F41
39	141	\N	\N	\N	143 15 166	0106000020E610000001000000010300000001000000050000003FA1D241AB4C33419EF3F99ED39B0F41AA7BF9B1B34C3341C06EA7AFD2B00F41E9108059634D334173E1FF09ADB00F4183BAA6D5594D3341386AF8FDB19B0F413FA1D241AB4C33419EF3F99ED39B0F41
413	517	\N	\N	\N	245 97 233	0106000020E61000000100000001030000000100000005000000CF9C4B26385A3341005FA082E57E0F4111DCF106A75733418B42DEFA587F0F413E40D92CA9573341F8BF58B2C7840F410155E97F3A5A3341413DFE5141840F41CF9C4B26385A3341005FA082E57E0F41
88	190	\N	\N	\N	171 246 223	0106000020E610000001000000010300000001000000050000004EEE2381F5513341F4BCF5DCBED80F41836EF33FFD513341594A60AF70ED0F4101275DEAA052334163D965CD4EED0F414D9578769B523341396E90129DD80F414EEE2381F5513341F4BCF5DCBED80F41
223	476	\N	\N	\N	221 50 185	0106000020E610000001000000010300000001000000050000009D542A783C4F334115B32C9780860F41A60350E0444F3341ADE40A67539B0F41C54A127FE14F33419D70923B359B0F419CDE49C3D94F33417F0D656F60860F419D542A783C4F334115B32C9780860F41
40	142	\N	\N	\N	143 166 167	0106000020E6100000010000000103000000010000000500000012A0CDE7A1473341209146FDCB9C0F41F15D3C63AA4733410BC171ECCDA80F41F550915B414833418BF46E3A38AC0F412C71989539483341F5E779C5AE9C0F4112A0CDE7A1473341209146FDCB9C0F41
414	518	\N	\N	\N	245 248 234	0106000020E6100000010000000103000000010000000500000086C6FD65415A3341FED2AC59FC930F41A55AA068AF573341B11774728B940F41467FC772B1573341D14C29FBB3990F4171B044B0435A334166451B2F35990F4186C6FD65415A3341FED2AC59FC930F41
89	191	\N	\N	\N	172 141 224	0106000020E61000000100000001030000000100000004000000057A514CF54F3341E8EA23E58BD00F41D2228514364F3341436464EC42D50F414DB5688BFC4F3341ED1AE8BA42D90F41057A514CF54F3341E8EA23E58BD00F41
224	477	\N	\N	\N	221 201 186	0106000020E610000001000000010300000001000000050000007879DA30344F3341C218521CFF710F419D542A783C4F334115B32C9780860F419CDE49C3D94F33417F0D656F60860F417E034A27D24F3341B5B71840E1710F417879DA30344F3341C218521CFF710F41
271	363	\N	\N	\N	154 139 52	0106000020E61000000100000001030000000100000005000000059EC5CAFA543341C1B884A6C94F0F41532F460894573341233CFC324F4F0F418356E55092573341A733EA00F84A0F415E705A04F95433414D5D9B08784B0F41059EC5CAFA543341C1B884A6C94F0F41
415	519	\N	\N	\N	246 143 236	0106000020E61000000100000001030000000100000005000000A55AA068AF573341B11774728B940F4142653ABD15553341AFE1CB361C950F41C26C8F9D17553341443EA33D349A0F41467FC772B1573341D14C29FBB3990F41A55AA068AF573341B11774728B940F41
90	192	\N	\N	\N	173 36 226	0106000020E61000000100000001030000000100000005000000C153269BBE4E33416BC8DD26A2D90F4114970680C74E334108DA0AEF14EE0F41564395F6674F3341A1A94DC1F2ED0F4141F1621F5F4F33413F316D0277D90F41C153269BBE4E33416BC8DD26A2D90F41
225	478	\N	\N	\N	222 96 187	0106000020E61000000100000001030000000100000005000000A60350E0444F3341ADE40A67539B0F416B947E544D4F3341C96D2C0644B00F41A71CFA43E94F33411792709A22B00F41C54A127FE14F33419D70923B359B0F41A60350E0444F3341ADE40A67539B0F41
272	364	\N	\N	\N	155 34 53	0106000020E61000000100000001030000000100000005000000532F460894573341233CFC324F4F0F413A42C912235A3341FC260FA0D64E0F41129C1329215A33415EF242FC794A0F418356E55092573341A733EA00F84A0F41532F460894573341233CFC324F4F0F41
416	520	\N	\N	\N	247 38 237	0106000020E61000000100000001030000000100000006000000CD72EEF40D55334184A69C70FB7F0F413EBD72EB0F553341B6BFC2B14F850F413E40D92CA9573341F8BF58B2C7840F4111DCF106A75733418B42DEFA587F0F4111DCF106A75733418B42DEFA587F0F41CD72EEF40D55334184A69C70FB7F0F41
226	479	\N	\N	\N	222 247 189	0106000020E61000000100000001030000000100000005000000807096DE2B4F3341A8D4967F625D0F417879DA30344F3341C218521CFF710F417E034A27D24F3341B5B71840E1710F41625BC97FCA4F3341DC2A9A14435D0F41807096DE2B4F3341A8D4967F625D0F41
273	365	\N	\N	\N	155 185 54	0106000020E610000001000000010300000001000000050000007D89C136FE54334187C572F31C580F4108AF744E975733413181B9F996570F413C3A71B295573341D68B69FC84530F41164AC18FFC543341E33846C617540F417D89C136FE54334187C572F31C580F41
417	521	\N	\N	\N	247 189 238	0106000020E610000001000000010300000001000000050000009638123EBB5733412F6391F778B20F4165B9855AB9593341F1A5B9D70DB20F41475B5C43B8593341BD952E6F08AE0F410C42F2A7B9573341C598BBDE75AE0F419638123EBB5733412F6391F778B20F41
227	480	\N	\N	\N	223 142 190	0106000020E61000000100000001030000000100000005000000C7F98431BF4F33413EF9CC00CF3E0F418BF93A941F4F33417E2CE00DF13E0F4152C4EE97234F3341263D52A5E2480F410628C5DFC24F33414F965313B9480F41C7F98431BF4F33413EF9CC00CF3E0F41
274	366	\N	\N	\N	156 80 56	0106000020E6100000010000000103000000010000000500000008AF744E975733413181B9F996570F419F9268AF265A3341BFABEDF412570F41E85DECE0245A334176BCE964F4520F413C3A71B295573341D68B69FC84530F4108AF744E975733413181B9F996570F41
418	522	\N	\N	\N	248 84 239	0106000020E61000000100000001030000000100000005000000B0356A79BA5933415BF843C22FB60F41A11AA558505A3341DECBF3EA11B60F41C32B5DC44C5A33415754329BE8AD0F41475B5C43B8593341BD952E6F08AE0F41B0356A79BA5933415BF843C22FB60F41
228	320	\N	\N	\N	129 46 1	0106000020E6100000010000000103000000010000000500000052C4EE97234F3341263D52A5E2480F41807096DE2B4F3341A8D4967F625D0F41625BC97FCA4F3341DC2A9A14435D0F410628C5DFC24F33414F965313B9480F4152C4EE97234F3341263D52A5E2480F41
275	367	\N	\N	\N	156 231 57	0106000020E61000000100000001030000000100000005000000CFD7CB8D9A573341F07C4B73CD5F0F414CFA0B4E2A5A33417BAB97E2535F0F41A5489C7F285A3341C3631B6F355B0F41B67C20F09857334141D0EE45B75B0F41CFD7CB8D9A573341F07C4B73CD5F0F41
419	523	\N	\N	\N	248 235 240	0106000020E61000000100000001030000000100000005000000194825DEBC57334190E70E3A95B60F41AF356A79BA5933415BF843C22FB60F4165B9855AB9593341F1A5B9D70DB20F419638123EBB5733412F6391F778B20F41194825DEBC57334190E70E3A95B60F41
229	321	\N	\N	\N	129 197 3	0106000020E61000000100000001030000000100000005000000BA9B659FF64B33416A1B2726993F0F41A7A5ADF32F4D3341786CAA0A583F0F41B6C2A7072B4D33417FD1E2B07D340F4187ED370BF94B33414F4A00A3BD340F41BA9B659FF64B33416A1B2726993F0F41
276	368	\N	\N	\N	157 126 58	0106000020E61000000100000001030000000100000005000000FEBC7E9201553341CF3911BA48600F41CFD7CB8D9A573341F07C4B73CD5F0F41B67C20F09857334141D0EE45B75B0F418C98F9E7FF543341F3FBFBFC3A5C0F41FEBC7E9201553341CF3911BA48600F41
420	524	\N	\N	\N	249 130 242	0106000020E610000001000000010300000001000000050000005D4DE7B2BC593341EF478BBF63BE0F416B8B81F3535A3341AE72BC3B4ABE0F41A11AA558505A3341DECBF3EA11B60F41B0356A79BA5933415BF843C22FB60F415D4DE7B2BC593341EF478BBF63BE0F41
230	322	\N	\N	\N	130 92 4	0106000020E61000000100000001030000000100000006000000683C4A8C744E3341715AD697143F0F418BF93A941F4F33417E2CE00DF13E0F41C7F98431BF4F33413EF9CC00CF3E0F410B26092ABB4F33411E720092F4330F41E73AF08F6F4E3341A7BF8DDE39340F41683C4A8C744E3341715AD697143F0F41
277	369	\N	\N	\N	158 21 59	0106000020E61000000100000001030000000100000005000000DA68F0F6045533410A3BA2AE89680F41F80047D59D5733418893578318680F418554732F9C573341FA4E96B4ED630F4121CCD54203553341ECC42BA064640F41DA68F0F6045533410A3BA2AE89680F41
278	370	\N	\N	\N	158 172 60	0106000020E61000000100000001030000000100000005000000F80047D59D5733418893578318680F4195E076F52D5A33411C2C03D5A8670F41A7A0231F2C5A3341A4DD846478630F418554732F9C573341FA4E96B4ED630F41F80047D59D5733418893578318680F41
279	371	\N	\N	\N	159 67 61	0106000020E610000001000000010300000001000000050000004F603B6608553341F7717508E5700F41635FA51DA1573341ABA500D265700F41033A3C6D9F5733416B8EF13E206C0F417FB6D2A306553341A348182C9D6C0F414F603B6608553341F7717508E5700F41
1	101	\N	\N	\N	119 119 119	0106000020E6100000010000000103000000010000000500000015D0DBCE2D4633412F69C28F1F5F0F4189780A61394633412E70D1A9B1730F41635777F0DD463341B972518E92730F4104356EDFD9463341514AA05C085F0F4115D0DBCE2D4633412F69C28F1F5F0F41
280	372	\N	\N	\N	159 218 63	0106000020E61000000100000001030000000100000005000000625FA51DA1573341ABA500D265700F41A1B56993315A334132C50D30E86F0F417C64D4B42F5A3341F6F00BEBA46B0F41033A3C6D9F5733416B8EF13E206C0F41625FA51DA1573341ABA500D265700F41
2	102	\N	\N	\N	120 14 120	0106000020E6100000010000000103000000010000000C000000FFD4D3A4634633410AA9CE66B1B10F41FFD4D3A4634633410AA9CE66B1B10F41FFD4D3A4634633410AA9CE66B1B10F4106FDF2261346334176B538A2BEB10F4123D45A39AC4933415B3C485607C80F4159F84B2BA649334109570265FDC00F410F02B157CF49334108FAB89B34BD0F419FB9CE73DB493341EEF4AD795FBC0F411237C9E270493341A1E58C13E0B90F412C4A1D81C2483341A06CB1511EB90F413B539638EA463341B25B42479BB10F41FFD4D3A4634633410AA9CE66B1B10F41
331	423	\N	\N	\N	189 239 123	0106000020E610000001000000010300000001000000050000006F8595BE4D533341745F9590EA001041101C5394485333413A4485172CED0F4101275DEAA052334163D965CD4EED0F41EA9B6446A75233413CC64026FE0010416F8595BE4D533341745F9590EA001041
141	243	\N	\N	\N	203 58 30	0106000020E6100000010000000103000000010000000500000068B8D98C8F54334161387A734E9A0F411CCF445A7F543341D27C853F6D850F411E3CB67FD55333415953A1F88F850F4108535E8AE253334141002CC76F9A0F4168B8D98C8F54334161387A734E9A0F41
3	103	\N	\N	\N	120 165 121	0106000020E610000001000000010300000001000000050000004F047D56875033417D2FCEE6C9330F41C1186CEF8A503341243D1EDB8E480F411456777419513341026AA87571480F417329A98C11513341E32C8C04AD330F414F047D56875033417D2FCEE6C9330F41
332	424	\N	\N	\N	190 134 124	0106000020E61000000100000001030000000100000005000000101C5394485333413A4485172CED0F41C4B71D6843533341B614F4417BD80F41D33D7BCB9A523341396E90129DD80F4101275DEAA052334163D965CD4EED0F41101C5394485333413A4485172CED0F41
142	244	\N	\N	\N	203 209 31	0106000020E610000001000000010300000001000000050000002ADF23836F543341412F10EF01710F418E29937D5F543341EA1486C25A5C0F417F9F1ED5BB533341F563762C7B5C0F41F1E5D6BBC85333418525E97521710F412ADF23836F543341412F10EF01710F41
4	104	\N	\N	\N	121 60 122	0106000020E61000000100000001030000000100000005000000885A482EF54D3341AD27346C3ECD0F418B950F41DC4A3341A2F03D10DACD0F4117AA42DCDD4A33412DA6A7F49CD10F410D3F41F4934E334100F604EBD5D00F41885A482EF54D3341AD27346C3ECD0F41
333	425	\N	\N	\N	191 29 125	0106000020E61000000100000001030000000100000005000000101C5394485333413A4485172CED0F416F8595BE4D533341745F9590EA0010417B43F53AF3533341E81B8A18D70010417CD1562AEA533341F9F5C2A30AED0F41101C5394485333413A4485172CED0F41
143	245	\N	\N	\N	204 104 32	0106000020E610000001000000010300000001000000050000008E29937D5F543341EA1486C25A5C0F410623C4874F543341DFA8A7E5C7470F41A343F9FAAE533341049C2A03E9470F417F9F1ED5BB533341F563762C7B5C0F418E29937D5F543341EA1486C25A5C0F41
5	105	\N	\N	\N	121 211 123	0106000020E610000001000000010300000001000000090000001B052782E24733410F19FF73F4BC0F41C9D59BC9544733410BD0DD26BFC10F412440429A984733410D98B935CDC70F41FA31BEC09B4833412965A066B0CE0F41A35B623CC3483341D332B72473DB0F417E4BE204E64A334105BAE51BB5DA0F4100065A96D94A33419113D2629BC70F4123D45A39AC4933415B3C485607C80F411B052782E24733410F19FF73F4BC0F41
11	112	\N	\N	\N	125 244 131	0106000020E6100000010000000103000000010000000B000000730D219BE74633417D7425E565A40F413B539638EA463341B25B42479BB10F412C4A1D81C2483341A06CB1511EB90F411237C9E270493341A1E58C13E0B90F419FB9CE73DB493341EEF4AD795FBC0F410F02B157CF49334108FAB89B34BD0F4159F84B2BA649334109570265FDC00F4123D45A39AC4933415B3C485607C80F4100065A96D94A33419113D2629BC70F419380CE41D44A3341E53C931320BB0F41730D219BE74633417D7425E565A40F41
334	426	\N	\N	\N	191 180 126	0106000020E61000000100000001030000000100000005000000C4B71D6843533341B614F4417BD80F41101C5394485333413A4485172CED0F417CD1562AEA533341F9F5C2A30AED0F41F5C9B014E1533341551EE4A25BD80F41C4B71D6843533341B614F4417BD80F41
144	246	\N	\N	\N	204 255 33	0106000020E61000000100000001030000000100000005000000897D26DF26533341196E8DABB3850F416555D94F1A5333419A6EA36E42710F41C2E1FBE2705233414680917562710F41F6CCBE207952334170E23D30D7850F41897D26DF26533341196E8DABB3850F41
6	106	\N	\N	\N	122 106 124	0106000020E61000000100000001030000000100000005000000A55C6032B3453341B63FD73506C30F410C202E328B4633413DF917EBF6C20F412892C784A8463341C80613BE5BB50F41D0272EF8A945334178BEF92D33AF0F41A55C6032B3453341B63FD73506C30F41
381	483	\N	\N	\N	225 83 193	0106000020E610000001000000010300000001000000050000006555D94F1A5333419A6EA36E42710F41897D26DF26533341196E8DABB3850F411E3CB67FD55333415953A1F88F850F41F1E5D6BBC85333418525E97521710F416555D94F1A5333419A6EA36E42710F41
191	293	\N	\N	\N	232 184 89	0106000020E610000001000000010300000001000000050000001E10569B224D33418BDAB98A8B270F412E908654934A334182BD5FC5F1270F41780D5BB3954A33413DDD8F13FE2B0F41493BBB3F254D3341C23B2F209B2B0F411E10569B224D33418BDAB98A8B270F41
12	113	\N	\N	\N	126 139 133	0106000020E61000000100000001030000000100000005000000FB442EAA73453341F867389A873A0F41B126C02A08483341B1282AE5E8390F4180696BFE054833412F69B6ED90350F411220FA9A71453341601B31F01A360F41FB442EAA73453341F867389A873A0F41
335	427	\N	\N	\N	192 75 127	0106000020E61000000100000001030000000100000005000000C4A15BE4B65033413349BC3FB4ED0F41202DAD62C150334175C8D1F9230110412003015E5F51334107E24FAD170110412C365CA3575133410A3B7DF892ED0F41C4A15BE4B65033413349BC3FB4ED0F41
145	247	\N	\N	\N	205 150 34	0106000020E610000001000000010300000001000000050000001CCF445A7F543341D27C853F6D850F412ADF23836F543341412F10EF01710F41F1E5D6BBC85333418525E97521710F411E3CB67FD55333415953A1F88F850F411CCF445A7F543341D27C853F6D850F41
7	108	\N	\N	\N	123 152 127	0106000020E61000000100000001030000000100000006000000A376EDF31B46334168476EEBC4DB0F41929E0E0E7E46334107882B4173CF0F41058D432B60463341F6C51C684BCF0F4192276DECB7453341D63853ED2DCD0F410225CA5FC645334179640977E5DB0F41A376EDF31B46334168476EEBC4DB0F41
382	484	\N	\N	\N	225 234 194	0106000020E61000000100000001030000000100000005000000589BC64DAC533341A2BD554BA0430F414F2550815E5233419FBCDD4FC2430F41398A434960523341F45B010C2E480F41A343F9FAAE533341049C2A03E9470F41589BC64DAC533341A2BD554BA0430F41
192	294	\N	\N	\N	233 79 90	0106000020E610000001000000010300000001000000050000002E908654934A334182BD5FC5F1270F41325065CBFE473341AE5C0FD258280F41BEAEF8FD004833417B4256CE612C0F41780D5BB3954A33413DDD8F13FE2B0F412E908654934A334182BD5FC5F1270F41
13	114	\N	\N	\N	127 34 134	0106000020E61000000100000001030000000100000005000000D21ABC7E8E503341BF260A431C5D0F416A1564119250334196F1DAF8BC710F414524D821295133417F0E766AA0710F4175D17147215133415084A930FF5C0F41D21ABC7E8E503341BF260A431C5D0F41
336	428	\N	\N	\N	192 226 129	0106000020E610000001000000010300000001000000050000002C365CA3575133410A3B7DF892ED0F412003015E5F51334107E24FAD170110414D47EBF90452334118C3CBC80A011041836EF33FFD513341594A60AF70ED0F412C365CA3575133410A3B7DF892ED0F41
146	248	\N	\N	\N	206 45 36	0106000020E6100000010000000103000000010000000500000089780A61394633412E70D1A9B1730F418AE565FD44463341913893DA55880F41B5A07306E246334188404DC035880F41635777F0DD463341B972518E92730F4189780A61394633412E70D1A9B1730F41
8	109	\N	\N	\N	124 47 128	0106000020E61000000100000001030000000100000008000000929E0E0E7E46334107882B4173CF0F41A376EDF31B46334168476EEBC4DB0F41E85464644C4633418AB6A923DDDB0F41173667B36E46334193AC3A4358DA0F41B86190CCE7463341F8141DB597D40F414FFCB9C0F846334177ED9C8EF1D10F418C2C3DE4C5463341A99A6909D3CF0F41929E0E0E7E46334107882B4173CF0F41
383	485	\N	\N	\N	226 129 196	0106000020E610000001000000010300000001000000050000006242EBCDA9533341311A0026A03F0F41612FFFF35C5233415371C41DE83F0F414F2550815E5233419FBCDD4FC2430F41589BC64DAC533341A2BD554BA0430F416242EBCDA9533341311A0026A03F0F41
193	295	\N	\N	\N	233 230 91	0106000020E61000000100000001030000000100000005000000325065CBFE473341AE5C0FD258280F41577EB64567453341AEF20556C0280F415F7150626A453341A1F982D2C52C0F41BEAEF8FD004833417B4256CE612C0F41325065CBFE473341AE5C0FD258280F41
337	429	\N	\N	\N	193 121 130	0106000020E61000000100000001030000000100000005000000202DAD62C150334175C8D1F923011041C4A15BE4B65033413349BC3FB4ED0F41FF17B263215033412FA41833D3ED0F41E25F21F3195033410196BD0231011041202DAD62C150334175C8D1F923011041
147	249	\N	\N	\N	206 196 37	0106000020E610000001000000010300000001000000050000006A1564119250334196F1DAF8BC710F41454EDF9D95503341FB3145083A860F414FDA42ED30513341744449481A860F414524D821295133417F0E766AA0710F416A1564119250334196F1DAF8BC710F41
9	110	\N	\N	\N	124 198 129	0106000020E6100000010000000103000000010000001000000018D9FF138C4733418E2BC66CA7DB0F414828D2939247334104892DEF71DA0F4165F793D9224833411E101FC1EFD50F41B8DCAB6D9647334140D2F8FFCBC70F41ACD65E095A4733414C7AFA63AAC70F4133C296138246334140373D3432C70F410C202E328B4633413DF917EBF6C20F41A55C6032B3453341B63FD73506C30F4192276DECB7453341D63853ED2DCD0F41058D432B60463341F6C51C684BCF0F418C2C3DE4C5463341A99A6909D3CF0F414FFCB9C0F846334177ED9C8EF1D10F41B86190CCE7463341F8141DB597D40F41173667B36E46334193AC3A4358DA0F41E85464644C4633418AB6A923DDDB0F4118D9FF138C4733418E2BC66CA7DB0F41
61	163	\N	\N	\N	156 9 192	0106000020E61000000100000001030000000100000005000000A60350E0444F3341ADE40A67539B0F419D542A783C4F334115B32C9780860F41701A5E6A954E3341ECBBC1BDA2860F41A276F6F99E4E334134C91F5C739B0F41A60350E0444F3341ADE40A67539B0F41
384	486	\N	\N	\N	227 24 197	0106000020E61000000100000001030000000100000005000000EEA14664A75333410A49C08EC33B0F41A43F296F5B523341DBF375F8223C0F41612FFFF35C5233415371C41DE83F0F416242EBCDA9533341311A0026A03F0F41EEA14664A75333410A49C08EC33B0F41
194	296	\N	\N	\N	234 125 92	0106000020E610000001000000010300000001000000050000000D617A9F0F5A33417D1E2C4E87250F4160D1FF3980573341ADD79A8DED250F411619D5FE825733411C1F6A8F0A2A0F419569ABE1115A33412FB7A0B5A7290F410D617A9F0F5A33417D1E2C4E87250F41
14	115	\N	\N	\N	127 185 135	0106000020E61000000100000001030000000100000005000000374E923076473341B4AFE666E95E0F41784592B284473341BBE8730873730F416C5146E52448334101020DC054730F416F3EAC9D1A4833411BD903D6C85E0F41374E923076473341B4AFE666E95E0F41
338	430	\N	\N	\N	194 16 131	0106000020E61000000100000001030000000100000006000000C4A15BE4B65033413349BC3FB4ED0F4157BE077CAB503341087F7B0602D90F4157BE077CAB503341087F7B0602D90F414DB5688BFC4F3341ED1AE8BA42D90F41FF17B263215033412FA41833D3ED0F41C4A15BE4B65033413349BC3FB4ED0F41
148	250	\N	\N	\N	207 91 38	0106000020E610000001000000010300000001000000050000006092CEA49A4C3341EFF2E0EB7C720F4140929BE6A24C33416DA3F9A608870F4114ADC566504D3341BF79022FE5860F417B68B516474D3341A59ED1525C720F416092CEA49A4C3341EFF2E0EB7C720F41
10	111	\N	\N	\N	125 93 130	0106000020E6100000010000000103000000010000000500000085B30C5F574633416DF0B99822A10F41FFD4D3A4634633410AA9CE66B1B10F413B539638EA463341B25B42479BB10F41730D219BE74633417D7425E565A40F4185B30C5F574633416DF0B99822A10F41
62	164	\N	\N	\N	156 160 193	0106000020E610000001000000010300000001000000050000000A698027064E3341E21F5F258AB00F410462C8DDFC4D33413D515296929B0F4183BAA6D5594D3341386AF8FDB19B0F41E9108059634D334173E1FF09ADB00F410A698027064E3341E21F5F258AB00F41
385	488	\N	\N	\N	228 70 199	0106000020E61000000100000001030000000100000005000000AA7BF9B1B34C3341C06EA7AFD2B00F413FA1D241AB4C33419EF3F99ED39B0F4128F8A0E30E4C33418A7D02BEF19B0F41028C22F3194C3341456A3AA3F3B00F41AA7BF9B1B34C3341C06EA7AFD2B00F41
195	297	\N	\N	\N	235 20 93	0106000020E61000000100000001030000000100000005000000422EDAEB8557334152064544632E0F412F983339145A3341FB13B61AEF2D0F419569ABE1115A33412FB7A0B5A7290F411619D5FE825733411C1F6A8F0A2A0F41422EDAEB8557334152064544632E0F41
\.


--
-- Name: half_blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('half_blocks_id_seq', 429, false);


--
-- Data for Name: map_layers; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY map_layers (id, name, description, layer_mapfile_text, created_at, updated_at, draw_order) FROM stdin;
6	Zoning	Zoning Areas	  \r\n\r\n  LAYER\r\n\r\n    NAME 'zoning2'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'zoning2.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n        "wms_title" "zoning2"\r\n\r\n        'wms_srs'   "epsg:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 20\r\n\r\n    PROJECTION\r\n\r\n    "init=epsg:4326"\r\n\r\n    END\r\n\r\n    CLASSITEM 'ZONELUT'\r\n\r\n    CLASS\r\n\r\n      NAME 'default'\r\n\r\n      EXPRESSION '' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 153 185 218\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = C1' \r\n\r\n      EXPRESSION 'C1' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 0 59\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = C2' \r\n\r\n      EXPRESSION 'C2' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 250 5 30\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L1' \r\n\r\n      EXPRESSION 'L1' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 229 78\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L1/RC' \r\n\r\n      EXPRESSION 'L1/RC' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 85 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L2' \r\n\r\n      EXPRESSION 'L2' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 246 103 56\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L2/RC' \r\n\r\n      EXPRESSION 'L2/RC' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 85 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L3' \r\n\r\n      EXPRESSION 'L3' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 85 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = L3/RC' \r\n\r\n      EXPRESSION 'L3/RC' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 85 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = LDT' \r\n\r\n      EXPRESSION 'LDT' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 2 181 26\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = MIO' \r\n\r\n      EXPRESSION 'MIO' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 159 221 126\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = MR' \r\n\r\n      EXPRESSION 'MR' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 191 127 97\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = NC1' \r\n\r\n      EXPRESSION 'NC1' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 0 255\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = NC2' \r\n\r\n      EXPRESSION 'NC2' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 218 8 255\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'ZONELUT = NC3' \r\n\r\n      EXPRESSION 'NC3' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 96 34 190\r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n  END	2011-09-24 02:05:56.507679	2011-09-27 07:05:23.844199	13
8	Parcels	Parcel Fill Color	\nLAYER\n\n  NAME 'Parcel_Clip'\n\n  TYPE POLYGON\n\n  DUMP true\n\n  TEMPLATE fooOnlyForWMSGetFeatureInfo\n\n  EXTENT 1259300 254000 1269500 262500\n\n  DATA 'Parcel_Clip.shp|layerid=0'\n\n  METADATA\n\n    'ows_title' 'Parcel_Clip'\n\n    'wms_title' 'Parcel_Clip'\n\n    'wms_srs'    "EPSG:4326"\n\n    'OWS_INCLUDE_ITEMS' "all"\n\n  END\n\n  STATUS on\n\n  TRANSPARENCY 36\n\n  PROJECTION\n\n  "init=epsg:4326"\n\n  END\n\n\n\n  CLASS\n\n     NAME 'Parcel_Clip' \n\n     STYLE\n\n       SYMBOL 0 \n\n       SIZE 7.0\n\n\n\n       COLOR 200 200 200\n\n     END\n\n  END\n\nEND\n	2011-09-24 02:08:44.454233	2011-09-27 06:58:44.56535	10
7	Parks	Park Areas (green)	  LAYER\r\n\r\n    NAME 'park'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'park.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'park'\r\n\r\n      'wms_title' 'park'\r\n\r\n      'wms_srs'    "EPSG:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 18\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'park' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0 \r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR  0 255 0 \r\n\r\n       END\r\n\r\n    END\r\n\r\n  END\r\n\r\n	2011-09-24 02:06:54.222901	2011-09-27 06:59:42.531633	15
9	Parcel Outlines	Parcel Outlines - near/far	  LAYER\r\n\r\n    NAME 'Parcel_Clip_Outline'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'Parcel_Clip.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'Parcel_Clip_Outline'\r\n\r\n      'wms_title' 'Parcel_Clip'\r\n\r\n      'wms_srs'    "EPSG:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n   TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    "init=epsg:4326"\r\n\r\n    END\r\n\r\n\r\n\r\n    \r\n\r\n    CLASS\r\n\r\n      NAME 'Parcel_Clip_Outline_Thick' \r\n\r\n      MAXSCALEDENOM 500000000\r\n\r\n\r\n\r\n      STYLE\r\n\r\n         #SYMBOL "dash-long"\r\n\r\n         SYMBOL 0\r\n\r\n         SIZE 7.0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         OPACITY 30\r\n\r\n         WIDTH 3\r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n    CLASS\r\n\r\n       NAME 'Parcel_Clip_Outline_Thin' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         OPACITY 30\r\n\r\n         WIDTH 1\r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n  END	2011-09-24 02:09:53.849815	2011-09-27 18:13:38.941374	49
10	Permeability	Permeability high = green	  LAYER\r\n\r\n    NAME 'infiltration_p'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'infiltration_p'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'infiltration_p'\r\n\r\n      'wms_title' 'infiltration_p'\r\n\r\n      'wms_srs'    "EPSG:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 50\r\n\r\n    PROJECTION\r\n\r\n    "init=epsg:4326"\r\n\r\n    END\r\n\r\n\r\n\r\n    \r\n\r\n    CLASSITEM 'PERM'\r\n\r\n\r\n\r\n    CLASS\r\n\r\n      NAME 'PERM = HIGH' \r\n\r\n      EXPRESSION 'High' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 50 255 50\r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n    CLASS\r\n\r\n      NAME 'PERM = Medium' \r\n\r\n      EXPRESSION 'Medium' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 250 250 00\r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n    CLASS\r\n\r\n      NAME 'PERM = LOW' \r\n\r\n      EXPRESSION 'Low' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 255 0 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'PERM = SATURATED' \r\n\r\n      EXPRESSION 'Saturated' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 200\r\n\r\n         COLOR 255 1 255\r\n\r\n       END\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'PERM = WATER' \r\n\r\n      EXPRESSION 'Water' \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 0 0 255 \r\n\r\n       END\r\n\r\n    END\r\n\r\n\r\n\r\n  END	2011-09-24 02:11:16.525806	2011-09-27 07:00:01.522045	12
15	Bus Stops	Bus stop locations	  LAYER\r\n\r\n    NAME 'Busstop'\r\n\r\n    TYPE POINT\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1255781.009996 252154.768069 1276181.547177 263745.982377\r\n\r\n    DATA 'Busstop.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'Busstop'\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'Busstop' \r\n\r\n       STYLE\r\n\r\n         SYMBOL "triangle" \r\n\r\n         SIZE 8 \r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 0 0 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END	2011-09-24 02:16:11.422827	2011-09-27 07:06:46.714005	91
17	Project Boundary	Greenwood project boundary	  LAYER\r\n\r\n    NAME 'Boundary'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    DATA 'Boundary.shp'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'Boundary'\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'Boundary' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0\r\n\r\n         WIDTH 3\r\n\r\n         OPACITY 70\r\n\r\n         OUTLINECOLOR 255 100 0\r\n\r\n         COLOR 255 0 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END 	2011-09-24 02:17:49.284126	2011-09-28 02:08:12.187814	60
24	White Background	To be used as a default base layer.	  LAYER\r\n    NAME "line"\r\n    STATUS ON\r\n    TYPE line\r\n    PROJECTION\r\n      "init=epsg:4326"\r\n    END\r\n    CLASS\r\n      COLOR 0 0 0\r\n      NAME "Some Line Layer"\r\n    END\r\n    METADATA\r\n      "wms_title" "Some Line Layer"\r\n    END\r\n  END 	2011-09-27 17:16:45.663132	2011-09-27 19:36:21.826126	8
14	Utility Poles	City Light pole locations	  LAYER\r\n\r\n    NAME 'CityLightPoles'\r\n\r\n    TYPE POINT\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1255781.009996 252154.768069 1276181.547177 263745.982377\r\n\r\n    DATA 'CityLightPoles.shp'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'CityLightPoles'\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'CityLightPoles' \r\n\r\n       STYLE\r\n\r\n         SYMBOL "circle" \r\n\r\n         SIZE 4.0 \r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 177 214 186\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END\r\n\r\n	2011-09-24 02:15:24.446515	2011-09-27 07:05:57.154169	87
12	Contours light	2' contours - light color	  LAYER\r\n\r\n    NAME 'light_contour'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    DATA 'contour.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'light_contour'\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    #TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'light_contour' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0 \r\n\r\n         WIDTH 1\r\n\r\n         COLOR 254 254 254\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END	2011-09-24 02:13:17.193832	2011-09-28 04:37:50.484904	89
13	Contours dark	2' contours - dark color	  LAYER\r\n\r\n    NAME 'dark_contour'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    DATA 'contour.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'dark_contour'\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'dark_contour' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0 \r\n\r\n         WIDTH 1\r\n\r\n         COLOR 100 100 100\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END\r\n\r\n	2011-09-24 02:13:46.281992	2011-09-28 02:35:18.466968	88
16	Bus Routes	Bus route locations	  LAYER\r\n\r\n    NAME 'BusRoutes'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    DATA 'BusRoutes.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'BusRoutes'\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS ON\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n       NAME 'BusRoutes' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0\r\n\r\n         WIDTH 3\r\n\r\n         OPACITY 25\r\n\r\n         OUTLINECOLOR 255 100 0\r\n\r\n         COLOR 255 0 0\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END 	2011-09-24 02:16:58.793936	2011-09-27 18:07:25.037563	65
23	Aerial Low Res		  LAYER\r\n\r\n    NAME 'greenwood_half'\r\n\r\n    TYPE RASTER\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'greenwood_half.tif'\r\n\r\n    METADATA\r\n\r\n      'wms_title' 'greenwood_half'\r\n\r\n      'wms_srs'   "epsg:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n  END	2011-09-27 02:47:28.059726	2011-09-28 04:31:37.510969	2
11	Street Names	Street names	  \r\n\r\n  LAYER\r\n\r\n    NAME 'st_address_Clip'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'st_address_Clip.shp|layerid=0'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'st_address_Clip'\r\n\r\n      'wms_title' 'st_address_Clip'\r\n\r\n      'wms_srs'    "EPSG:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 40\r\n\r\n    PROJECTION\r\n\r\n      "init=epsg:4326"\r\n\r\n    END\r\n\r\n    \r\n\r\n    LABELITEM 'ST_NAME'\r\n\r\n    \r\n\r\n    CLASS\r\n\r\n       NAME 'st_address_Clip' \r\n\r\n       \r\n\r\n       \r\n\r\n     LABEL \r\n\r\n      FONT arial-bold\r\n\r\n      TYPE truetype\r\n\r\n      SIZE 8\r\n\r\n      COLOR 100 100 100\r\n\r\n      ANGLE AUTO\r\n\r\n      BUFFER 1\r\n\r\n      POSITION cc\r\n\r\n      FORCE false\r\n\r\n      ANTIALIAS false\r\n\r\n      PARTIALS false\r\n\r\n      MINDISTANCE 100000000\r\n\r\n     END \r\n\r\n    END\r\n\r\n  END	2011-09-24 02:12:19.188752	2011-09-27 07:03:34.745976	85
22	Aerial High Res		  LAYER\r\n\r\n    NAME 'greenwood'\r\n\r\n    TYPE RASTER\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n    EXTENT 1259300 254000 1269500 262500\r\n\r\n    DATA 'greenwood.tif'\r\n\r\n    METADATA\r\n\r\n      'wms_title' 'ortho1'\r\n\r\n      'wms_srs'   "epsg:4326"\r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n  END\r\n\r\n\r\n	2011-09-26 21:52:26.098359	2011-10-09 16:49:03.419693	4
20	Study Areas Character 	Study Areas: areas with typical character	  LAYER\r\n\r\n    NAME 'study_character'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n  EXTENT 1261618.518886 256258.726399 1270194.665382 261411.937232\r\n\r\n    DATA 'study_character.shp'\r\n\r\n    METADATA\r\n\r\n      'ows_title' 'study_character'\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    LABELITEM 'name'\r\n\r\n    CLASS\r\n\r\n       NAME 'study_character' \r\n\r\n       STYLE\r\n\r\n         WIDTH 0.91 \r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR 116 69 196\r\n\r\n       END\r\n\r\n     LABEL \r\n\r\n      FONT arial-bold\r\n\r\n      TYPE truetype\r\n\r\n      SIZE 15\r\n\r\n      COLOR 0 0 0\r\n\r\n      OUTLINECOLOR 255 255 255\r\n\r\n      OUTLINEWIDTH 5\r\n\r\n      REPEATDISTANCE 500\r\n\r\n      ANGLE 0\r\n\r\n      BUFFER 10\r\n\r\n      POSITION cc\r\n\r\n      FORCE true\r\n\r\n      ANTIALIAS true\r\n\r\n      PARTIALS false\r\n\r\n      MINDISTANCE 1000000\r\n\r\n    END            \r\n\r\n    END\r\n\r\n  END	2011-09-24 02:23:35.093783	2011-09-28 02:36:34.967862	78
19	Study Areas Corridors	Study Areas: Corridors	LAYER\n\n    NAME 'study_corridors'\n\n    TYPE POLYGON\n\n    DUMP true\n\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\n\n  EXTENT 1261618.518886 256258.726399 1270194.665382 261411.937232\n\n    DATA 'study_corridors.shp'\n\n    METADATA\n\n      'ows_title' 'study_corridors'\n\n    END\n\n    STATUS on\n\n    TRANSPARENCY 100\n\n    PROJECTION\n\n    'proj=longlat'\n\n    'ellps=WGS84'\n\n    'datum=WGS84'\n\n    'no_defs'\n\n    END\n\n    LABELITEM 'kate areas'\n\n    CLASS\n\n       NAME 'study_corridors' \n\n       STYLE\n\n         WIDTH 0.91 \n\n         OUTLINECOLOR 0 0 0\n\n         COLOR 229 61 99\n\n       END\n\n    LABEL \n\n      FONT arial-bold\n\n      TYPE truetype\n\n      SIZE 15\n\n      COLOR 0 0 0\n\n      OUTLINECOLOR 255 255 255\n\n      OUTLINEWIDTH 5\n\n      REPEATDISTANCE 500\n\n      ANGLE 0\n\n      BUFFER 10\n\n      POSITION cc\n\n      FORCE true\n\n      ANTIALIAS true\n\n      PARTIALS false\n\n      MINDISTANCE 1000000\n\n    END     \n\n    END\n\n  END\n	2011-09-24 02:21:14.20751	2011-09-28 02:36:52.09243	79
21	Study Areas Blocks	Block Focus Study Areas	LAYER\n\n    NAME 'study_blocks'\n\n    TYPE POLYGON\n\n    DUMP true\n\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\n\n    EXTENT 1261618.518886 256258.726399 1270194.665382 261411.937232\n\n    DATA 'study_blocks.shp'\n\n    METADATA\n\n      'ows_title' 'study_blocks'\n\n    END\n\n    STATUS on\n\n    OPACITY 100\n\n    PROJECTION\n\n    'proj=longlat'\n\n    'ellps=WGS84'\n\n    'datum=WGS84'\n\n    'no_defs'\n\n    END\n\n\n\n    LABELITEM 'kate areas'\n\n    CLASS\n\n       NAME 'study_blocks' \n\n\n\n       STYLE\n\n         WIDTH 0.91 \n\n         OUTLINECOLOR 0 0 0\n\n         COLOR 174 31 183\n\n       END\n\n     LABEL \n\n\n      FONT arial-bold\n\n      TYPE truetype\n\n      SIZE 15\n\n      COLOR 0 0 0\n\n      OUTLINECOLOR 255 255 255\n\n      OUTLINEWIDTH 5\n\n      REPEATDISTANCE 500\n\n      ANGLE 0\n\n      BUFFER 10\n\n      POSITION cc\n\n      FORCE true\n\n      ANTIALIAS true\n\n      PARTIALS false\n\n      MINDISTANCE 1000000\n\n    END     \n\n  END\n\nEND	2011-09-24 02:24:55.211769	2011-09-30 00:01:13.915582	80
25	None	Background layer, always first.	  LAYER\r\n    NAME "line"\r\n    STATUS ON\r\n    TYPE line\r\n    PROJECTION\r\n      "init=epsg:4326"\r\n    END\r\n    CLASS\r\n      COLOR 0 0 0\r\n      NAME "Some Line Layer"\r\n    END\r\n    METADATA\r\n      "wms_title" "Some Line Layer"\r\n    END\r\n  END 	2011-10-03 06:48:47.876565	2011-10-09 18:17:32.256828	1
18	Survey Walking Paths	Surveys: Walking Paths	  LAYER\r\n\r\n    NAME 'walk_survey'\r\n\r\n    TYPE LINE\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE    'walk_survey_query_response_template.html'\r\n\r\n    HEADER      'header.html'\r\n\r\n    FOOTER      'footer.html'\r\n\r\n\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    CONNECTIONTYPE POSTGIS\r\n\r\n    CONNECTION "host=localhost dbname=neighbors_maps_dev user=paul password=874rghtic port=5432"\r\n\r\n    DATA "routes from walk_surveys "\r\n\r\n\r\n\r\n    FILTER "%filter_string%"\r\n\r\n\r\n\r\n    METADATA\r\n\r\n      'ows_title'  'walk_survey'\r\n\r\n      'wms_title'  'walk_survey'\r\n\r\n      'wms_srs'    "EPSG:4326"    \r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n      'default_filter_string' '1=1'\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    \r\n\r\n   LABELITEM 'route_frequencies'\r\n\r\n    \r\n\r\n    CLASS\r\n\r\n       NAME 'route_frequencies' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 7.0\r\n\r\n         WIDTH 8\r\n\r\n         OPACITY 15\r\n\r\n\r\n\r\n         OUTLINECOLOR 255 0 0\r\n\r\n         COLOR 255 0 0\r\n\r\n       END\r\n\r\n     LABEL \r\n\r\n      FONT arial-bold\r\n\r\n      TYPE truetype\r\n\r\n      SIZE 15\r\n\r\n      COLOR 0 0 0\r\n\r\n      OUTLINECOLOR 255 255 255\r\n\r\n      OUTLINEWIDTH 5\r\n\r\n      REPEATDISTANCE 500\r\n\r\n      ANGLE 0\r\n\r\n      BUFFER 10\r\n\r\n      POSITION cc\r\n\r\n      FORCE true\r\n\r\n      ANTIALIAS true\r\n\r\n      PARTIALS false\r\n\r\n      MINDISTANCE 1000000\r\n\r\n     END \r\n\r\n    END\r\n\r\n  END\r\n\r\n	2011-09-24 02:20:14.593375	2014-06-21 01:24:13.556186	81
3	Half Block Areas	Half Block colored polygons	  \r\n\r\n  # this layer draws a polygon colored according to the 'fill_color' column of table 'half_blocks'\r\n\r\n  LAYER\r\n\r\n    NAME 'half_block_color'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    CONNECTIONTYPE POSTGIS\r\n\r\n    CONNECTION "host=localhost dbname=neighbors_maps_dev user=paul password=874rghtic port=5432"\r\n\r\n    DATA "the_geom from half_blocks"\r\n\r\n    METADATA\r\n\r\n      'ows_title'  'half_block_id'\r\n\r\n      'wms_title'  'half_block_id'\r\n\r\n      'wms_srs'    "EPSG:4326"    \r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 50\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    CLASS\r\n\r\n      NAME 'half_block_color'  \r\n\r\n      STYLE\r\n\r\n        SYMBOL 0\r\n\r\n         OUTLINECOLOR 0 0 0\r\n\r\n         COLOR [fill_color]\r\n\r\n       END\r\n\r\n    END\r\n\r\n  END\r\n\r\n	2011-09-24 01:55:08.76141	2014-06-21 04:41:25.025679	14
1	Neighbors	Shows a red dot and last name of participating Neighbors.	  LAYER\r\n    NAME 'Neighbors'\r\n    TYPE POINT\r\n    DUMP true\r\n    TEMPLATE    'neighbor_query_response_template.html'\r\n    HEADER      'header.html'\r\n    FOOTER      'footer.html'\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n    CONNECTIONTYPE POSTGIS\r\n    CONNECTION "host=localhost dbname=neighbors_maps_dev user=paul password=874rghtic port=5432"\r\n    DATA "location from neighbors"\r\n    METADATA\r\n      'ows_title' 'neighbors_layer'\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n    END\r\n    STATUS on\r\n    TRANSPARENCY 100\r\n    PROJECTION\r\n      'proj=longlat'\r\n      'ellps=WGS84'\r\n      'datum=WGS84'\r\n      'no_defs'\r\n    END\r\n    LABELITEM 'last_name1'\r\n\r\n    CLASS\r\n       NAME 'neighbors' \r\n       STYLE\r\n         SYMBOL "circle"\r\n         SIZE 8\r\n         OUTLINECOLOR 255 100 0\r\n         COLOR 255 0 0\r\n       END\r\n      LABEL\r\n        FONT arial-bold\r\n        TYPE truetype\r\n        SIZE 9\r\n        POSITION uc\r\n        COLOR 0 0 0\r\n        FORCE true\r\n      END\r\n    END\r\n  END     	2011-09-24 01:42:36.07524	2014-06-21 04:51:42.601043	90
2	Half Block Labels	Half Block ID Labels	   \r\n\r\n  # this layer/class shows the half_block_id label\r\n\r\n  LAYER\r\n\r\n    NAME 'half_block_id'\r\n\r\n    TYPE POLYGON\r\n\r\n    DUMP true\r\n\r\n    TEMPLATE fooOnlyForWMSGetFeatureInfo\r\n\r\n\r\n\r\n    EXTENT 1259532.633428 252753.973920 1272953.746014 262713.223921\r\n\r\n    CONNECTIONTYPE POSTGIS\r\n\r\n    CONNECTION "host=localhost dbname=neighbors_maps_dev user=paul password=874rghtic port=5432"\r\n\r\n    DATA "the_geom from half_blocks"\r\n\r\n    METADATA\r\n\r\n      'ows_title'  'half_block_id'\r\n\r\n      'wms_title'  'half_block_id'\r\n\r\n      'wms_srs'    "EPSG:4326"    \r\n\r\n      'OWS_INCLUDE_ITEMS' "all"\r\n\r\n    END\r\n\r\n    STATUS on\r\n\r\n    TRANSPARENCY 100\r\n\r\n    PROJECTION\r\n\r\n    'proj=longlat'\r\n\r\n    'ellps=WGS84'\r\n\r\n    'datum=WGS84'\r\n\r\n    'no_defs'\r\n\r\n    END\r\n\r\n    \r\n\r\n   LABELITEM 'half_block_id'\r\n\r\n    \r\n\r\n    CLASS\r\n\r\n       NAME 'half_block_id' \r\n\r\n       STYLE\r\n\r\n         SYMBOL 0 \r\n\r\n         SIZE 10.0 \r\n\r\n\r\n\r\n       END\r\n\r\n     LABEL \r\n\r\n      FONT arial-bold\r\n\r\n      TYPE truetype\r\n\r\n      SIZE 11\r\n\r\n      COLOR 50 50 255\r\n\r\n      ANGLE 0\r\n\r\n      BUFFER 10\r\n\r\n      POSITION cc\r\n\r\n      FORCE true\r\n\r\n      ANTIALIAS true\r\n\r\n      PARTIALS false\r\n\r\n      MINDISTANCE 1000000\r\n\r\n     END \r\n\r\n    END\r\n\r\n  END	2011-09-24 01:52:56.201497	2014-06-21 04:42:10.097518	86
\.


--
-- Name: map_layers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('map_layers_id_seq', 26, false);


--
-- Data for Name: mapped_lines; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY mapped_lines (id, end_label, data, owner_id, map_layer_id, created_at, updated_at, geometry) FROM stdin;
\.


--
-- Name: mapped_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('mapped_lines_id_seq', 55, true);


--
-- Data for Name: neighbors; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY neighbors (id, first_name1, last_name1, email_1, first_name2, last_name2, email_2, address, zip, half_block_id, phone_1, phone_2, email_list, block_captain, volunteer, resident, professional, interest_expertise, created_at, updated_at, alias, years, sidewalks, unit, improvements, why_walk, dont_walk, signup_date, user_id, location) FROM stdin;
39	Joe	Smith	jsmith@yahoo.com				12018 8th Ave NE	98125	outside project area	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 01:51:32.000685	\N	7	\N		\N	\N	\N	2010-05-18	39	0101000020E61000000DA1CF6A2872334101784882262A1041
40	Joe	Schmoe	anonymous@clearwire.net				9209 Palatine Ave N	98103	499	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:17:09.592407	\N	6.5	\N		\N	\N	\N	2010-05-18	40	0101000020E61000009013455F344E33417300B45C3C760F41
42	Mel	Oyello	meloyello@incense.com				8544 Evanston Ave N	98103	238	555 555 5555		\N	maybe	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:27:55.449664	\N	10	\N		\N	\N	\N	2010-05-18	42	0101000020E6100000F54E7E90055433414F1D56405D420F41
18	Fred	Fields	more@hotmail.com				11009 Evantson Ave N	98103	outside project area	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:22:13.962438	\N	65	\N		\N	\N	\N	2010-06-12	18	0101000020E6100000D759F9D6945333418D6AD05DC5021041
28	Jon	Jones	jj@email.com				600 4th Ave	98104	outside project area	555 5555555		\N	no	\N	neither	\N	\N	2010-09-05 23:03:50	2011-10-26 19:19:15.08534	\N		\N		\N	\N	\N	2010-05-18	28	0101000020E6100000048A1C1FA2653341359654F244530B41
41	Alfred	Newman	aenewman@mad.com				420 N 70th St	98103	outside project area	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:25:57.83246	\N		\N		\N	\N	\N	2010-05-18	41	0101000020E61000001F173D544C513341D381ACF9FFB80E41
19	Mister	Rogers	mrrogers@mrrogers.com				332 NW 89th St	98117	355	555 555 5555		\N	maybe	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:25:01.713607	\N	5	\N		\N	\N	\N	2010-05-18	19	0101000020E6100000694840B24A493341B2B655C6BE580F41
8	Roger	Over	rogerover@andout.com				8739 Evanston Ave N	98103	482	555 555 5555		\N	yes	\N	both	\N	\N	2010-09-05 23:03:50	2011-10-26 19:26:54.839261	\N	2	\N		\N	\N	\N	2010-06-12	8	0101000020E6100000F72CDB7F6A5333414EA9087E48550F41
29	Bill	Rogers	lbcnu@home.net				705 N 85th	98103	200	555 555 5555		\N	no	\N	both	\N	\N	2010-09-05 23:03:50	2011-10-26 19:23:57.518315	\N	21	\N		\N	\N	\N	2010-05-18	29	0101000020E61000005E1EAE093F5533411F78C2AEB1320F41
32	Rich	Fortune	gud-s-gold@keepyourwealth.com				9227 1st Ave NW	98117	250	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:33:47.840095	\N	6	\N		\N	\N	\N	2010-06-12	32	0101000020E61000002D62AEB7EC4C3341947DDEF1F47B0F41
9	Howe	deDuty	howdedoo@gmail.com				115 N 84th	98103	292	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:32:22.170965	\N	16	\N		\N	\N	\N	2010-05-18	9	0101000020E61000004553782DD74D3341A799544524290F41
31	Phoebe	Wren	phoebe@birdsofafeather.com				9579 Dayton Ave N	98103	340	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:29:33.065078	\N	2	\N		\N	\N	\N	2010-05-18	31	0101000020E61000000E13823B7D5233415E035D482C990F41
21	Bob	Dobelina	mrbobdobolina@zilch.com				1301 N 90th St	98103	outside project area	555 555 5555		\N	no	\N	neither	\N	\N	2010-09-05 23:03:50	2011-10-26 19:35:15.204656	\N		\N		\N	\N	\N	2010-05-18	21	0101000020E61000004F6E6191735D33419541802F5B580F41
10	Sonny	Daze	makeame@happy.com				722 N 101st St	98133	385	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:38:04.047801	\N	8	\N		\N	\N	\N	2010-05-18	10	0101000020E6100000720897DA20563341A649A4C949B90F41
43	Frank	Enjoe	frankenjoe@hotmail.com				9059 3rd Ave NW	98117	354	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:38:51.711527	\N	3	\N		\N	\N	\N	2010-05-18	43	0101000020E6100000BE0F4682714A334143D5C296BB700F41
33	Joe	Brown	jbrown@tom.net	 	 		9200 2nd Ave NW	98117	491	555 555 5555		\N	maybe	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:40:08.09588	\N	6	\N		\N	\N	\N	2010-06-12	33	0101000020E6100000B5135A745A4C3341D704D95F42740F41
22	Mary	Doe	maresydoe@gemail.com				9046 Phinney Ave N	98103	334	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:45:10.083208	\N	10	\N		\N	\N	\N	2010-06-12	22	0101000020E6100000F70A8ED87F51334109031B47AF6C0F41
34	Fred	Smith	fred@smith.com				9557 7th Ave NW	98103	506	555  555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:45:59.219333	\N		\N		\N	\N	\N	2010-05-18	34	0101000020E610000038049012864633412F628505509B0F41
24	James	Cook	jamescook@msn.com				744 N 101st	98133	385	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:50:49.019417	\N	1	\N		\N	\N	\N	2010-05-18	24	0101000020E6100000E9113505075733417A19EFB01FB90F41
12	Bob	Dillon	bobdillon@dablues.com				9014 Evanston Ave N	98103	244	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:49:41.038497	\N	1	\N		\N	\N	\N	2010-05-18	12	0101000020E610000057A792CA1C5433418D931201B4610F41
1	Tombow	Dette	tombo@msnay.com				355 N 102nd St	98133	455			\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:48:13.857864	\N	5	\N		\N	\N	\N	2010-05-18	1	0101000020E6100000A4C54A4C5D523341CF0F8BC864BD0F41
23	Fred	Friendly	ffriendly@meetup.com				8701 1st Ave NW	98117	172	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:46:46.227291	\N	11	\N		\N	\N	\N	2010-05-18	23	0101000020E610000034BD333BEF4C33413DF04AE7194B0F41
25	Ann	Amal	m.anne@animal.com				933 N 84th	98103	296	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:59:12.109804	\N	21	\N		\N	\N	\N	2010-05-18	25	0101000020E6100000EAD26CB0F5583341619252A14B270F41
2	Mitt	Romney	ceo@cocacola.com				9732 Dayton Ave N	98117	140	555 555 5555		\N	maybe	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:53:47.634436	\N	10	\N		\N	\N	\N	2010-05-18	2	0101000020E6100000C71ACC4CEA52334100EF4DFDD1A50F41
35	Ron	Paul	flaming_liberal@gop.com				9008 Evanston Ave N	98103	244	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:52:36.64951	\N	4	\N		\N	\N	\N	2010-05-18	35	0101000020E61000009001C29A1B5433412E033A9BD25F0F41
13	Rick	Perry	rick@gotexas.net				9710 13th Ave NW	98117	outside project area	555 555 5555		\N	no	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:51:44.939411	\N	10	\N		\N	\N	\N	2010-05-18	13	0101000020E6100000FD1510E4983F33411DBC837B71A70F41
3	Rob	Rich	robinhood@sherwood.com				343 NW 77th St	98117	outside project area			\N	maybe	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:54:51.454842	\N	14	\N		\N	\N	\N	2010-05-18	3	0101000020E6100000B63D1B27A3483341D5BCA81BB5EF0E41
14	Frankie	Enjonnie	frankieenjonnie@me.com				340 NW 87th St	98117	308	206 789 8498		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:56:37.526078	\N	15	\N		\N	\N	\N	2010-06-12	14	0101000020E6100000746297E2DF483341F167A9F43B480F41
36	Max	Planck	quark@quantum.com				9007 Phinney Ave N	98103	114	555 555 5555		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 19:59:59.531463	\N	20	\N		\N	\N	\N	2010-06-12	36	0101000020E6100000A5C46D31C5503341182584E44D600F41
26	Avo	Gadro	themole@bignumber.com				8745 Greenwood Ave N	98103	320	6.022x10^23		\N	yes	\N	resident	\N	\N	2010-09-05 23:03:50	2011-10-26 20:05:19.361767	\N	8	\N		\N	\N	\N	2010-05-18	26	0101000020E61000003E11D71FAF4F33416F2B80AD63570F41
44	Paul	Sorey	psorey@comcast.net				9000 3rd Ave NW 	 	328			\N	maybe	--- \n- _non-skilled\n- _LA\n- _writer\n- _gardening\n- _construction\n	neither	\N	\N	2010-09-06 00:23:40.437719	2012-08-13 20:48:14.000298	\N	0	\N		--- \n- _trees\n- _plants\n- _slow\n- _rain\n- _gather\n- _play\n- _parking\n	--- \n- _school\n- _visit\n- _trans\n- _parks\n- _dog\n- _shop\n- _exercise\n- _meet\n	--- \n- _safety\n	\N	44	0101000020E6100000265232C1B54A3341B629B8ED925E0F41
\.


--
-- Name: neighbors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('neighbors_id_seq', 67, false);


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY projects (id, name, short_desc, forum_url, created_at, updated_at, project_boundary) FROM stdin;
\.


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('projects_id_seq', 1, false);


--
-- Data for Name: projects_users; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY projects_users (project_id, user_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY roles (id, name) FROM stdin;
87878	user
5555	guest
344677561	neighbor
135138680	admin
\.


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('roles_id_seq', 87879, false);


--
-- Data for Name: roles_users; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY roles_users (role_id, user_id) FROM stdin;
344677561	39
344677561	17
344677561	40
344677561	6
344677561	28
344677561	7
344677561	18
344677561	29
344677561	30
344677561	19
344677561	41
344677561	8
135138680	44
344677561	20
344677561	42
344677561	31
344677561	9
344677561	32
344677561	21
344677561	10
344677561	43
344677561	33
344677561	11
344677561	22
344677561	66
344677561	34
344677561	23
344677561	1
344677561	12
344677561	24
344677561	13
344677561	35
344677561	2
344677561	3
344677561	14
344677561	25
344677561	36
344677561	26
344677561	37
344677561	4
344677561	15
344677561	27
344677561	38
344677561	5
344677561	16
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY schema_migrations (version) FROM stdin;
20110930181623
20110402040800
20110924191123
20110928015215
20110401010121
20110924012759
20110927063444
20110407042118
20110926173435
20110924012760
20110923210812
20110928014709
20110406003402
20110924151941
20110930181625
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: theme_map_layers; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY theme_map_layers (id, theme_map_id, map_layer_id, line_color, fill_color, created_at, updated_at, is_base_layer, opacity, line_width, is_interactive) FROM stdin;
17	3	25	\N	\N	2011-10-14 05:56:14.672297	2011-10-14 05:56:14.672297	t	\N	\N	f
20	3	1	\N	\N	2011-10-14 17:55:08.263438	2011-10-14 17:55:08.263438	f	\N	\N	f
21	3	9	\N	\N	2011-10-14 17:55:08.282941	2011-10-14 17:55:08.282941	f	\N	\N	f
22	3	8	\N	\N	2011-10-14 17:55:08.288013	2011-10-14 17:55:08.288013	f	\N	\N	f
23	3	7	\N	\N	2011-10-14 17:55:08.292706	2011-10-14 17:55:08.292706	f	\N	\N	f
24	3	17	\N	\N	2011-10-14 17:55:08.297052	2011-10-14 17:55:08.297052	f	\N	\N	f
25	3	11	\N	\N	2011-10-14 17:55:08.301325	2011-10-14 17:55:08.301325	f	\N	\N	f
34	5	9	\N	\N	2011-10-14 18:50:37.412766	2011-10-14 18:50:37.412766	f	\N	\N	f
35	5	8	\N	\N	2011-10-14 18:50:37.422052	2011-10-14 18:50:37.422052	f	\N	\N	f
36	5	7	\N	\N	2011-10-14 18:50:37.426431	2011-10-14 18:50:37.426431	f	\N	\N	f
37	5	17	\N	\N	2011-10-14 18:50:37.430956	2011-10-14 18:50:37.430956	f	\N	\N	f
38	5	11	\N	\N	2011-10-14 18:50:37.435916	2011-10-14 18:50:37.435916	f	\N	\N	f
39	5	21	\N	\N	2011-10-14 18:50:37.441045	2011-10-14 18:50:37.441045	t	\N	\N	f
40	5	20	\N	\N	2011-10-14 18:50:37.445614	2011-10-14 18:50:37.445614	t	\N	\N	f
41	5	19	\N	\N	2011-10-14 18:50:37.450535	2011-10-14 18:50:37.450535	t	\N	\N	f
42	5	6	\N	\N	2011-10-14 18:50:37.559083	2011-10-14 18:50:37.559083	f	\N	\N	f
49	4	3	\N	\N	2011-10-16 08:28:09.348	2011-10-16 08:28:09.348	f	\N	\N	f
50	4	2	\N	\N	2011-10-16 08:28:09.478056	2011-10-16 08:28:09.478056	f	\N	\N	f
51	4	1	\N	\N	2011-10-16 08:28:09.483332	2011-10-16 08:28:09.483332	f	\N	\N	f
52	4	25	\N	\N	2011-10-16 08:28:09.487747	2011-10-16 08:28:09.487747	t	\N	\N	f
53	4	9	\N	\N	2011-10-16 08:28:09.492425	2011-10-16 08:28:09.492425	f	\N	\N	f
54	4	8	\N	\N	2011-10-16 08:28:09.509082	2011-10-16 08:28:09.509082	f	\N	\N	f
55	4	17	\N	\N	2011-10-16 08:28:09.513414	2011-10-16 08:28:09.513414	f	\N	\N	f
56	4	11	\N	\N	2011-10-16 08:28:09.517732	2011-10-16 08:28:09.517732	f	\N	\N	f
67	2	25	\N	\N	2014-06-25 19:21:08.178683	2014-06-25 19:21:08.178683	t	\N	\N	f
68	2	17	\N	\N	2014-06-25 19:21:08.190204	2014-06-25 19:21:08.190204	f	\N	\N	f
69	2	11	\N	\N	2014-06-25 19:21:08.201336	2014-06-25 19:21:08.201336	f	\N	\N	f
\.


--
-- Name: theme_map_layers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('theme_map_layers_id_seq', 69, true);


--
-- Data for Name: theme_maps; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY theme_maps (id, name, description, created_at, updated_at, slug, is_interactive) FROM stdin;
3	Neighbors Map	Map showing locations of neighbors who have signed up to participate.	2011-10-14 05:56:14.634571	2011-10-14 05:56:14.634571	neighbors-map	f
5	GS Team Study Areas	Study areas identified by the Greenwood Streetscapes design team.	2011-10-14 18:50:37.388577	2011-10-14 18:50:37.388577	gs-team-study-areas	f
4	Half Block IDs	Half-blocks are our proposed smallest organizational units for neighborhoods. Generally, one half-block consist of all the properties and residences on one side of a street, plus one half of the street and one half of the alley if it exists.	2011-10-14 18:44:37.922979	2011-10-16 08:28:09.528256	half-block-ids	f
2	Walking Paths Survey	Each neighbor marks the routes, and estimated number of trips per month, to destinations that they walk to. This data will be used in planning several new paved paths from east to west and north to south.  \r\n\r\nIn general, start the line at your residence and follow the path that you walk to each destination. If you sometimes take a different route to the same spot, that can be another line.  \r\n\r\nEstimate the number of times you walk that route per month and type the number in the pop-up box that appears when you double-click to end your line.  \r\n\r\nDon't worry if the first line you draw is not accurate; you can adjust the line later to make it more so. That being said, please be as accurate as you can with the actual path you take.   \r\n\r\n**Hint:** start off at a zoom level that allows you to see the entire route. Once you have drawn the line, zoom in closer and adjust the line. You can add line segments where you need them by dragging the circular handle at the middle of the segment you want to divide into two.  \r\n\r\nFor your final adjustments turn on the aerial photo layer.  \r\n\r\nRemember, you can come back later and adjust the paths as much as you like. We will notify by email when the survey is to be collected and analyzed.  \r\n	2011-10-14 05:44:12.613618	2011-10-16 08:29:11.123845	walking-paths-survey	t
\.


--
-- Name: theme_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('theme_maps_id_seq', 5, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY users (id, login, name, email, crypted_password, salt, created_at, updated_at, remember_token, remember_token_expires_at, activation_code, activated_at, neighbor_id) FROM stdin;
39	silvia_miea@yahoo.com		silvia_miea@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	39
17	dknezovich@hotmail.com		dknezovich@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	17
40	davidhw2008@clearwire.net		davidhw2008@clearwire.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	40
6	wyattdunlap@hotmail.com		wyattdunlap@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	6
28	tom.rasmussen@seattle.gov		tom.rasmussen@seattle.gov	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	28
7	improvenorth@msn.com		improvenorth@msn.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	7
18	daniel@danielkopald.com		daniel@danielkopald.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	18
29	x@art4321.com		x@art4321.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	29
30	lil-bitweed@hotmail.com		lil-bitweed@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	30
19	cynthiakozzi@comcast.net		cynthiakozzi@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	19
41	jean119@earthlink.net		jean119@earthlink.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	41
8	jon.espenschied@gmail.com		jon.espenschied@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	8
44	psorey		psorey@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	44
20	kruegernick@comcast.net		kruegernick@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	20
42	union1786@hotmail.com		union1786@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	42
31	sahmhs@hotmail.com		sahmhs@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	31
9	rob.fellows@mac.com		rob.fellows@mac.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	9
32	utiberio@comcast.net		utiberio@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	32
21	bjmessina@mindspring.com		bjmessina@mindspring.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	21
10	kertfog@yahoo.com		kertfog@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	10
43	bzeallear@yahoo.com		bzeallear@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	43
33	k-and-i@comcast.net		k-and-i@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	33
11	angela.gunn@gmail.com		angela.gunn@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	11
22	juli.susanne@gmail.com		juli.susanne@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	22
66	guest		test@test.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	66
34	bleacherspub@gmail.com		bleacherspub@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	34
23	ottoman55@msn.com		ottoman55@msn.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	23
1	sjamshein@hotmail.com		sjamshein@hotmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	1
12	hugh.handeyside@gmail.com		hugh.handeyside@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	12
24	hewittsama@yahoo.com		hewittsama@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	24
13	rickgharris@comcast.net		rickgharris@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	13
35	jc@visualsavant.com		jc@visualsavant.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	35
2	billyb53@comcast.net		billyb53@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	2
3	bjbrennan@yahoo.com		bjbrennan@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	3
14	matthewheilgeist@mac.com		matthewheilgeist@mac.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	14
25	okomski@msn.com		okomski@msn.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	25
36	avetrovs@gmail.com		avetrovs@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	36
26	mikeperfetti@yahoo.com		mikeperfetti@yahoo.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	26
37	jlvetrovs@earthlink.net		jlvetrovs@earthlink.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	37
4	lcoopergg@msn.com		lcoopergg@msn.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	4
15	tyanlee@gmail.com		tyanlee@gmail.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	15
27	c_perry@msn.com		c_perry@msn.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	27
38	ianwhyte@comcast.net		ianwhyte@comcast.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	38
5	tomjanet@premier1.net		tomjanet@premier1.net	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	5
16	shout@ozten.com		shout@ozten.com	14d9a43831d02b330565dfacc3f92959110a4f94	44d234b8ac26b0b80e302c22fcf3ebfce1b3f9cd	2011-03-21 00:13:48.138386	2011-10-14 00:02:32	\N	\N	bd43d9e588d46709bd4a59171a32d4072f72d16c	2011-03-21 00:13:48.138387	16
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('users_id_seq', 67, false);


--
-- Data for Name: walk_surveys; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY walk_surveys (id, neighbor_id, frequency, created_at, updated_at, route) FROM stdin;
\.


--
-- Name: walk_surveys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: paul
--

SELECT pg_catalog.setval('walk_surveys_id_seq', 1, false);


--
-- Name: administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);


--
-- Name: forums_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY forums
    ADD CONSTRAINT forums_pkey PRIMARY KEY (id);


--
-- Name: half_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY half_blocks
    ADD CONSTRAINT half_blocks_pkey PRIMARY KEY (id);


--
-- Name: map_layers_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY map_layers
    ADD CONSTRAINT map_layers_pkey PRIMARY KEY (id);


--
-- Name: mapped_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY mapped_lines
    ADD CONSTRAINT mapped_lines_pkey PRIMARY KEY (id);


--
-- Name: neighbors_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY neighbors
    ADD CONSTRAINT neighbors_pkey PRIMARY KEY (id);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: theme_map_layers_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY theme_map_layers
    ADD CONSTRAINT theme_map_layers_pkey PRIMARY KEY (id);


--
-- Name: theme_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY theme_maps
    ADD CONSTRAINT theme_maps_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: walk_surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY walk_surveys
    ADD CONSTRAINT walk_surveys_pkey PRIMARY KEY (id);


--
-- Name: index_projects_users_on_project_id; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE INDEX index_projects_users_on_project_id ON projects_users USING btree (project_id);


--
-- Name: index_projects_users_on_user_id; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE INDEX index_projects_users_on_user_id ON projects_users USING btree (user_id);


--
-- Name: index_roles_users_on_role_id; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE INDEX index_roles_users_on_role_id ON roles_users USING btree (role_id);


--
-- Name: index_roles_users_on_user_id; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE INDEX index_roles_users_on_user_id ON roles_users USING btree (user_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: paul; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO PUBLIC;
GRANT ALL ON SCHEMA public TO paul;


--
-- PostgreSQL database dump complete
--

