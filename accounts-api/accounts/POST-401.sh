#! /bin/bash


# account creation requires admin authorization


${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     ${STORE_URL}/accounts?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "401"
{"repository": {"name": "${STORE_ACCOUNT}-anon"} }
EOF

