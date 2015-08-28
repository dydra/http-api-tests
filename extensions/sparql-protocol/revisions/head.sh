#! /bin/bash

# exercise the revision mechanism

curl_sparql_request revision-id=HEAD <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "2"

SELECT (count(*) as ?count)
WHERE { { graph ?g  { ?s ?p ?o } } union { ?s ?p ?o } }
EOF


