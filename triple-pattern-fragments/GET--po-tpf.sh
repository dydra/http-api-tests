#! /bin/bash

subject=''
predicate='p=%3chttp://example.org/predicate1%3e'
object='o=%22subject1.object1%22'
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep http://example.org/predicate1 result.nq \
 | fgrep -c "subject1.object1" \
 | fgrep -q 1
