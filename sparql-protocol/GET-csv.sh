#! /bin/bash


curl_sparql_request \
      -H "Accept: text/csv" 'query=select%20*%20where%20%7b?s%20?p%20?o%7d' \
   | fgrep -q -s '"default object"'

