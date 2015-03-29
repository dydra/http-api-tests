#! /bin/bash

curl_graph_store_get -H "Accept: application/ld+json" \
   | jq '.[]["@id"]' | tr -s '\n' ' ' \
   | fgrep '/default-subject' | fgrep -q '/named-subject' 


# NYI
#  | rapper -q --input json --output nquads /dev/stdin - | tr -s '\n' '\t' \

