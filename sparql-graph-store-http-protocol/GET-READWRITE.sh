#! /bin/bash

# verify read access for user with read/write access

curl_graph_store_get -u "${STORE_TOKEN}_READWRITE:" \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -q "<http://example.com/subject>"
