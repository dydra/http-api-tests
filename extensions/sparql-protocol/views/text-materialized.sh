#! /bin/bash
set -e

# exercise free-text index cache materialization
# 
# given the test/foaf repository
# - ensure that the materialization cache repository exists
# - create a materialization cache repository
#   test/foaf/byNameMbox corresponds to the foaf__byNameMbox__view repository
# - delete the cache content to regenerate the view
#   do not perform the failures varians as in materialized.sh, just generate the materialized content
# - test the projection
# - delete the cache repository and ensure that it is gone

# the first $variable in the projection clause names the originating binding.
# it ields the free text values as well as the interned term identifier
# the remainder are carried through as term identifiers only

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
    foaf:name $name;
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


echo "check corrected view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --account "test" \
    --repository "foaf" \
    byNameMbox \
    | egrep -qs '"test"';


echo "delete the cache content to regenerate to match the corrected view - should succeed" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --repository "foaf__types__view" \
    | test_delete_success

echo "delete asynchronously" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --account "test" \
    --repository "foaf__types__view" \
    -H "Accept-Asynchronous: notify" \
    | test_accepted


echo "test materialized contents" > ${ECHO_OUTPUT}
curl_sparql_request -X GET '$s=%22t:*%22' \
    -H "Content-Type: " \
    --repository "foaf__types__view" \
    | egrep -qs '"mailto:test@dydra.com"'; 

### this would be the place for a federation test, but it is not clear how that
### would work

echo "delete the cache repository" > ${ECHO_OUTPUT}
${CURL} -X DELETE -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    "${STORE_URL}/system/accounts/openrdf-sesame/repositories/foaf__types__view" \
    | test_delete_success


echo " ensure it is gone" >  ${ECHO_OUTPUT}
curl_sparql_request -X GET   -w "%{http_code}\n" \
    --repository "foaf__types__view" \
    | tee $ECHO_OUTPUT | test_not_found ; 


echo "${0} complete" >  ${ECHO_OUTPUT}

