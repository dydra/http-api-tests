#! /bin/bash

# test asynchronous view invocation
# - clear a target repository
# - direct the request to a construct view
# - specify notify-asynchronous
# - direct the result to a repository with content type ntriples
# - test for content in the target repository

function async_sparql_get () {
  viewName="$1"
  requestID=`date +%Y%m%dT%H%M%S`
  echo "${0} async request ${requestID}" >  ${ECHO_OUTPUT}
  curl_sparql_view -w "%{http_code}\n" -o /dev/null \
    -H "Content-Type: " \
    -H "Accept-Asynchronous: notify" \
    -H "Asynchronous-Location: https://${STORE_HOST}/${STORE_ACCOUNT}/${STORE_REPOSITORY_WRITABLE}/service?default" \
    -H "Asynchronous-Method: POST" \
    -H "Asynchronous-Content-Type: application/n-triples" \
    -H "Accept: application/json" \
    -H "Client-Request-Id: ${requestID}" \
    $viewName \
    --repository "${STORE_REPOSITORY}" \
   |  fgrep -q 202
}

# ensure an empty target repository and source content
initialize_repository_content --repository ${STORE_REPOSITORY}
clear_repository_content --repository ${STORE_REPOSITORY_WRITABLE}

# get source content
curl_graph_store_get --repository ${STORE_REPOSITORY} -H "Accept: application/n-triples" | sort > GET-asynchronous.nt

# curl_sparql_view --repository "${STORE_REPOSITORY}" all
# curl_sparql_view --repository "${STORE_REPOSITORY}" construct_all

# perform the asynchronous request
async_sparql_get construct_all

sleep 20

# curl_sparql_view --repository ${STORE_REPOSITORY_WRITABLE} all

curl_graph_store_get --repository ${STORE_REPOSITORY_WRITABLE} | sort | cmp -s /dev/stdin GET-asynchronous.nt

echo "${0} complete" >  ${ECHO_OUTPUT}

