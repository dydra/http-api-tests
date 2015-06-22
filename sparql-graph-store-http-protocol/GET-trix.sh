#! /bin/bash

curl_graph_store_get -H "Accept: application/trix" | tr -s '\n' ' ' \
   | fgrep "${STORE_NAMED_GRAPH}" \
   | fgrep 'default object' | fgrep -q 'named object' 

# NYI
#  | rapper -q --input rdfxml --output nquads /dev/stdin - | tr -s '\n' '\t' \
