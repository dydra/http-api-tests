#! /bin/bash

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     'query=ask%20%7B%20bind%20(%27test%20literal%27%20as%20%3Fl)%20filter%20(regex(%3Fl%2C%20%27test%27))%20%7D' \
   | jq '.boolean' | fgrep -q true

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     'query=ask%20%7B%20filter%20(regex(%27test%20literal%27%2C%20%27test%27))%20%7D' \
   |  jq '.boolean' | fgrep -q true

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     'query=ask%20%7B%20bind%20(%27test%20literal%27%20as%20%3Fl)%20filter%20(regex(str(%3Fl)%2C%20%27test%27))%20%7D' \
   |  jq '.boolean' | fgrep -q true

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     'query=ask%20%7B%20bind%20(%27test%20literal%27%20as%20%3Fl)%20filter%20(regex(str(%3Fl)%2C%20%27no%27))%20%7D' \
   |  jq '.boolean' | fgrep -q false

