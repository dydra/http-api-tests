#! /bin/bash


curl -f -s -S -X POST \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"COUNT1".*"value":"1"'
query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d
EOF
