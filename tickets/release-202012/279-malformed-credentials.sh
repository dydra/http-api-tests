#! /bin/bash
#
# test that malformed user credentials does not cause an error

${CURL} -u ":${STORE_TOKEN}" \
    "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql?user_id=" -Is \
  | tr '\n' '.' | tr '\r' '.' | fgrep -q "..Client-Request-Id: .."
