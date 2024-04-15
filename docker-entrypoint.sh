#!/bin/sh

# Expand ERL_AFLAGS environment variable to include runtime variables
export ERL_AFLAGS=$(eval echo "$ERL_AFLAGS")

exec $@
