#! /bin/bash

# write privacy settings and test the immediate response;
# test the get response and then cycle back to the original state
# content emulates rails' requests

curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-urlencode @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q "204"
_method=put&authenticity_token=XR2RR3czwS9DvgJKQhLfzNPkKo1lnVd/vTKZrHfQAhE=&repository[privacy_setting]=5&repository[permissable_ip_addresses]=192.168.1.1,192.168.1.2&commit=Update
EOF


curl -f -s -S -X GET \
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"privacy_setting":5' | fgrep -q '192.168.1.2'


initialize_privacy | egrep -q "${STATUS_UPDATED}"


curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"privacy_setting":1' | fgrep '192.168.1.1' | fgrep -q -v '192.168.1.2'
