#! /bin/bash

subject=''
predicate=''
object='o=%22subject1.object1%22'
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep -c subject1.object1 result.nq | fgrep -q 1
