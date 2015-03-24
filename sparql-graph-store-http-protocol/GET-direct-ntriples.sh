#! /bin/bash

set_graph_store_url ${STORE_ACCOUNT} ${STORE_REPOSITORY}/graph-name
curl_graph_store_get \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"named object"' | fgrep -v "${STORE_NAMED_GRAPH}" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

    


