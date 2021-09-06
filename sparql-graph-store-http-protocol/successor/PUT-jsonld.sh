#! /bin/bash

# add a successor query
# notify back to the repository

initialize_repository --repository "${STORE_REPOSITORY}-write"
# -o /dev/null

# execute the put with json.
# succeed with the count variant which includes the revision url
echo PUT-rj : w/successor PUT > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /tmp/successor.nt \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/ld+json" \
     -H "Successor-Location: https://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}/count-all" \
     -H "Successor-Content-Type: application/sparql-query" \
     -H "Asynchronous-Content-Type: application/n-quads" \
     -H "Asynchronous-Location: https://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/service" \
     -H "Asynchronous-Method: POST" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
[{"@id":"http://example.com/default-subject",
  "http://example.com/default-predicate":[{"@value":"default object . PUT successor"}]},
 {"@id":"http://example.com/named-subject",
  "http://example.com/named-predicate":[{"@value":"named object . PUT successor"}]}]
EOF

export repositoryRevisionUUID=`fgrep 'http://www.w3.org/ns/activitystreams#object' /tmp/successor.nt | sed 's/.*revision=\([^>]*\).*/\1/'`

echo PUT-rj : test gps update completion > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | fgrep http://example.com/default-subject | fgrep -q 'default object . PUT successor'

# wait for the asynchronous successor to run
sleep 20


# test that the result count was 2
# jsonld knows triples only: both statements are in the default graph
echo PUT-rj : test successor query completion > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | fgrep openrdf-sesame/mem-rdf-write | fgrep -q '"2"^^<http://www.w3.org/2001/XMLSchema#integer>'

# test that the revision was adopted
echo PUT-rj : test successor query completion > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | fgrep 'http://www.w3.org/ns/activitystreams#object' | fgrep -q "$repositoryRevisionUUID"

