#! /bin/bash

# exercise the revision mechanism

curl_sparql_request 'revision-id=HEAD~1' <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "1"

SELECT (count(*) as ?count)
WHERE { { graph ?g  { ?s ?p ?o } } union { ?s ?p ?o } }
EOF


