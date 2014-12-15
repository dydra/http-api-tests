#! /bin/bash

curl -f -s -S -X GET \
     -H "Accept: text/tab-separated-values" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"'?query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d' \
 | tr -s '\n' '\t' \
 | egrep -q -s 'COUNT1.*1'

