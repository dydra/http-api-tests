#! /bin/bash

# verify operation of an html view

# SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.html" \
curl_sparql_view  -X GET \
  -H "Accept:" \
  -H "Content-Type:" all.html \
  | egrep -q '<title>.*'${STORE_ACCOUNT}/${STORE_REPOSITORY}'.*</title>'
