#! /bin/bash

# verify read access for user with read access only

curl_graph_store_get -u "${STORE_TOKEN}_READ:" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -q "<http://example.com/subject>"
