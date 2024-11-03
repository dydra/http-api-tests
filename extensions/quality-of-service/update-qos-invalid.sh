#! /bin/bash
set -e

# ensure that a view exists
# - import settings for a non-existent view should fail
# - import setttings for a non-existent class should fail
# - import setttings for a non-existent abstract class should fail
# - import setttings for a non-existent service quality should fail
# remove the view

# for background:
# (spocq.i::REPOSITORY-VIEW-DEFINITIONS (repository "test/test"))

echo "create repository" > $ECHO_OUTPUT
curl_sparql_view -X PUT --account test --repository test -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --data-binary @- test_qos <<EOF | test_put_success
select * where {?s ?p ?o}
EOF

echo "allow invalid view specified" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_success
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/SPARQL> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos_not> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test> .
}
EOF

echo "invalid view class specified" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service  -H "Content-Type: application/trig" <<EOF | test_bad_request
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/SPARQL> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test-Not> .
}
EOF

echo "specify invalid service class" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_bad_request
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application-Not> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/SPARQL> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test> .
}
EOF

echo "specify invalid service quality" > $ECHO_OUTPUT
curl_graph_store_update -X PUT -w "%{http_code}\n" --account test --repository quality-of-service -H "Content-Type: application/trig" <<EOF | test_bad_request
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Test> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Application> .
}
<http://dydra.com/quality-of-service> {
    <http://dydra.com/quality-of-service/class/Application> <http://dydra.com/quality-of-service/quality> <http://dydra.com/quality-of-service/class/SPARQL-NOT> .
}

<http://dydra.com/quality-of-service/views> {
    <http://dydra.com/accounts/test/repositories/test/views/test_qos> <http://dydra.com/quality-of-service/class> <http://dydra.com/quality-of-service/class/Test> .
}
EOF

echo "delete view" > $ECHO_OUTPUT
curl_sparql_view -X DELETE -w "%{http_code}\n" --account test --repository test test_qos \
    | test_ok
