#! /bin/bash


# http api tests : environment initialization
#
# environment :
# STORE_URL : host http url
# STORE_ACCOUNT : account name
# STORE_REPOSITORY : individual repository
# STORE_TOKEN : the authentication token

if [[ "" == "${CURL}" ]]
then
  export CURL=curl
fi

if [[ "" == "${STORE_URL}" ]]
then
  export STORE_URL="http://localhost"
fi
STORE_HOST=${STORE_URL#http://}
export STORE_HOST=${STORE_HOST%:*}
export STORE_SITE="dydra.com"
export STORE_ACCOUNT="openrdf-sesame"
export STORE_REPOSITORY="mem-rdf"
export STORE_REPOSITORY_PUBLIC="public"
export STORE_TOKEN=`cat ~/.dydra/token-${STORE_ACCOUNT}`
export STORE_TOKEN_JHACKER=`cat ~/.dydra/token-jhacker`
export STORE_PREFIX="rdf"
export STORE_DGRAPH="sesame"
export STORE_IGRAPH="http://example.org"
export STORE_NAMED_GRAPH="http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_NAMED_GRAPH_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_IS_LOCAL=false
fgrep 127.0.0.1 /etc/hosts | fgrep -q ${STORE_HOST} &&  export STORE_IS_LOCAL=true

export STATUS_OK=200
export STATUS_DELETE_SUCCESS=204
export STATUS_PATCH_SUCCESS=201
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
STORE_ERRORS=0


# provide operators to restore aspects of the store to a known state
# they presumes, that the various PUT operators work


function initialize_account () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/system?auth_token=${STORE_TOKEN} <<EOF
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:baseIRI> <http://www.openrdf.org> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:skolemize> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:defaultContextTerm> <urn:dydra:all> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:describeForm> <urn:rdfcache:simple-concise-bounded-description> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:describeObjectDepth> "2"^^<http://www.w3.org/2001/XMLSchema#integer> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:describeSubjectDepth> "0"^^<http://www.w3.org/2001/XMLSchema#integer> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:federationMode> <urn:rdfcache:none>  <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:requestMemoryLimit> "1000000"^^<http://www.w3.org/2001/XMLSchema#integer> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:namedContextsTerm> <urn:dydra:named> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:prefixes> "cc: <http://creativecommons.org/ns#>"  <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:provenanceRepositoryId> <http://dydra.com/accounts/openrdf-sesame/repository/provenance> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:requestSolutionLimit>  "10000"^^<http://www.w3.org/2001/XMLSchema#integer>  <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:strictVocabularyTerms> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:requestTimeLimit>  "60"^^<http://www.w3.org/2001/XMLSchema#integer>  <http://dydra.com/accounts/openrdf-sesame> .
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:undefinedVariableBehavior> <urn:dydra:error>  <http://dydra.com/accounts/openrdf-sesame> .
EOF
}

function initialize_repository () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/system?auth_token=${STORE_TOKEN} <<EOF
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:baseIRI> <http://www.openrdf.org/mem-rdf> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:skolemize> "false"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:defaultContextTerm> <urn:dydra:default> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeForm> <urn:rdfcache:simple-symmetric-concise-bounded-description> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeObjectDepth> "2"^^<http://www.w3.org/2001/XMLSchema#integer> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:describeSubjectDepth> "2"^^<http://www.w3.org/2001/XMLSchema#integer> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:federationMode> <urn:rdfcache:internal>  <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:namedContextsTerm> <urn:dydra:named> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:prefixes> "dc: <http://purl.org/dc/terms/>"  <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:provenanceRepositoryId> <http://dydra.com/accounts/openrdf-sesame/repository/provenance> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:strictVocabularyTerms> "true"^^<http://www.w3.org/2001/XMLSchema#boolean> <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
<http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> <urn:dydra:undefinedVariableBehavior> <urn:dydra:dynamicBinding>  <http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf> .
EOF

# content
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
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
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/namespaces?auth_token=${STORE_TOKEN} <<EOF
{"default_repository_prefixes":{"cc":"http://creativecommons.org/ns#","cert":"http://www.w3.org/ns/auth/cert#","dbp":"http://dbpedia.org/property/","dc":"http://purl.org/dc/terms/","dc11":"http://purl.org/dc/elements/1.1/","dcterms":"http://purl.org/dc/terms/","doap":"http://usefulinc.com/ns/doap#","exif":"http://www.w3.org/2003/12/exif/ns#","fn":"http://www.w3.org/2005/xpath-functions#","foaf":"http://xmlns.com/foaf/0.1/","geo":"http://www.w3.org/2003/01/geo/wgs84_pos#","geonames":"http://www.geonames.org/ontology#","gr":"http://purl.org/goodrelations/v1#","http":"http://www.w3.org/2006/http#","log":"http://www.w3.org/2000/10/swap/log#","owl":"http://www.w3.org/2002/07/owl#","rdf":"http://www.w3.org/1999/02/22-rdf-syntax-ns#","rdfs":"http://www.w3.org/2000/01/rdf-schema#","rei":"http://www.w3.org/2004/06/rei#","rsa":"http://www.w3.org/ns/auth/rsa#","rss":"http://purl.org/rss/1.0/","sfn":"http://www.w3.org/ns/sparql#","sioc":"http://rdfs.org/sioc/ns#","skos":"http://www.w3.org/2004/02/skos/core#","swrc":"http://swrc.ontoware.org/ontology#","types":"http://rdfs.org/sioc/types#","wot":"http://xmlns.com/wot/0.1/","xhtml":"http://www.w3.org/1999/xhtml#","xsd":"http://www.w3.org/2001/XMLSchema#"}
}
EOF
}

function initialize_privacy () {
${CURL} -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/privacy?auth_token=${STORE_TOKEN} <<EOF
{"permissable_ip_addresses":["192.168.1.1"],"privacy_setting":1}
EOF
}

function run_test() {
  bash $1
  if [[ "0" == "$?" ]]
  then
    echo succeeded
  else
    echo failed
  fi
}

function run_tests() {
  for file in $*; do
    case "$file" in
    *.sh )
      bash $file
      if [[ "0" == "$?" ]]
      then
        echo $file succeeded
      else
        echo $file failed
      fi
      ;;
    * )
      ;;
    esac
  done
}

export -f initialize_account
export -f initialize_repository
export -f initialize_repository_public
export -f initialize_repository_rdf_graphs
export -f initialize_profile
export -f initialize_collaboration
export -f initialize_prefixes
export -f initialize_privacy


