#! /bin/bash

# cycle the privacy setting to test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-HTTP-Method-Override: PUT" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q "204"
{"permissable_ip_addresses":["192.168.1.1", "192.168.1.2"],"privacy_setting": 5}
EOF


curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"privacy_setting":5' | fgrep -q '192.168.1.2'


initialize_privacy | egrep -q "${STATUS_UPDATED}"


curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"privacy_setting":1' | fgrep -q -v '192.168.1.2'

