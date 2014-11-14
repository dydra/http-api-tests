#! /bin/bash

# http api tests : run-time environment initialization
#
# environment :
# STORE_URL : host http url
# STORE_ACCOUNT : account name
# STORE_REPOSITORY : individual repository
# STORE_TOKEN : the authentication token

if [[ "" == "${STORE_URL}" ]]
then
  export STORE_URL="http://localhost"
fi
# strip the protocol and possible user authentication to yield the actual host
export STORE_HOST=${STORE_URL#*http://} 
# strip a possible port
export STORE_HOST=${STORE_HOST%:*}
export STORE_SITE="dydra.com"           # the abstract site name
export STORE_ACCOUNT="openrdf-sesame"
export STORE_REPOSITORY="mem-rdf"
export STORE_REPOSITORY_PUBLIC="public"
export STORE_CLIENT_IP="127.0.0.1"
export STORE_PREFIX="rdf"
export STORE_DGRAPH="sesame"
export STORE_IGRAPH="http://example.org"
export STORE_NAMED_GRAPH="http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_NAMED_GRAPH_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_IS_LOCAL=false
fgrep 127.0.0.1 /etc/hosts | fgrep -q ${STORE_HOST} &&  export STORE_IS_LOCAL=true

export STATUS_OK=200
export STATUS_DELETE_SUCCESS=204
export STATUS_PATCH_SUCCESS="201|204"
export POST_SUCCESS="201|204"
export STATUS_POST_SUCCESS="201|204"
export PUT_SUCCESS="201|204"
export STATUS_PUT_SUCCESS="201|204"
export PATCH_SUCCESS=201
export STATUS_CREATED=201
export STATUS_NO_CONTENT=204
export STATUS_UPDATED="201|204"
export DELETE_SUCCESS=204
export STATUS_BAD_REQUEST=400
export STATUS_UNAUTHORIZED=401
export STATUS_NOT_FOUND=404
export STATUS_NOT_ACCEPTABLE=406
export STATUS_UNSUPPORTED_MEDIA=415

if [[ "" == "${CURL}" ]]
then
  export CURL=curl
fi

if [[ "" == "${STORE_CLIENT_IP_AUTHORIZED}" ]]
then 
  export STORE_CLIENT_IP_AUTHORIZED=true
fi

if [[ "" == "${STORE_TOKEN}" ]]
then 
  export STORE_TOKEN=`cat ~/.dydra/token-${STORE_ACCOUNT}@${STORE_HOST}`
fi
if [[ "" == "${STORE_TOKEN_JHACKER}" ]]
then 
  export STORE_TOKEN_JHACKER=`cat ~/.dydra/token-jhacker@${STORE_HOST}`
fi

# indicate whether those put/post operations for which the request specified the default graph, will apply any
# quad statements to the default graph or to that graph from the statement. false implies by statement.
export QUAD_DISPOSITION_BY_REQUEST=false
STORE_ERRORS=0

function grep_patch_success () {
  egrep -q "${STATUS_PATCH_SUCCESS}"
}

function grep_post_success () {
  egrep -q "${STATUS_POST_SUCCESS}"
}

function grep_put_success () {
  egrep -q "${STATUS_PUT_SUCCESS}"
}

# provide operators to restore aspects of the store to a known state
# they presumes, that the various PUT operators work


function initialize_account () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/system?auth_token=${STORE_TOKEN} <<EOF
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:baseIRI> <http://dydra.com/accounts/openrdf-sesame> <http://dydra.com/accounts/openrdf-sesame> .
EOF
}

function initialize_repository_configuration () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/system?auth_token=${STORE_TOKEN} <<EOF
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:baseIRI> <http://www.openrdf.org/mem-rdf> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:skolemize> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:defaultContextTerm> <urn:dydra:default> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeForm> <urn:rdfcache:simple-symmetric-concise-bounded-description> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeObjectDepth> "2"^^<http://www.w3.org/2001/XMLSchema#integer> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeSubjectDepth> "2"^^<http://www.w3.org/2001/XMLSchema#integer> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:federationMode> <urn:rdfcache:internal>  <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:namedContextsTerm> <urn:dydra:named> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:prefixes> "prefix dc: <http://purl.org/dc/terms/>"  <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:provenanceRepositoryId> <http://${STORE_SITE}/accounts/openrdf-sesame/repository/provenance> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:strictVocabularyTerms> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:undefinedVariableBehavior> <urn:dydra:dynamicBinding>  <http://${STORE_SITE}/accounts/openrdf-sesame/repositories/mem-rdf> .
EOF
}

function initialize_repository_content () {
# content
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
}

function initialize_repository () {
  initialize_repository_content;
}

function initialize_repository_public () {
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC}?auth_token=${STORE_TOKEN} <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
}

function initialize_repository_rdf_graphs () {
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
<http://example.com/named-subject> <http://example.com/named-predicate> "rdf-graphs named object" <$STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame> .
EOF
}

function initialize_profile () {
${CURL} -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: " \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} <<EOF 
{
    "name": "mem-rdf",
    "homepage": "http://example.org/test",
    "summary": "a summary",
    "description": "a description",
    "license_url": "http://unlicense.org"
 }
EOF
}

function initialize_collaboration () {
${CURL} -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: " \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/collaborations?auth_token=${STORE_TOKEN} <<EOF
{"collaborator": "jhacker",
 "read": true,
 "write": false
 }
EOF
}

function initialize_prefixes () {
${CURL} -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     -H "Accept: " \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} <<EOF
{"prefixes": "PREFIX foaf: <http://xmlns.com/foaf/0.1/> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#> PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>" }
EOF
}

function initialize_privacy () {
${CURL} -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF
{"permissable_ip_addresses":["192.168.1.1"],"privacy_setting":1}
EOF
}

function run_test() {
  bash -e $1
  if [[ "0" == "$?" ]]
  then
    echo $1 succeeded
  else
    echo $1 failed
    initialize_repository > /dev/null
  fi
}

function run_tests() {
  for file in $*; do
    case "$file" in
    *.sh )
      bash -e $file
      if [[ "0" == "$?" ]]
      then
        echo $file succeeded
      else
        echo $file failed
        initialize_repository > /dev/null
      fi
      ;;
    * )
      if (test -d $file)
      then run_tests `find $file -name '*.sh'`
      fi
      ;;
    esac
  done
}



export -f grep_patch_success
export -f grep_post_success
export -f grep_put_success

export -f initialize_account
export -f initialize_repository
export -f initialize_repository_configuration
export -f initialize_repository_content
export -f initialize_repository_public
export -f initialize_repository_rdf_graphs
export -f initialize_profile
export -f initialize_collaboration
export -f initialize_prefixes
export -f initialize_privacy


