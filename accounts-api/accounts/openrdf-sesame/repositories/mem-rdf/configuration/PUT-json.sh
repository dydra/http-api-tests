#! /bin/bash

# cycle the prefixes to test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

curl -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"undefinedVariableBehavior": {"type":"uri", "value":"urn:dydra:error"},
 "strictVocabularyTerms": false,
 "provenanceRepositoryId": false,
 "prefixes": "PREFIX cc-not: <http://creativecommons.org/ns#> PREFIX xsd-not: <http://www.w3.org/2001/XMLSchema#>",
 "namedContextsTerm": {"type":"uri", "value":"http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"},
 "federationMode": {"type":"uri", "value":"urn:dydra:none"},
 "describeSubjectDepth": 1,
 "describeObjectDepth": 1,
 "describeForm": {"type":"uri", "value":"urn:dydra:simple-concise-bounded-description"},
 "defaultContextTerm": {"type":"uri", "value":"http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"},
 "skolemize": true,
 "baseIRI": {"type":"uri", "value":"http://www.dydra.com"}}
EOF

curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/prefixes?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"cc-not":' | fgrep -v '"cc":' | fgrep '"xsd-not":' | fgrep -q -v '"xsd":'

initialize_prefixes | fgrep -q "204"

curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/prefixes?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"cc":"http://creativecommons.org/ns#"' | fgrep -q 'xsd":"http://www.w3.org/2001/XMLSchema#"'
