#! /bin/bash


${CURL} -f -s -X GET \
       -H "Accept: text/csv" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"'?query=select%20(count(*)%20as%20?count)where%20%7b?s%20?p%20?o%7d' \
 | fgrep -q -s 'count'

