#! /bin/bash

# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 

${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep 'baseIRI' \
  | fgrep 'skolemize' \
  | fgrep 'defaultContextTerm' \
  | fgrep 'describeForm' \
  | fgrep 'describeObjectDepth' \
  | fgrep 'describeSubjectDepth' \
  | fgrep 'federationMode' \
  | fgrep -v 'requestMemoryLimit' \
  | fgrep 'namedContextsTerm' \
  | fgrep 'prefixes' \
  | fgrep 'provenanceRepositoryId' \
  | fgrep -v 'requestSolutionLimit' \
  | fgrep 'strictVocabularyTerms' \
  | fgrep 'undefinedVariableBehavior' \
  | fgrep -v 'requestTimeLimit' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"

