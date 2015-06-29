#! /bin/bash

curl_graph_store_get -H "Accept: application/rdf+json" \
   | jq 'keys' | tr -s '\n' ' ' \
   | fgrep '/default-subject"' | fgrep -q '/named-subject' 

