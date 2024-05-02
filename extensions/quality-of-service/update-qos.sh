#! /bin/bash
set -e

# ensure that a view exists
# import one qos variant for that view
# exercise the view and ensure that the qos is refleted in the response 
# import a second qos variant for that view
# exercise the view again and ensure that the second qos is refleted in the response 
# remove the view

# (spocq.i::REPOSITORY-VIEW-DEFINITIONS (repository "test/test"))

echo "create repository" > $ECHO_OUTPUT
curl_sparql_view -X PUT --account test --repository test -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --data-binary @- test_qos <<EOF | test_put_success
select * where {?s ?p ?o}
EOF

echo "SPARQL qos specified" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_success
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/SPARQL> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test> .
}
EOF

sleep 10
echo "retrieve SPARQL qos" > $ECHO_OUTPUT
curl_sparql_view -X GET --account test --repository test -w "%{http_code}\n" \
    -H "Accept: application/sparql-results+json" \
    -D - test_qos \
    | fgrep Service-Quality | fgrep -q SPARQL


echo "Scheduled qos specified" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_success
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/Scheduled> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test> .
}
EOF


sleep 10
echo "retrieve Scheduled qos" > $ECHO_OUTPUT
curl_sparql_view -X GET --account test --repository test -w "%{http_code}\n" \
    -H "Accept: application/sparql-results+json" \
    -D - test_qos \
    | fgrep Service-Quality | fgrep -q Scheduled


echo "clear the specification" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_success
EOF

sleep 10
echo "retrieve no qos" > $ECHO_OUTPUT
curl_sparql_view -X GET --account test --repository test -w "%{http_code}\n" \
    -H "Accept: application/sparql-results+json" \
    -D - test_qos \
     | fgrep Service-Quality | fgrep -q Unspecified


echo "delete view" > $ECHO_OUTPUT
curl_sparql_view -X DELETE  --account test --repository test -w "%{http_code}\n" test_qos \
    | test_ok
