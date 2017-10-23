#! /bin/bash

# verify slice arguments for sparql views
# uses the built-in "all" and "default" views.
# nb. an earlier version of the test combined request parameters with a query slice.


SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.tsv" \
  curl_sparql_request -X GET -I -w "%{http_code}\n" | fgrep -q -s '200'


SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.tsv" \
curl_sparql_request -X GET  | wc -l | fgrep -q -s '3'
SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.tsv" \
curl_sparql_request 'limit=1' -X GET  | wc -l | fgrep -q -s '2' 
SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.tsv" \
curl_sparql_request 'limit=1' 'offset=1' -X GET | wc -l | fgrep -q -s '2'
SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.tsv" \
curl_sparql_request 'limit=1' 'offset=2' -X GET | wc -l | fgrep -q -s '1'


SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.csv" \
curl_sparql_request -X GET  | wc -l | fgrep -q -s '3'


SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.srj" \
curl_sparql_request -X GET | fgrep '"s":' | wc -l  | fgrep -q -s '2' 
SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.srj" \
curl_sparql_request 'limit=1' 'offset=1' -X GET | fgrep '"s":' | wc -l | fgrep -q -s '1' 


SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.srx" \
curl_sparql_request -X GET  | tidy -xml -q | fgrep '<result>' | wc -l | fgrep -q -s '2' 
SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.srx" \
curl_sparql_request 'limit=1' 'offset=1' -X GET | tidy -xml -q | fgrep '<result>' | wc -l | fgrep -q -s '1' 


# NTF
# $CURL -u "${STORE_TOKEN}:" "http://dydra.com/openrdf-sesame/mem-rdf/${query}.jsonp?limit=1" | fgrep -q -s-v "],["

# when jsonp
# 2016-03-21T08:52:30.601368+00:00 [debug] ool dydra-admin: Spawning: exec '/opt/dydra/bin/dydra-query' 'openrdf-sesame/mem-rdf' '-U' 'ee34b433-2d04-49a9-860a-b3f22572916c' '-o' 'application/json' '-D' 'agent-id=james' '-D' 'agent-location=94.219.69.66'
# when tsv
# 2016-03-21T08:53:15.806306+00:00 [debug] ool dydra-query: Spawning: exec '/opt/dydra/bin/dydra-query' 'openrdf-sesame/mem-rdf' '-U' '1206b632-0769-41ef-a43a-0ad3b9e61646' '-o' 'text/tab-separated-values' '-D' 'agent-id=james' '-D' 'agent-location=94.219.69.66' '-D' 'limit=1'

