#! /bin/bash
set -e

# ensure that a view exists
# import one qos variant for that view
# exercise the view and ensure that the qos is refleted in the response 
# import a second qos variant for that view
# exercise the view again and ensure that the second qos is reflected in the response
# delete the specifications and ensure that the quality is default 
# remove the view

# for background:
# (spocq.i::REPOSITORY-VIEW-DEFINITIONS (repository "test/test"))

echo "create qos repository" > $ECHO_OUTPUT
create_repository --repository quality-of-service \
  | test_success

echo "create view" > $ECHO_OUTPUT
curl_sparql_view -X PUT --account test --repository test -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --data-binary @- test_qos <<EOF | test_put_success
select * where {?s ?p ?o}
EOF

echo "Queued qos specified" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_success
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/Queued> .
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
    | fgrep Service-Quality | fgrep -q Queued


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

# SPARQL is the default established by the nginx general view location
sleep 10
echo "retrieve no qos" > $ECHO_OUTPUT
curl_sparql_view -X GET --account test --repository test -w "%{http_code}\n" \
    -H "Accept: application/sparql-results+json" \
    -D - test_qos \
     | fgrep Service-Quality | fgrep -q SPARQL


echo "delete view" > $ECHO_OUTPUT
curl_sparql_view -X DELETE  --account test --repository test -w "%{http_code}\n" test_qos \
    | test_ok
