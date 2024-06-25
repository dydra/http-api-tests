#! /bin/bash
set -e

# exercise free-text index for identifier cache materialization
# this is for an internal materialized view with free text indices for the parameters
# 
# given the test/foaf repository
# - replace any "byNameMbox" view with a known text
# - ensure that the materialization cache repository exists
#   test/foaf/byNameMbox corresponds to the foaf__byNameMbox__view repository
# - delete the cache content to regenerate the view
#   do not perform the failures varians as in materialized.sh, just generate the materialized content
# - test the projection
# - delete the cache repository and ensure that it is gone
# - delete the view

# the first $variable in the projection clause names the originating binding.
# it yields the free text values as well as the interned term identifier
# the remainder are carried through as term identifiers only

# test support
curl_sparql_query -X GET \
  -H "Content-Type: " \
  -H "Accept: application/n-quads" \
  | fgrep -qs  'http://www.w3.org/ns/sparql-service-description#TextIndex' \
    || echo "no free text support" ; exit 0



echo 'define (or replace) the "byNameMbox" view query' > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --account "test" \
    --repository "foaf" \
    --data-binary @- byNameMbox <<EOF \
    | test_put_success
prefix foaf: <http://xmlns.com/foaf/0.1/> .
select ?subject \$name ?mbox
where {
  ?subject a foaf:Person;
    foaf:name \$name;
    foaf:mbox ?mbox .
}
EOF
## (repository-view "test/foaf" "byNameMbox")


echo "check the view presence" > ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-query" \
    --account "test" \
    --repository "foaf" \
    byNameMbox \
    | fgrep -qs '?subject $name ?mbox';


echo "check view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --account "test" \
    --repository "foaf" \
    byNameMbox \
    | egrep -qs '"test"';


echo "create a text index cache repository." > ${ECHO_OUTPUT}
${CURL} -X POST -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    -H "Content-Type: application/json" \
    --data-binary @- \
    "${STORE_URL}/system/accounts/test/repositories" <<EOF \
    | tee ${ECHO_OUTPUT} | test_success
{"name": "foaf__byNameMbox__view",
 "class": "internal-text-view-repository",
 "sourceRepository": "test/foaf",
 "sourceView": "byNameMbox"}
EOF


echo "delete the cache content to regenerate to match the corrected view - should succeed" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --repository "foaf__byNameMbox__view" \
    | test_delete_success

echo "delete asynchronously" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --account "test" \
    --repository "foaf__byNameMbox__view" \
    -H "Accept-Asynchronous: notify" \
    | test_accepted


echo "test materialized contents" > ${ECHO_OUTPUT}
curl_sparql_request -X GET '$s=%22t:*%22' \
    -H "Content-Type: " \
    --repository "foaf__byNameMbox__view" \
    | egrep -qs '"mailto:test@dydra.com"'; 

### this would be the place for a federation test, but it is not clear how 
### to arrange the bindings for:
### - pattern parameter as a query string argument
### - pattern parameter through sip to the materialized cache
### - result string incorporated into the base query interpretation

echo "delete the cache repository" > ${ECHO_OUTPUT}
${CURL} -X DELETE -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    "${STORE_URL}/system/accounts/openrdf-sesame/repositories/foaf__byNameMbox__view" \
    | test_delete_success


echo " ensure it is gone" >  ${ECHO_OUTPUT}
curl_sparql_request -X GET   -w "%{http_code}\n" \
    --repository "foaf__byNameMbox__view" \
    | tee $ECHO_OUTPUT | test_not_found ; 


echo "${0} complete" >  ${ECHO_OUTPUT}

