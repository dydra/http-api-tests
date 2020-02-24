#! /bin/bash
set -e

# exercise materialization
#
# given openrdf_sesame/foaf
# - replace any "classes" view query with a known text
# - create a materialization cache repository
# - delete the cache content to regenerate to match the view
# - - first attempt should faile for lack of index
# - - revised version succeeds
# - test the projection
# - modify the view changing the indices and the projection
# - test the new projection
# - delete the view query and ensure it is gone
# - test that a view query without index parameters is rejected
# - delete the cache repository and ensure that it is gone
#

echo 'define (or replace) the "classes" view query with a known (erroneous) text' > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    -H "Accept: text/turtle" \
    --repository "foaf" \
    --data-binary @- types <<EOF \
    | cat # test_put_success
select distinct ?type  # invalid
where {
 { graph ?g {?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type} }
 union
 {?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type}
 bind('version1' as ?version)
}
EOF
## (repository-view "openrdf-sesame/foaf" "types")
## curl_graph_store_get --repository foaf

echo "check the view presence" > ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-query" \
    --repository "foaf" \
    types \
    | fgrep -qs '?g {?s';

echo "check view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --repository "foaf" \
    types \
    | egrep -qs '"results"';

echo "create a materialization cache repository. fails due to vew query" > ${ECHO_OUTPUT}
${CURL} -X POST -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    -H "Content-Type: application/json" \
    --data-binary @- \
    "${STORE_URL}/system/accounts/openrdf-sesame/repositories" <<EOF \
    | test_success
{name: "foaf__types__view",
 class: "internal-materialized-repository",
 sourceRepository: "openrdf-sesame/foaf",
 sourceView: "types"}
EOF
#

echo "test that it did create the repository itself"
curl_graph_store_get -w "%{http_code}\n" --repository foaf__types__view \
    | test_ok

# test the projection
# the first attempt should fail and require a revision

echo "delete the cache content to regenerate to match the view - should fail due to parameters" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    --repository "foaf__types__view" \
    | test_bad_request


echo "modify the view correcting the indices and the projection"  > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --repository "foaf" \
    --data-binary @- types <<EOF | test_put_success
select distinct ?type  # not quite corrected
where {
 { graph ?g {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type} }
 union
 {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type}
 bind('version2' as ?version)
}
EOF

echo "delete the cache content to regenerate to match the view - should fail due to projection" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    --repository "foaf__types__view" \
    | test_bad_request


echo "modify the view correcting the indices and the projection"  > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --repository "foaf" \
    --data-binary @- types <<EOF | test_put_success
select \$s ?type  # corrected
where {
 { graph ?g {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type} }
 union
 {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type}
 bind('version3' as ?version)
}
EOF


## (repository-view "openrdf-sesame/foaf" "types")

echo "check the corrected view presence" > ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-query" \
    --repository "foaf" \
    types \
    | fgrep -qs '?g {$s';

echo "check corrected view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --repository "foaf" \
    types \
    | egrep -qs '"results"';


echo "delete the cache content to regenerate to match the corrected view - should succeed" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --repository "foaf__types__view" \
    | test_delete_success

echo "delete asynchronously" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    --repository "foaf__types__view" \
    -H "Accept-Asynchronous: notify" \
    | test_accepted

echo "modify the view changing the indices and the projection"  > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --repository "foaf" \
    --data-binary @- types <<EOF | test_put_success
select \$g \$s ?type  # extended
where {
 { graph \$g {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type} }
 union
 {\$s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type}
 bind('version4' as ?version)
}
EOF
## (repository-view "openrdf-sesame/foaf" "types")

echo "check the corrected view presence" > ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-query" \
    --repository "foaf" \
    types \
    | fgrep -qs '$g $s ?type'

echo "check corrected view execution" >  ${ECHO_OUTPUT}
curl_sparql_view -H "Accept: application/sparql-results+json" \
    --repository "foaf" \
    types \
    | egrep -qs '"results"'


echo "delete the cache content to regenerate to match the corrected view - should succeed" > ${ECHO_OUTPUT}
curl_graph_store_delete -w "%{http_code}\n" \
    -H "Accept: text/turtle" \
    --repository "foaf__types__view" \
    | test_delete_success


echo "test materialized contents" > ${ECHO_OUTPUT}
curl_sparql_request -X GET '$s=%3chttp://www.setf.de/%23self%3e' \
    -H "Content-Type: " \
    --repository "foaf__types__view" \
    | egrep -qs '"results"'; 

echo "delete the cache repository" > ${ECHO_OUTPUT}
${CURL} -X DELETE -s -w "%{http_code}\n" -u ":${STORE_TOKEN}" \
    -H "Accept: application/sparql-results+json" \
    "${STORE_URL}/system/accounts/openrdf-sesame/repositories/foaf__types__view" \
    | test_delete_success


echo " ensure it is gone" >  ${ECHO_OUTPUT}
curl_sparql_request -X GET   -w "%{http_code}\n" \
    --repository "foaf__types__view" \
    | test_not_found ; 


echo "${0} complete" >  ${ECHO_OUTPUT}
