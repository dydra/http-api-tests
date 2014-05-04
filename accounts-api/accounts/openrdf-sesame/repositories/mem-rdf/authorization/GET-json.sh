#! /bin/bash


${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep '"accessTo"' \
   | fgrep '"agent"' \
   | fgrep '"mode"' \
   | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"

# get with two authorization controls
cat > /dev/null << EOF
[{"ID": {"type":"bnode", "value":"x1iz786s"},
  "accessTo": {"type":"uri", "value":"http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf"},
  "agent": {"type":"uri", "value":"http://dydra.com/users/openrdf-sesame"},
   "mode": [{"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Read"},
            {"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Write"},
            {"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Control"}]},
 {"ID": {"type":"bnode", "value":"xfny0n01"},
  "mode": {"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Read"},
  "accessTo": {"type":"uri", "value":"http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf"},
  "agentClass": {"type":"uri", "value":"urn:dydra:User"}}]
EOF
