#! /bin/bash

# test the asynchronous gsp process
#
# request an import with the asynchronous header
# require the ok response w/ the request id and client request id headers
# direct notification to be a post to the same repository
# confirm that the notification is recorded

# (trace graph-store-respsonse repository-post-graph-content repository-queue-graph-import graph-store-post-content process-asynchronous-task-entry)
# an alternative is to run a local http server, but that may not available for a given client location
# python -m SimpleHTTPServer

# the test requires that asynchronous processing is in place, as
#
#    service spocq-async start
#
# it frequently fails when the predicted delay is too short.


requestID=`date +%Y%m%dT%H%M%S`

 # | test_post_success -w "%{http_code}\n"
 #  --trace -

echo "post async triples" > $ECHO_OUTPUT

function async_graph_store_update () {
  requestID=`date +%Y%m%dT%H%M%S`
  index=$1
  curl_graph_store_update -X POST -w "%{http_code}\n" -o /dev/null \
    -H "Accept-Asynchronous: notify" \
    -H "Asynchronous-Location: https://${STORE_HOST}/${STORE_ACCOUNT}/${STORE_REPOSITORY_WRITABLE}/service" \
    -H "Asynchronous-Method: POST" \
    -H "Asynchronous-Content-Type: application/ld+json" \
    -H "Accept: application/json" \
    -H "Client-Request-Id: ${requestID}.${index}" \
    -H "Content-Type: application/n-triples; charset=UTF-8" \
    --repository "${STORE_REPOSITORY_WRITABLE}" --data-binary @- <<EOF \
   |  fgrep -q 202
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-async ${requestID}.${index}" .
EOF
# if [[ "$?" != "0" ]]; then echo "failed: ${requestID}.${index}"; fi
}

### alternativels
###     -H "Asynchronous-Content-Type: application/n-quads" \


clear_repository_content --repository "${STORE_REPOSITORY_WRITABLE}";
# perform 10 'parallel' requests, with a sleep to avoid a rate-limit 429
for ((i = 0; i < 10; i ++)); do (async_graph_store_update $i &); sleep .25; done

# allow the remote operations to run: background runs @10seconds
sleep 20

echo "test async completion" > $ECHO_OUTPUT
curl_sparql_request -X POST \
  -H "Accept: application/sparql-results+json" \
  -H "Client-Request-Id: ${requestID}" \
  -H "Content-Type: application/sparql-query" \
  --repository "${STORE_REPOSITORY_WRITABLE}" --data-binary @- <<EOF \
  | tee $ECHO_OUTPUT \
  | fgrep -c "default object POST-async" \
  | fgrep -q 10
select distinct ?o from <urn:dydra:all> where {?s <http://example.com/default-predicate> ?o}
EOF


echo "test async erroneous disposition" > $ECHO_OUTPUT
curl_graph_store_update -X POST -w "%{http_code}\n" -o /dev/null \
  -H "Accept-Asynchronous: notify-not" \
  -H "Content-Type: application/n-triples" \
  --repository "${STORE_REPOSITORY_WRITABLE}"  <<EOF  \
  | test_bad_request
EOF
