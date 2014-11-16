#! /bin/bash

# verify the invalid mime type is rejected

curl -w "%{http_code}\n" -f -s -X GET\
     -H 'Accept: json,application/sparql-results+xml,*/*;q=0.9' \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
    | fgrep -q 400
