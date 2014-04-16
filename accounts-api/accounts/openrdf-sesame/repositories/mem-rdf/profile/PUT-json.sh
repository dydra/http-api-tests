#! /bin/bash

# cycle various about setting and test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

curl -f -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep 'null' | wc | fgrep -q " 4 "
{
    "license": "http://example.com/none"
}
EOF

curl -f -s -S -X GET \
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep -q '"license_url":"http://example.com/none"'


initialize_profile | fgrep -q 204


