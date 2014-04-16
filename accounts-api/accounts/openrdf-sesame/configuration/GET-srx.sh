#! /bin/bash

# test as sparql-results+xml, that the the account configuration includes the user's access

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/configuration?auth_token=${STORE_TOKEN} \
  | xmllint --c14n11 - | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
  | fgrep 'urn:dydra:baseIRI' \
  | fgrep 'urn:dydra:skolemize' \
  | fgrep 'urn:dydra:defaultContextTerm' \
  | fgrep 'urn:dydra:describeForm' \
  | fgrep 'urn:dydra:describeObjectDepth' \
  | fgrep 'urn:dydra:describeSubjectDepth' \
  | fgrep 'urn:dydra:federationMode' \
  | fgrep 'urn:dydra:requestMemoryLimit' \
  | fgrep 'urn:dydra:namedContextsTerm' \
  | fgrep 'urn:dydra:prefixes' \
  | fgrep 'urn:dydra:provenanceRepositoryId' \
  | fgrep 'urn:dydra:requestSolutionLimit' \
  | fgrep 'urn:dydra:strictVocabularyTerms' \
  | fgrep 'urn:dydra:undefinedVariableBehavior' \
  | fgrep -q "accounts/${STORE_ACCOUNT}"
