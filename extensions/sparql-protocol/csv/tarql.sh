#! /bin/bash
set -e

# exercise csv inport with tarql conversion
#
# create the view, "tarql-test"
# import inline data into the mem-rdf-write repository as put and as post
# verify success
#

echo 'define (or replace) the "tarql-test" view query' > ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    -H "Accept: text/turtle" \
    --repository "mem-rdf-write" \
    --data-binary @- tarql-test <<EOF \
    | test_put_success
construct {?buri a ?auri}
where {
 { select ?a ?b where {} }
 bind( uri(?a) as ?auri)
 bind( uri(?b) as ?buri)
}
EOF
## (repository-view "openrdf-sesame/mem-rdf-write" "tarql-test")
## curl_graph_store_get --repository mem-rdf-write


echo "check import execution" >  ${ECHO_OUTPUT}
curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: text/csv" \
    -H "Accept: text/turtle" \
    --repository "mem-rdf-write" \
    --data-binary @- "tarql-test" <<EOF \
    | test_put_success
a, b
http://dydra.com/account_one, urn:dydra:Account
EOF
# curl_graph_store_get -w "%{http_code}\n" --repository mem-rdf-write

echo "check import execution" >  ${ECHO_OUTPUT}
curl_sparql_view -v -X POST -w "%{http_code}\n" \
    -H "Content-Type: text/csv" \
    -H "Accept: text/turtle" \
    --repository "mem-rdf-write" graph=default\
    --data-binary @- "tarql-test" <<EOF \
    | test_put_success
a, b
http://dydra.com/account_two, urn:dydra:Account
EOF


echo "verify success" >  ${ECHO_OUTPUT}
curl_graph_store_get -w "%{http_code}\n" --repository mem-rdf-write \
    | fgrep -c '/account' | fgrep -s 2


echo "${0} complete" >  ${ECHO_OUTPUT}

