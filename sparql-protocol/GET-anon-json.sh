#! /bin/bash

initialize_repository_public

ECHO_OUTPUT=/dev/null # /dev/tty

curl_sparql_request --repository "$STORE_REPOSITORY_PUBLIC" -u "" \
     -H "Accept: application/json" \
     'query=select%20(count(*)%20as%20?count)where%20%7bgraph%20?g%20%7b?s%20?p%20?o%7d%7d' \
 | tee ${ECHO_OUTPUT} | jq '.[].count' | fgrep -q '1'
