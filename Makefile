# Makefile to build the 'colour' demo extension

MODULES = colour

EXTENSION = colour
DATA = colour--1.0.sql

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
