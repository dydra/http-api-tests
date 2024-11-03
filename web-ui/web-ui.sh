#! /bin/bash

# enumerate all web-ui pages
# 

if [[ "$#" == 0 ]]
then
  OUTPUT="/dev/null"
else
  OUTPUT="$2"
fi

echo "ui tests @${STORE_HOST}"

function http_get () {
  echo -n "${STORE_URL}$1 "
  echo $CURL -w "%{http_code}\n" -s -L -u ":${STORE_TOKEN}" -o $OUTPUT ${STORE_URL}$1 > $ECHO_OUTPUT
  $CURL -w "%{http_code}\n" -s -L -u ":${STORE_TOKEN}" -o $OUTPUT ${STORE_URL}$1 | egrep -q '(200|301|302)'
  if [ "$?" != "0" ]
  then
    echo " failed"
  else
    echo " succeeded"
  fi
}

http_get /
http_get /account
http_get /login
http_get /logout
http_get /legal
http_get /${STORE_ACCOUNT}
http_get /${STORE_ACCOUNT}/${STORE_REPOSITORY}
http_get /${STORE_ACCOUNT}/${STORE_REPOSITORY}/@query
http_get /${STORE_ACCOUNT}/${STORE_REPOSITORY}/_endpoint
# was seen to fail with a rails "no database" error
http_get /${STORE_ACCOUNT}/${STORE_REPOSITORY}/_logs # || echo "? no database for logs?"
http_get /${STORE_ACCOUNT}/${STORE_REPOSITORY}/_sidebar

http_get /${STORE_ACCOUNT}/_repositories/new
http_get "/${STORE_ACCOUNT}/@settings#profile"
http_get "/${STORE_ACCOUNT}/@settings#account-password"
http_get "/${STORE_ACCOUNT}/@settings#account-settings"
http_get "/${STORE_ACCOUNT}/@settings#account-repository"
http_get "/${STORE_ACCOUNT}/@settings#account-admin"
