#! /bin/bash

subject=''
predicate=''
object=''
$CURL -f -s -X GET \
  -H "Accept: application/n-quads" \
  "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep -c example.org/subject result.nq | fgrep -q 12

grep -v -e '^$' result.nq | wc -c | fgrep -q 12

