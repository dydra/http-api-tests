#! /bin/bash

# test with a request for the repository configuration
# the '-v' are for those settings which are not present.

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep '"value":"urn:dydra:baseIRI"' \
  | fgrep '"value":"urn:dydra:skolemize"' \
  | fgrep '"value":"urn:dydra:defaultContextTerm"' \
  | fgrep '"value":"urn:dydra:describeForm"' \
  | fgrep '"value":"urn:dydra:describeObjectDepth"' \
  | fgrep '"value":"urn:dydra:federationMode"' \
  | fgrep -v '"value":"urn:dydra:requestMemoryLimit"' \
  | fgrep '"value":"urn:dydra:namedContextsTerm"' \
  | fgrep '"value":"urn:dydra:prefixes"' \
  | fgrep '"value":"urn:dydra:provenanceRepositoryId"' \
  | fgrep -v '"value":"urn:dydra:requestSolutionLimit"' \
  | fgrep '"value":"urn:dydra:strictVocabularyTerms"' \
  | fgrep '"value":"urn:dydra:undefinedVariableBehavior"' \
  | fgrep -v '"value":"urn:dydra:requestTimeLimit"' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
