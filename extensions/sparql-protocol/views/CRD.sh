#! /bin/bash
set -e

# test view usage: create/read/delete

# 'all' should always be found
echo "test 'all' definition" > ${ECHO_OUTPUT}
curl_sparql_view -w "%{http_code}\n" all | fgrep -q -s '200'
curl_sparql_view all | fgrep -q -s '"head"'
curl_sparql_view -H "Accept: application/sparql-query" all | fgrep -qs 'select * where'
echo "test 'all' definition . complete" > ${ECHO_OUTPUT}

# add/remove a new view
function insert_and_delete () {

curl_sparql_view -X PUT -w "%{http_code}\n" \
    -H "Content-Type: application/sparql-query" \
    --data-binary @- allput <<EOF | test_put_success
select * where {?s ?s ?d} # put
EOF

curl_sparql_view -H "Accept: application/sparql-query" allput | egrep -qs 'select.*# put';

curl_sparql_view -X DELETE -w "%{http_code}\n" allput \
    | test_ok
echo "CRD pass complete" > ${ECHO_OUTPUT}
}

echo "test view CRD" > ${ECHO_OUTPUT}
for ((i=0; i < 3; i ++)) ;do insert_and_delete; done

echo "test non-existence" > ${ECHO_OUTPUT}
curl_sparql_view -w "%{http_code}\n" -H "Accept: application/sparql-results+json" allput | fgrep -q -s '404'
# and
curl_sparql_view -w "%{http_code}\n" -H "Accept: application/rdf+xml" allput | fgrep -q -s '404'
# but
curl_sparql_view -w "%{http_code}\n" -H "Accept: application/rdf+xml" -H "Silent: true" allput | fgrep -q -s '204'

