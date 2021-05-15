#! /bin/bash

# exercise the revision mechanism

if ( repository_has_revisions )
then
  curl_sparql_request 'revision-id=HEAD~1' <<EOF \
  | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | fgrep -q "1"
SELECT (count(*) as ?count)
WHERE {
 #{ ?s ?p ?o } 
 #union
 { ?s ?p ?o } 
 union
 { graph ?g  { ?s ?p ?o } } 
 }
EOF

else
  echo "${STORE_ACCOUNT}/${STORE_REPOSITORY} has just one revision"
fi





