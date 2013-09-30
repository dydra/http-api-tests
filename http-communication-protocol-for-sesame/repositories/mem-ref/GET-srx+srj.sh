#! /bin/bash

# verify the accept order is observed

curl -f -s -S -X GET\
     -H 'Accept: json,application/sparql-results+application/sparql-results+xml,*/*;q=0.9' \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
   | egrep -q -s '<binding name="COUNT1"> <literal .*>1</literal>'
