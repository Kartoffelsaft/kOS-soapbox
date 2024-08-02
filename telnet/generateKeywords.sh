#!/bin/bash

# This script tries to extract all of the keywords used by kOS for
# autocompletion. This is intended to be used with rlwarp's -f option. Should
# automatically be generated in keywords.txt.
#
# Currently does not handle keywords hardcoded into the parser, such as "PRINT"

KOS_SRC='../../makes/KOS'



find "$KOS_SRC" -type f | grep ".*\.cs$" | while read filename; do
    grep -E '^[^/]+[^/]?[aA]dd[^(]*Suffix(<[a-zA-Z]+>)?\([^)]*"' "$filename" \
        | grep -oE '"[a-zA-Z]+"' \
        | tr -d '"'
done
