#! /bin/bash

curl -q -s  -H "Accept: text/plain" https://dydra.com/system/accounts/sparql-12/repositories/exists-tests/views \
  | sort \
  | while read view; do echo; echo $view; \
      curl -s -H "Accept: application/sparql-results+json" --user ":${TOKEN}" "https://dydra.com/sparql-12/exists-tests/${view}" ; \
  done
