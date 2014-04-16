#! /bin/bash

# verify constraints on about properties
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

# test reserved name
curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: " \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "400"
{
    "title": "sparql"
}
EOF


# test invalid homepage syntax
curl -w "%{http_code}\n" -f -s -X POST \
     --trace curl.out \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "400"
{
   "homepage": "//http://example.org/test"
}
EOF


# test invalid license
curl -w "%{http_code}\n" -f -s -X POST \
     --trace curl.out \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "400"
{
    "license": "//http://unlicense.org"
}
EOF

