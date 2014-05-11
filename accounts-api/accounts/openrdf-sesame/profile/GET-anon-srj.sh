#! /bin/bash

# test anonymous access; that, as configured, it succeed for the profile only

${CURL} -w "%{http_code}\n" -L -f -s -S -X GET \
    -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}-anon/profile \
 | fgrep -q "${GET_SUCCESS}"


${CURL} -w "%{http_code}\n" -L -f -s -S -X GET \
    -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}-anon/configuration \
 | fgrep -q "${STATUS_UNAUTHORIZED}"

