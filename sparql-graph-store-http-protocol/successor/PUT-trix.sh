#! /bin/bash

# execute an import with trix
# add a successor query
# use asynchronous headers to direct notification back to the repository

initialize_repository --repository "${STORE_REPOSITORY}-write"
# -o /dev/null

# execute the put with json.
# succeed with the count variant which includes the revision url
echo PUT-trix : w/successor PUT > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /tmp/successor.nt \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/trix" \
     -H "Successor-Location: https://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}/count-all" \
     -H "Successor-Content-Type: application/sparql-query" \
     -H "Asynchronous-Content-Type: application/n-quads" \
     -H "Asynchronous-Location: https://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/service" \
     -H "Asynchronous-Method: POST" \
     -H "Asynchronous-Authorization: Bearer ${STORE_TOKEN}" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
<TriX>
<graph>
  <uri>http://dydra.com/trix-graph-name</uri>
  <triple>
   <uri>http://example.com/default-subject</uri>
   <uri>http://example.com/default-predicate</uri>
   <plainLiteral>default object . PUT-trix with successor</plainLiteral>
  </triple>
</graph>
</TriX>
EOF

export repositoryRevisionUUID=`fgrep 'http://www.w3.org/ns/activitystreams#object' /tmp/successor.nt | sed 's/.*revision=\([^>]*\).*/\1/'`
rm /tmp/successor.nt

echo PUT-trix : test gps update completion > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | fgrep http://example.com/default-subject | fgrep -q 'default object . PUT-trix with successor'

echo PUT-trix : wait for the asynchronous successor to run > $ECHO_OUTPUT
sleep 30


# test that the result count was 1
echo PUT-trix : test successor query completion > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | tee ${ECHO_OUTPUT} \
    | fgrep "${STORE_ACCOUNT}/${STORE_REPOSITORY}-write" | fgrep -q '"1"^^<http://www.w3.org/2001/XMLSchema#integer>'

# test that the revision was adopted
echo PUT-trix : test successor query completion using $repositoryRevisionUUID > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
    | tee ${ECHO_OUTPUT} \
    | fgrep 'http://www.w3.org/ns/activitystreams#object' | fgrep -qi "$repositoryRevisionUUID"

