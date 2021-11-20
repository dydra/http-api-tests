#! /bin/bash

# exercise the revision mechanism

if ( repository_has_revisions )
then
  curl_sparql_request revision-id=HEAD <<EOF \
  | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q "2"
SELECT (count(*) as ?count)
WHERE { { graph ?g  { ?s ?p ?o } } union { ?s ?p ?o } }
EOF

else
  echo "${0}: ${STORE_ACCOUNT}/${STORE_REPOSITORY} has just one revision"
fi



