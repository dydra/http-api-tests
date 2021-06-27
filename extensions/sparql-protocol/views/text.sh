#! /bin/bash
set -e

# exercise string to term identifier index
# this is an internal materialized view with a text index for just the string identifier
#
# in this case, the materializing view is optional.
# the same pattern applies to the names, but if no "text" view exists, it is emulated as
# if the view were (nb, the isSTRING predicate does not actually exist)
#
#    select $string where { ?s ?p $string . filter(isSTRING($string)) }
#
# given the test/foaf repository 
# - ensure that the text index exists
#   test/foaf corresponds to the foaf__text__view repository
#   the "text" view is implicit
# - ensure that a "byName" view exists
# - delete the cache content to regenerate the index (this actually just adds)
# - test the index
#   - with a view which uses the index
#   - with a direct request to the index itself
# - delete the cache repository and ensure that it is gone
# - delete the view

echo "create a materialization cache repository. fails due to view query" > ${ECHO_OUTPUT}
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

echo 'define (or replace) the text index view query' > ${ECHO_OUTPUT}
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
  ?name <http://jena.hpl.hp.com/ARQ/property#textMatch> 't:*' .
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
    byName \
    | egrep -qs '"test"';



echo "check direct index access" > ${ECHO_OUTPUT}
curl_sparql_request -X GET '$name=%22t:*%22' \
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
    --data-binary @- byName | test_delete_success


echo "${0} complete" >  ${ECHO_OUTPUT}

