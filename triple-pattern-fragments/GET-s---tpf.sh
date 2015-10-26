#! /bin/bash

subject='s=%3chttp://example.org/subject1%3e'
predicate=''
object=''
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep -c example.org/subject1 result.nq \
 | fgrep -q 4
