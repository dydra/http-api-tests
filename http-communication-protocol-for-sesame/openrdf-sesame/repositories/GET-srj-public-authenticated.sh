#! /bin/bash

# retrieve a repository list authenticated a user
# if remote, authorize just public-authenticated repositories, but
# if local, authorize both public-authenticated and private-ip repositories

if $STORE_CLIENT_IP_AUTHORIZED
then
curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN}_READ \
  | json_reformat -m \
  | fgrep '"value":"mem-rdf-writebyip"' \
  | fgrep '"value":"mem-rdf-readbyip"' \
  | fgrep -q '"value":"mem-rdf-byuser"' 

else
curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN}_READ \
  | json_reformat -m \
  | fgrep -q '"value":"mem-rdf-byuser"' 

fi
