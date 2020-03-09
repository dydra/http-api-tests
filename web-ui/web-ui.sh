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
  echo $CURL -w "%{http_code}\n" -s -L -u "${STORE_TOKEN}:" -o $OUTPUT ${STORE_URL}$1 > $ECHO_OUTPUT
  $CURL -w "%{http_code}\n" -s -L -u "${STORE_TOKEN}:" -o $OUTPUT ${STORE_URL}$1 | egrep -q '(200|301|302)'
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
http_get /openrdf-sesame
http_get /openrdf-sesame/mem-rdf
http_get /openrdf-sesame/mem-rdf/@query
http_get /openrdf-sesame/mem-rdf/_endpoint
http_get /openrdf-sesame/mem-rdf/_logs
http_get /openrdf-sesame/mem-rdf/_sidebar

http_get /openrdf-sesame/_repositories/new
http_get "/openrdf-sesame/@settings#profile"
http_get "/openrdf-sesame/@settings#account-password"
http_get "/openrdf-sesame/@settings#account-settings"
http_get "/openrdf-sesame/@settings#account-repository"
http_get "/openrdf-sesame/@settings#account-admin"
