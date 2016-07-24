#! /bin/bash

# tests that default graph deletion leaves the named graph intact

initialize_repository --repository "${STORE_REPOSITORY}-write"
#echo initialized

curl_graph_store_delete default --repository "${STORE_REPOSITORY}-write"
#echo deleted

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 
#echo gotten


