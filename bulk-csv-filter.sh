#!/bin/bash

bindir="${0%/*}"

h="${1}"

if [ ! -e "${h}" ]; then
    exit 1
fi
if [ ! -e "$h"/bulk.csv ]; then
    echo "Does not exists: ${h}/bulk.csv" >&2
    exit 1
fi

perl -I"$bindir" "$bindir/filter-bulk-csv.pl" "${h}" || exit 1
