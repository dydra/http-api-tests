#! /bin/bash

# test with a request for the repository configuration
# the '-v' are for those settings which are not present.

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'urn:dydra:baseIRI' \
  | fgrep 'urn:dydra:skolemize' \
  | fgrep 'urn:dydra:defaultContextTerm' \
  | fgrep 'urn:dydra:describeForm' \
  | fgrep 'urn:dydra:describeObjectDepth' \
  | fgrep 'urn:dydra:describeSubjectDepth' \
  | fgrep 'urn:dydra:federationMode' \
  | fgrep -v 'urn:dydra:requestMemoryLimit' \
  | fgrep 'urn:dydra:namedContextsTerm' \
  | fgrep 'urn:dydra:prefixes' \
  | fgrep 'urn:dydra:provenanceRepositoryId' \
  | fgrep -v 'urn:dydra:requestSolutionLimit' \
  | fgrep 'urn:dydra:strictVocabularyTerms' \
  | fgrep 'urn:dydra:undefinedVariableBehavior' \
  | fgrep -v 'urn:dydra:requestTimeLimit' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
