#! /bin/bash

STORE_ACCOUNT=json-ld curl_sparql_request \
  --repository "i18n-kanji-tag" \
  -H "Accept: application/ld+json" \
  'query=select%20*%20where%20%20%7b?s%20?p%20?o%7d' \
  | fgrep -q language

STORE_ACCOUNT=json-ld curl_sparql_request \
  --repository "i18n-kanji-tag" \
  -H 'Accept: application/ld+json;profile="http://www.w3.org/ns/json-ld#expanded"' \
  'query=select%20*%20where%20%20%7b?s%20?p%20?o%7d' \
  | fgrep -q language


# (describe (mime:mime-type "application/ld+json;profile=\"http://www.w3.org/ns/json-ld#expanded\""))