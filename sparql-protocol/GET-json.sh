#! /bin/bash


curl_sparql_request \
      -H "Accept: application/json" 'query=select%20*%20where%20%7b?s%20?p%20?o%7d' \
   | fgrep -q -s '"o": "default object"'

