#! /bin/bash

subject='s=%3chttp://example.org/subject1%3e'
predicate='p=%3chttp://example.org/predicate1%3e'
object=''
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep example.org/subject1 result.nq \
 | fgrep -c example.org/predicate1 \
 | fgrep -q 1
