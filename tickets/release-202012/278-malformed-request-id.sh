#! /bin/bash
#
# test that malformed user id does not compromise the response headers

${CURL} -u ":${STORE_TOKEN}" \
    "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql?user_id=" -Is \
  | tr '\n' '.' | tr '\r' '.' | fgrep -q "..Client-Request-Id: .."
