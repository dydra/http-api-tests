#! /bin/bash

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=select%20(count(*)%20as%20%3Fcount1)%20where%20%7B%3Fs%20%3Fp%20%3Fo%7D'\&auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
   | fgrep 'variable name="count1"' \
   | egrep -q -s '<binding name="count1">.*<literal .*>1</literal>'
