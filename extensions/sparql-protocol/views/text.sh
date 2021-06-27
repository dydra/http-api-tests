#! /bin/bash
set -e

# exercise string to term identifier index
# this is for an internal text index for just one string identifier
#
# in this case, the materializing view is optional.
# the same pattern applies to the repository names, as if a "text" view exists.
# if there is none, it is emulated as if the view were
#
#    select $string where { ?s ?p $string . filter(isSTRING($string)) }
#
# (nb, the isSTRING predicate does not actually exist)
#
# given the test/foaf repository 
# - ensure that the text index exists
#   test/foaf corresponds to the foaf__text__view repository
#   the "text" view is implicit
# - ensure that a "byName" view exists
# - delete the cache content to regenerate the index
#   (this could actually just add)
# - test the index
#   - with a view which uses the index
#   - with a direct request to the index itself
# - delete the cache repository and ensure that it is gone
# - delete the view

# this proceeds without a view
# the single index is constructed with the columns
# - identifier
# - string
# - language
# - pattern

echo "create an index repository" > ${ECHO_OUTPUT}
${CURL} -X POST -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    -H "Content-Type: application/json" \
    --data-binary @- \
    "${STORE_URL}/system/accounts/test/repositories" <<EOF \
    | tee ${ECHO_OUTPUT} | test_success
{"name": "foaf__text__view",
 "class": "internal-text-repository",
 "sourceRepository": "test/foaf"}
EOF
#

echo 'define (or replace) the query which uses the text index' > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --account "test" \
    --repository "foaf" \
    --data-binary @- byName <<EOF | test_put_success
prefix foaf: <http://xmlns.com/foaf/0.1/> .
select ?subject ?name ?mbox
where {
  ?subject a foaf:Person;
    foaf:name $name;
    foaf:mbox ?mbox .
  ?name <http://jena.hpl.hp.com/ARQ/property#textMatch> $namePattern .
}
EOF


echo "check the view presence" > ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-query" \
    --account "test" \
    --repository "foaf" \
    byName \
    | fgrep -qs '?subject ?name ?mbox';


echo "delete the cache content to regenerate the index" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --account "test" \
    --repository "foaf__text__view" \
    | test_delete_success


echo "check view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --account "test" \
    --repository "foaf" \
    '$namePattern=%22t:*%22' \
    byName \
    | egrep -qs '"test"';



echo "check direct index access" > ${ECHO_OUTPUT}
curl_sparql_request -X GET '$pattern=%22t:*%22' \
    -H "Content-Type: " \
    -H "Accept: application/sparql-results+json" \
    --account "test" \
    --repository "foaf__text__view" \
    | egrep -qs '"test"'; 


echo "delete the cache repository" > ${ECHO_OUTPUT}
${CURL} -X DELETE -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    "${STORE_URL}/system/accounts/test/repositories/foaf__text__view" \
    | test_delete_success


echo "ensure it is gone" >  ${ECHO_OUTPUT}
curl_sparql_request -X GET   -w "%{http_code}\n" \
    --account "test" \
    --repository "foaf__text__view" \
    | tee $ECHO_OUTPUT | test_not_found ; 

# delete the view
curl_sparql_view -X DELETE -w "%{http_code}\n" \
    --account "test" \
    --repository "foaf" \
    byName | test_delete_success


echo "${0} complete" >  ${ECHO_OUTPUT}

