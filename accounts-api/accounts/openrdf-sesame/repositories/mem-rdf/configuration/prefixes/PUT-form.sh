#! /bin/bash


${CURL}  -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/namespaces?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q "204"
_method=PUT&repository[prefixes]=PREFIX xx: <http://xx.com> PREFIX yy: <http://zz.com> PREFIX zz2: <http://zz2.com>
EOF


${CURL}  -f -s -S -X GET \
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/namespaces?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep 'xx:' | fgrep 'yy:' | fgrep -v 'cc:' | fgrep -v -q '"xsd":'

initialize_prefixes | fgrep -q "204"

