/*-------------------------------------------------------------------------
 *
 * colour.c
 *	  A demo data type for colours
 *
 * Portions Copyright (c) 1996-2013, PostgreSQL Global Development Group
 *-------------------------------------------------------------------------
 */

#include "postgres.h"

#include "fmgr.h"
#include "utils/builtins.h"

PG_MODULE_MAGIC;

Datum colour_out(PG_FUNCTION_ARGS);
Datum colour_in(PG_FUNCTION_ARGS);

Datum red(PG_FUNCTION_ARGS);
Datum green(PG_FUNCTION_ARGS);
Datum blue(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(colour_out);
PG_FUNCTION_INFO_V1(colour_in);
PG_FUNCTION_INFO_V1(red);
PG_FUNCTION_INFO_V1(green);
PG_FUNCTION_INFO_V1(blue);

Datum
colour_out(PG_FUNCTION_ARGS)
{
	int32		val = PG_GETARG_INT32(0);
	char	   *result = palloc(8);

	snprintf(result, 8, "#%06X", val);
	PG_RETURN_CSTRING(result);
}

Datum
colour_in(PG_FUNCTION_ARGS)
{
	const char *str = PG_GETARG_CSTRING(0);
	int32		result;

	if (str[0] != '#' || strspn(&str[1], "01234567890ABCDEF") != 6)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for colour: \"%s\"", str)));

	sscanf(str, "#%X", &result);
	PG_RETURN_INT32(result);
}


/* Functions to extract the red, green and blue components from a colour */
Datum
red(PG_FUNCTION_ARGS)
{
	int32		colour = PG_GETARG_INT32(0);

	PG_RETURN_INT32((colour & 0xFF0000) >> 16);
}

Datum
green(PG_FUNCTION_ARGS)
{
	int32		colour = PG_GETARG_INT32(0);

	PG_RETURN_INT32((colour & 0x00FF00) >> 8);
}

Datum
blue(PG_FUNCTION_ARGS)
{
	int32		colour = PG_GETARG_INT32(0);

	PG_RETURN_INT32(colour & 0x0000FF);
}

