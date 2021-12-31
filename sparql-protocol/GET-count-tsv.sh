#! /bin/bash

curl_sparql_request -H "Accept: text/tab-separated-values" 'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d' \
   | tr -s '\n' '\t' \
   | egrep -q -s 'COUNT.*1'

