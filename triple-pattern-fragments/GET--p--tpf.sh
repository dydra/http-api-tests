#! /bin/bash

subject=''
predicate='p=%3chttp://example.org/predicate1%3e'
object=''
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep -c http://example.org/predicate result.nq | fgrep -q 3

fgrep -c http://example.org/predicate1 result.nq | fgrep -q 3
