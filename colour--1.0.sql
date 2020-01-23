-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION colour" to load this file. \quit

CREATE OR REPLACE FUNCTION colour_in(cstring) RETURNS colour
  AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION colour_out(colour) RETURNS cstring
  AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE colour (
  INPUT = colour_in,
  OUTPUT = colour_out,
  LIKE = pg_catalog.int4
);

-- Helper functions
CREATE FUNCTION red(colour) RETURNS int4
  LANGUAGE C AS 'MODULE_PATHNAME' IMMUTABLE STRICT;
CREATE FUNCTION green(colour) RETURNS int4
  LANGUAGE C AS 'MODULE_PATHNAME' IMMUTABLE STRICT;
CREATE FUNCTION blue(colour) RETURNS int4
  LANGUAGE C AS 'MODULE_PATHNAME' IMMUTABLE STRICT;

CREATE FUNCTION luminence(colour) RETURNS numeric AS
$$
  SELECT (0.30 * red($1) +
          0.59 * green($1) +
          0.11 * blue($1))
         / 255.0
$$
LANGUAGE SQL IMMUTABLE STRICT;



-- Operators
CREATE FUNCTION colour_eq (colour, colour) RETURNS bool
  LANGUAGE internal AS 'int4eq' IMMUTABLE;

CREATE FUNCTION colour_lt (colour, colour)
  RETURNS bool AS $func$
    SELECT luminence($1) < luminence($2);
  $func$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION colour_le (colour, colour)
  RETURNS bool AS $$
    SELECT luminence($1) <= luminence($2);
  $$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION colour_ge (colour, colour)
  RETURNS bool AS $$
    SELECT luminence($1) >= luminence($2);
  $$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE FUNCTION colour_gt (colour, colour)
  RETURNS bool AS $$
    SELECT luminence($1) > luminence($2);
  $$ LANGUAGE SQL IMMUTABLE STRICT;


CREATE OPERATOR = (
  PROCEDURE = colour_eq,
  LEFTARG = colour, RIGHTARG = colour,
  HASHES, MERGES
);
CREATE OPERATOR <  ( LEFTARG=colour, RIGHTARG=colour, PROCEDURE=colour_lt);
CREATE OPERATOR <= ( LEFTARG=colour, RIGHTARG=colour, PROCEDURE=colour_le);
CREATE OPERATOR >= ( LEFTARG=colour, RIGHTARG=colour, PROCEDURE=colour_ge);
CREATE OPERATOR >  ( LEFTARG=colour, RIGHTARG=colour, PROCEDURE=colour_gt);

-- Comparison function, required for b-tree operator class.
CREATE FUNCTION luminence_cmp(colour, colour) RETURNS integer
AS $$
  SELECT CASE WHEN $1 = $2 THEN 0
  WHEN luminence($1) < luminence($2) THEN 1
  ELSE -1 END;
$$ LANGUAGE SQL IMMUTABLE STRICT;

-- B-tree Operator class
CREATE OPERATOR CLASS luminence_ops
  DEFAULT FOR TYPE colour USING btree AS
  OPERATOR 1 <,
  OPERATOR 2 <=,
  OPERATOR 3 =,
  OPERATOR 4 >=,
  OPERATOR 5 >,
  FUNCTION 1 luminence_cmp(colour, colour);



-- Distance

CREATE FUNCTION colour_diff (colour, colour) RETURNS float
AS $$
  SELECT sqrt((red($1) - red($2))^2 +
              (green($1) - green($2))^2 +
              (blue($1) - blue($2))^2)
$$ LANGUAGE SQL IMMUTABLE STRICT;

CREATE OPERATOR <-> (
  PROCEDURE = colour_diff,
  LEFTARG=colour,
  RIGHTARG=colour
);
