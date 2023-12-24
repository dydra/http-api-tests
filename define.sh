#! /bin/bash

# http api tests : run-time environment initialization
#   intended to be sourced
#
# environment :
# STORE_HOST : http host name
# STORE_ACCOUNT : account name                 : default "openrdf-sesame"
# STORE_REPOSITORY : individual repository     : default "mem-rdf"
# STORE_TOKEN : the authentication token
# STORE_COLLABORTOR : the collaborator account : default "jhacker"
#
# in order to run it behind nginx to target a local host
# define STORE_TOKEN, STORE_TOKEN_ADMIN and STORE_HOST
# source define.sh
# redefine STORE_URL to use http rather than https
#
# this defines several operators for RDF|SPARQL access to the given store
#
# curl_sparql_request
#   curl_sparql_query
#   curl_sparql_update
#   curl_sparql_view
# graph_store_get
# graph_store_update
#
#
# in order for the tests to run, the following must be present for the default settings
#
# openrdf-sesame/mem-rdf
# openrdf-sesame/mem-rdf

export PATH=`pwd`/bin:${PATH}
# export STORE_URL=https://dydra.com:81 # 20170705 server version is just http
# export STORE_URL=http://dydra.com
# export STORE_URL=http://stage.dydra.com

if [[ "" == "${STORE_HOST}" ]]
then
  if [[ "" == "${STORE_URL}" ]]
  then
    export STORE_URL="http://localhost"
  fi
  # strip the protocol and possible user authentication to yield the actual host
  case ${STORE_URL} in
    http:*)   export STORE_HOST=${STORE_URL#*http://}  ;;
    https:*)  export STORE_HOST=${STORE_URL#*https://} ;;
    *) echo "invalid store url: '${STORE_URL}'"; return 1;;
  esac
  # strip a possible port
  export STORE_HOST=${STORE_HOST%:*}
else
  export STORE_URL="https://${STORE_HOST}"
fi


export STORE_SITE="dydra.com"           # the abstract site name
if [[ "" == "${STORE_ACCOUNT}" ]]
then export STORE_ACCOUNT="openrdf-sesame"
fi
if [[ "" == "${STORE_REPOSITORY}" ]]
then export STORE_REPOSITORY="mem-rdf"
fi
if [[ "" == "${STORE_COLLABORATOR}" ]]
then export STORE_COLLABORATOR="jhacker"
fi


export STORE_REPOSITORY_WRITABLE="${STORE_REPOSITORY}-write"
export STORE_REPOSITORY_PROVENANCE="${STORE_REPOSITORY}-provenance"
export STORE_REPOSITORY_PUBLIC="${STORE_REPOSITORY}-public"
export STORE_REPOSITORY_REVISIONED="${STORE_REPOSITORY}-revisioned"
export STORE_REPOSITORY_CLASS_DEFAULT="lmdb-quad-repository"
export STORE_REVISIONED_REPOSITORY_CLASS_DEFAULT="lmdb-revisioned-repository"
if [[ "" == "${GRAPH_STORE_PATCH_LEGACY}" ]]
then export GRAPH_STORE_PATCH_LEGACY=true
fi
export STORE_CLIENT_IP="127.0.0.1"
export STORE_PREFIX="rdf"
export STORE_DGRAPH="sesame"
export STORE_IGRAPH="http://example.org"
# the _url form is used as the curl location while the other is the quad term
export STORE_NAMED_GRAPH="http://${STORE_SITE}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_NAMED_GRAPH_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
# accept json by default for use with jq
export STORE_SPARQL_RESULTS_MEDIA_TYPE="application/sparql-results+json"
export STORE_GRAPH_MEDIA_TYPE="application/n-quads"
export STORE_ACCEPT="Accept: application/sparql-results+json"
export STORE_ACCEPT_GRAPH="Accept: application/n-triples"

export STORE_SPARQL_QUERY_MEDIA_TYPE="application/sparql-query"
export STORE_SPARQL_UPDATE_MEDIA_TYPE="application/sparql-update"

export STORE_GRAPH_CONTENT_TYPE="Content-Type: text/turtle"
export STORE_IS_LOCAL=false
fgrep 127.0.0.1 /etc/hosts | fgrep -q ${STORE_HOST} &&  export STORE_IS_LOCAL=true

export STATUS_OK=200
export STATUS_ACCEPTED='202'
export STATUS_DELETE_SUCCESS='200|204'
export STATUS_PATCH_SUCCESS='200|201|204'
export POST_SUCCESS='200|201|204'
export STATUS_POST_SUCCESS='200|201|204'
export PUT_SUCCESS='201|204'
export STATUS_PUT_SUCCESS='200|201|204'
export STATUS_CREATED=201
export STATUS_NO_CONTENT=204
export STATUS_UPDATED='201|204'
export DELETE_SUCCESS=204
export STATUS_BAD_REQUEST=400
export STATUS_UNAUTHORIZED=401
export STATUS_NOT_FOUND=404
export STATUS_NOT_ACCEPTABLE=406
export STATUS_UNSUPPORTED_MEDIA=415
export STATUS_NOT_IMPLEMENTED=501

if [[ "" == "${CURL}" ]]
then
  export CURL="curl --ipv4 --http1.1 -k"  # ignore certificates
fi
# export CURL="curl -v --ipv4"
# export CURL="curl --ipv4 --trace-ascii /dev/tty"
if [[ "" == "${ECHO_OUTPUT}" ]]
then
  export ECHO_OUTPUT=/dev/null # /dev/tty # 
fi
export RESULT_OUTPUT=

function 1cpl () {
 sed 's/[[:space:]]*//g' | sed 's/\(.\)/\1\
/g'
}
export -f 1cpl

if ! [ -x "$(command -v md5sum)" ]; then
  function md5sum () {
    md5
  }
  export -f md5sum
fi

# define operators to export sparql and graph store url variables of the appropriate pattern
# and define the values for the default repository. these will be overridden by scripts which expect to use a
# different repository than the default.
#
# export SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/sparql"
# export GRAPH_STORE_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/service"

function set_sparql_url() {
  # $1 : account name
  # $2 : repository name
  export SPARQL_URL="${STORE_URL}/${1}/${2}/sparql"
}
function set_graph_store_url() {
  # $1 : account name
  # $2 : repository name
  export GRAPH_STORE_URL="${STORE_URL}/${1}/${2}/service"
}
function set_download_url() {
  # $1 : account name
  # $2 : repository name
  export DOWNLOAD_URL="${STORE_URL}/${1}/${2}"
}
# set the default values - each script can over-ride
set_sparql_url ${STORE_ACCOUNT} ${STORE_REPOSITORY}
set_graph_store_url ${STORE_ACCOUNT} ${STORE_REPOSITORY}
set_download_url ${STORE_ACCOUNT} ${STORE_REPOSITORY}

if [[ "" == "${STORE_CLIENT_IP_AUTHORIZED}" ]]
then 
  export STORE_CLIENT_IP_AUTHORIZED=true
fi

# define a token for the primary account
if [[ "" == "${STORE_TOKEN}" ]]
then
  if [ -f ~/.dydra/${STORE_HOST}.${STORE_ACCOUNT}.token ]
  then 
    export STORE_TOKEN=`cat ~/.dydra/${STORE_HOST}.${STORE_ACCOUNT}.token`
  elif [ -f ~/.dydra/${STORE_ACCOUNT}.token ]
  then
    export STORE_TOKEN=`cat ~/.dydra/${STORE_ACCOUNT}.token`
  elif [ -f ~/.dydra/${STORE_HOST}.token ]
  then
    export STORE_TOKEN=`cat ~/.dydra/${STORE_HOST}.token`
  else
    echo "no STORE_TOKEN"
    return 1
  fi
fi

# and for admin operations - in case different from user account
if [[ "" == "${STORE_TOKEN_ADMIN}" ]]
then
  echo "reuse STORE_TOKEN as STORE_TOKEN_ADMIN"
  export STORE_TOKEN_ADMIN="$STORE_TOKEN"
fi


# and one for another registered user
if [[ "" == "${STORE_TOKEN_COLLABORATOR}" ]]
then
  if [ -f ~/.dydra/${STORE_HOST}.${STORE_COLLABORATOR}.token ]
  then 
    export STORE_TOKEN_COLLABORATOR=`cat ~/.dydra/${STORE_HOST}.${STORE_COLLABORATOR}.token`
  else
    echo "reuse STORE_TOKEN as STORE_TOKEN_COLLABORATOR"
    export STORE_TOKEN_COLLABORATOR="${STORE_TOKEN}"
  fi
fi

# indicate whether those put/post operations for which the request specified the default graph, will apply any
# quad statements to the default graph or to that graph from the statement. false implies by statement.
export QUAD_DISPOSITION_BY_REQUEST=false
STORE_ERRORS=0

function test_bad_request () {
  egrep -q "${STATUS_BAD_REQUEST}"
}

function test_accepted () {
  egrep -q "${STATUS_ACCEPTED}"
}

function test_delete_success () {
  egrep -q "${STATUS_DELETE_SUCCESS}"
}

function test_not_acceptable () {
  egrep -q "${STATUS_NOT_ACCEPTABLE}"
}
function test_not_acceptable_success () {
  egrep -q "${STATUS_NOT_ACCEPTABLE}"
}

function test_unauthorized () {
  egrep -q "${STATUS_UNAUTHORIZED}"
}
function test_unauthorized_success () {
  egrep -q "${STATUS_UNAUTHORIZED}"
}

function test_not_found () {
  egrep -q "${STATUS_NOT_FOUND}|${STATUS_BAD_REQUEST}"
}
function test_not_found_success () {
  egrep -q "${STATUS_NOT_FOUND}"
}

function test_not_implemented () {
  egrep -q "${STATUS_NOT_IMPLEMENTED}"
}

function test_ok () {
  egrep -q "${STATUS_OK}|${STATUS_NO_CONTENT}"
}
function test_success () {
  egrep -q "${STATUS_OK}|${STATUS_NO_CONTENT}"
}
function test_ok_success () {
  egrep -q "${STATUS_OK}"
}

function test_patch_success () {
  egrep -q "${STATUS_PATCH_SUCCESS}"
}

function test_post_success () {
  egrep -q "${STATUS_POST_SUCCESS}"
}

function test_put_success () {
  egrep -q "${STATUS_PUT_SUCCESS}"
}

function test_unsupported_media () {
  egrep -q "${STATUS_UNSUPPORTED_MEDIA}"
}

function test_updated () {
  egrep -q "${STATUS_UPDATED}"
}


# provide operators to restore aspects of the store to a known state
# they presume that the various PUT operators work

function initialize_account () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF
<http://dydra.com/accounts/openrdf-sesame> <urn:dydra:baseIRI> <http://dydra.com/accounts/openrdf-sesame> <http://dydra.com/accounts/openrdf-sesame> .
EOF
}

## in all the following repositories must be present
# openrdf-sesame/collation
# openrdf-sesame/graphql
# openrdf-sesame/ldp
# openrdf-sesame/library
# openrdf-sesame/mem-rdf
# openrdf-sesame/mem-rdf-provenance
# openrdf-sesame/mem-rdf-write
# openrdf-sesame/mem-rdfs
# openrdf-sesame/public # to test anonymous access
# openrdf-sesame/system
# openrdf-sesame/tpf
# schema/foaf (must be part of the installed service)
# schema/foaf__classDescription__view (and the "class" view query

function initialize_repository_configuration () {
# metadata
${CURL} -w "%{http_code}\n" -L -f -s -X POST \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/${STORE_ACCOUNT}/system <<EOF
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


function initialize_repository_rdf_graphs () {
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     -u ":${STORE_TOKEN}" \
     ${GRAPH_STORE_URL} <<EOF
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
     -u ":${STORE_TOKEN}" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile <<EOF 
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
     -u ":${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/collaborations <<EOF
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
     -u ":${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes <<EOF
{"prefixes": "PREFIX foaf: <http://xmlns.com/foaf/0.1/> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#> PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>" }
EOF
}

function initialize_privacy () {
${CURL} -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     --data-binary @- \
     -u ":${STORE_TOKEN}:" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization <<EOF
{"permissable_ip_addresses":["192.168.1.1"],"privacy_setting":1}
EOF
}

## convenience operators,
## but note, some require presence in the respective directory

function run_all_tests() {
  bash run_all.sh | tee /dev/tty > run_all.out 2&>1 
}

function run_test() {
  (cd `dirname "$1"`; bash -e "`basename \"$1\"`")
  if [[ "0" == "$?" ]]
  then
    echo "$1" succeeded
  else
    echo "$1" failed
  fi
}

function run_tests() {
  for file in $@; do
    case "$file" in
    *.sh )
      (cd `dirname $file`; bash -e `basename $file`)
      if [[ "0" == "$?" ]]
      then
        echo $file succeeded
      else
        echo $file failed
      fi
      ;;
    * )
      if (test -d $file)
      then ./run.sh $file  # `find $file -name '*.sh'`
      fi
      ;;
    esac
  done
}


# curl_sparql_request { $accept-header-argument } { $content-type-header-argument } { $url }
function curl_sparql_request () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_SPARQL_RESULTS_MEDIA_TYPE")
  local -a content_media_type=("-H" "Content-Type: $STORE_SPARQL_QUERY_MEDIA_TYPE")
  local -a method=("-X" "POST")
  local -a data=()
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local -a curl_url="${SPARQL_URL}"
  local -a url_args=()
  local -a account=${STORE_ACCOUNT}
  local -a repository=${STORE_REPOSITORY}

  while [[ "$#" > 0 ]] ; do
    # echo "arg $1";
    case "$1" in
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type[1]="${2}"; shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      -X) method[1]="${2}"; shift 2;;
      --data*) data+=("${1}" "${2}"); shift 2;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      query=*) data=(); content_media_type=(); url_args+=("${1}"); method=("-X" "GET"); shift 1;;
      user_id=*) user_id=("${1}"); shift 1;;
      *=*) url_args+=("${1}"); shift 1;;
      *) curl_args+=("${1}"); shift 1;;
    esac
    # echo "curl_args in loop ${curl_args[@]}" > /dev/tty
  done
  # echo "curl_args ${curl_args[@]}" > /dev/tty
  curl_url="${STORE_URL}/${account}/${repository}/sparql"
  url_args+=(${user_id[@]})
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#data[*]} == 0 && ${method[1]} == "POST" ]] ; then data=("--data-binary" "@-"); fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  if [[ ${accept_media_type[1]} != "Accept:" ]]; then curl_args+=("${accept_media_type[@]}"); fi
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -L -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  mkdir -p /tmp/test/
  ${CURL} -L -f -s "${curl_args[@]}" ${curl_url}
}


function curl_sparql_query () {
  curl_sparql_request -H "Content-Type:application/sparql-query" "$@"
}

function curl_sparql_update () {
  curl_sparql_request -H "Content-Type:application/sparql-update" "$@"
}


# curl_sparql_view { accept-header-argument } { content-type-header-argument } { view_name }
# operate with/on a view
# content-type is permitted in order to post to a view
function curl_sparql_view () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_SPARQL_RESULTS_MEDIA_TYPE")
  local -a content_media_type=("-H" "Content-Type: $STORE_SPARQL_QUERY_MEDIA_TYPE")
  local -a method=("-X" "GET")
  local -a data=()
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local graph=""  #  the default is all graphs
  local curl_url=""
  local url_args=()
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local view="sparql" # start out as the default service location

  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      default|DEFAULT) graph="default"; shift 1;;
      --graph) if [[ "" == "${2}" ]] ; then graph=""; else graph="graph=${2}"; fi;  shift 2;;
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      -v) curl_args+=("-v"); shift 1;;
      -w) curl_args+=("${1}" "${2}"); shift 2;;
      -X) method[1]="${2}"; shift 2;;
      --data*) data+=("${1}" "${2}"); shift 2;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      query=*) data=(); content_media_type=(); url_args+=("${1}"); shift 1;;
      --repository) repository="${2}"; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      *=*) url_args+=("${1}"); shift 1;;
      *) view="${1}"; shift 1;;
    esac
  done
  curl_url="${STORE_URL}/${account}/${repository}/${view}"
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph[@]}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#data[*]} == 0 && ${method[1]} == "POST" ]] ; then data=("--data-binary" "@-"); fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  curl_args+=("${accept_media_type[@]}");
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -L -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -L -f -s "${curl_args[@]}" ${curl_url}
}


# curl_graph_store_delete { -H $accept-header-argument } { graph }
function curl_graph_store_delete () {
  curl_graph_store_get -X DELETE "$@"
}

# curl_graph_store_get { -H $accept-header-argument } {--repository $repository} { graph }
function curl_graph_store_get_nofail () {
  local -a curl_args=()
  local -a accept_media_type=("-H" "Accept: $STORE_GRAPH_MEDIA_TYPE")
  local -a content_media_type=()
  local -a method=("-X" "GET")
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local graph=""  #  the default is all graphs
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local curl_url=""
  local url_args=()
  curl_url="${STORE_URL}/${account}/${repository}/service"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      all|ALL) graph="all"; shift 1;;
      default|DEFAULT) graph="default"; shift 1;;
      graph=*) graph="${1}"; shift 1;;
      --graph=*) graph="${1}"; shift 1;;
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
          Content-Type:*) content_media_type=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      --repository) repository="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      --url) curl_url="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      -X) method[1]="${2}"; shift 2;;
      *=*) url_args+=("${1}"); shift 1;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  curl_args+=("${accept_media_type[@]}");
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=(${content_media_type[@]}); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -s "${curl_args[@]}" ${curl_url}
}

function curl_graph_store_get () {
  curl_graph_store_get_nofail -f "$@"
}

# curl_graph_store_get_code { $accept-header-argument } { graph }
function curl_graph_store_get_code () {
  curl_graph_store_get -w "%{http_code}\n" "$@"
}

function curl_graph_store_get_code_nofail () {
  curl_graph_store_get_nofail -w "%{stderr}%{http_code}\n" "$@"
}

function curl_graph_store_update () {
  local -a curl_args=()
  local -a accept_media_type=()
  local -a content_encoding=()
  local -a content_media_type=("-H" "Content-Type: $STORE_GRAPH_MEDIA_TYPE")
  local -a data=("--data-binary" "@-")
  local -a method=("-X" "POST")
  local -a user=(-u ":${STORE_TOKEN}")
  local -a user_id=("user_id=$0")
  local -a output="/dev/stdout"
  local graph=""  #  the default is all graphs
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local curl_url="${GRAPH_STORE_URL}"
  local url_args=()
  curl_url="${STORE_URL}/${account}/${repository}/service"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      all|ALL) graph="all"; shift 1;;
      --data*) data[0]="${1}";  data[1]="${2}"; shift 2;;
      default|DEFAULT) graph="default"; shift 1;;
      graph=*) if [[ "graph=" == "${1}" ]] ; then graph=""; else graph="${1}"; fi;  shift 1;;
      --graph=*) if [[ "--graph=" == "${1}" ]] ; then graph=""; else graph="${1}"; fi;  shift 1;;
      -H) case "$2" in
          Accept:*) accept_media_type=("-H" "${2}"); shift 2;;
          Content-Type:*) content_media_type[1]="${2}"; shift 2;;
          Content-Encoding:*) content_encoding=("-H" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      -o) curl_args+=("-o" "${2}"); output="${2}"; shift 2;;
      --repository) repository="${2}";
        shift 2; curl_url="${STORE_URL}/${account}/${repository}/service";;
      --url) curl_url="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      user_id=*) user_id=("${1}"); shift 1;;
      -X) method[1]="${2}"; shift 2;;
      -v) curl_args+=("-v"); shift 1;;
      -w) curl_args+=("${1}" "${2}"); output="/dev/stdout"; shift 2;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  url_args+=(${user_id[@]})
  if [[ "${graph}" ]] ; then url_args+=(${graph}); fi
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  if [[ ${#accept_media_type[*]} > 0 ]] ; then curl_args+=("${accept_media_type[@]}"); fi
  if [[ ${#content_encoding[*]} > 0 ]] ; then curl_args+=("${content_encoding[@]}"); fi
  if [[ ${#content_media_type[*]} > 0 ]] ; then curl_args+=("${content_media_type[@]}"); fi
  if [[ ${#data[*]} > 0 ]] ; then curl_args+=("${data[@]}"); fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=("${user[@]}"); fi

  echo  ${CURL} -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL}  -f -s "${curl_args[@]}" ${curl_url} # > $output
}


function curl_graph_store_clear () {
  curl_graph_store_update -X DELETE "$@" -o /dev/null <<EOF
EOF
}

function clear_repository_content () {
  curl_graph_store_update -X PUT "$@" -o /dev/null <<EOF
EOF
}

function clear_repository_revisions () {
  local -a URL="${STORE_URL}/system/accounts/${1}/repositories/${2}/revisions"
  ${CURL} -f -s -X DELETE  -w "%{http_code}\n" \
     -H "Accept: text/turtle" \
     -u ":${STORE_TOKEN_ADMIN}" ${URL}
}
# clear_repository_revisions test test-revisioned-repository

# initialize_repository_content { --repository $repository-name } { --url $url }
# clear everything, insert one statement each in the default and the named graphs
function initialize_repository_content () {
  curl_graph_store_update -X PUT "$@" -o /dev/null <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
EOF
  curl_graph_store_update -X POST graph=${STORE_NAMED_GRAPH} -o /dev/null "$@" <<EOF
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
}

function initialize_repository () {
  initialize_repository_content "$@"
}

function initialize_repository_public () {
  initialize_repository_content --repository "${STORE_REPOSITORY_PUBLIC}"
}

# to setup for tests, this must be done once the repositories have been created
function initialize_all_repositories () {
  curl_graph_store_update -X PUT --repository collation  -o /dev/null \
  -H "Content-Type: text/turtle" \
  --data-binary @extensions/sparql-protocol/collation/collation.ttl

  initialize_repository
}

function curl_download () {
  ${CURL} -f -s -S -X GET \
     -H "${1}" \
     -u ":${STORE_TOKEN}:" \
     ${DOWNLOAD_URL}.${2}
}


# curl_tpf_get { -H $header-argument } {--repository $repository} { query }
function curl_tpf_get () {
  local -a curl_args=()
  local -a method=("-X" "GET")
  local -a user=(-u ":${STORE_TOKEN}")
  local query=""  #  the default no query args
  local revision=""
  local curl_url="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/tpf"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      -H) case "$2" in
          Accept*) curl_args+=("${1}" "${2}"); shift 2;;
          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      --repository) curl_url="${STORE_URL}/${STORE_ACCOUNT}/${2}/tpf"; shift 2;;
      --revision) revision="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); e<e user[1]="${2}"; fi; shift 2;;
      *) query="${1}"; shift 1;;
    esac
  done

  # where an empty array is possible, must be conditional due to unset variable constraint
  # curl_args+=("${accept_media_type[@]}");
  if [[ "${query}" ]]
    then if [[ "${revision}" ]]
      then curl_url="${curl_url}?${query}&revision=${revision}";
      else curl_url="${curl_url}?${query}";
      fi
    else if [[ "${revision}" ]]
      then curl_url="${curl_url}?revision=${revision}";
      fi
    fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -f -s "${curl_args[@]}" ${curl_url}
}

# curl_ldp_get { -H $header-argument } {--repository $repository} { --path $path }
function curl_ldp_get () {
  local -a curl_args=()
  local -a method=("-X" "GET")
  local -a user=(-u ":${STORE_TOKEN}")
  local revision=""
  local repository="${STORE_REPOSITORY}"
  local path=""
  local curl_url=""
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      -H) case "$2" in
          Accept:*) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --head) method=(); curl_args+=("${1}"); shift 1;;
      --repository) repository="${2}"; shift 2;;
      --path) path="${2}"; shift 2;;
      --revision) revision="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done

  curl_url="http://ldp.${STORE_HOST}/${STORE_ACCOUNT}/${repository}"
  if [[ "${path}" ]]
  then curl_url="${curl_url}/${path}"
  fi
  # where an empty array is possible, must be conditional due to unset variable constraint
  # curl_args+=("${accept_media_type[@]}");
  if [[ "${query}" ]]
    then if [[ "${revision}" ]]
      then curl_url="${curl_url}?${query}&revision=${revision}";
      else curl_url="${curl_url}?${query}";
      fi
    else if [[ "${revision}" ]]
      then curl_url="${curl_url}?revision=${revision}";
      fi
    fi
  if [[ ${#method[*]} > 0 ]] ; then curl_args+=(${method[@]}); fi
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi

  echo ${CURL} -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -f -s "${curl_args[@]}" ${curl_url}
}


function create_account() {
  local -a newAccount=${1}
  local -a URL="${STORE_URL}/system/accounts"

  ${CURL} -w "%{http_code}\n" -f -s -X POST -H "Content-Type: application/json" --data-binary @- \
     -u ":${STORE_TOKEN_ADMIN}" ${URL} <<EOF
{"account": {"name": "${newAccount}"} }
EOF
}

function create_repository() {
  local -a curl_args=()
  local -a account="${STORE_ACCOUNT}"
  local -a repository="new"
  local -a class="${STORE_REPOSITORY_CLASS_DEFAULT}"
  local -a temporal_properties=""
  local -a time_series_properties=""
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      --class) class="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      --temporal_properties) temporal_properties=", \"temporal-properties\": \"${2}\" "; shift 2 ;;
      --event_properties) event_properties=", \"event-properties\": \"${2}\" "; shift 2 ;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  local -a URL="${STORE_URL}/system/accounts/${account}/repositories"
  echo "create repository: ${account}/${repository}, class: ${class}" > $ECHO_OUTPUT
  ${CURL} -w "%{http_code}\n" -f -s -X POST "${curl_args[@]}" \
     -H "Content-Type: application/json" \
     -H "Accept: application/n-quads" \
     --data-binary @- \
     -u ":${STORE_TOKEN_ADMIN}" ${URL} <<EOF
{"repository": {"name": "${repository}", "class": "${class}"
                 ${temporal_properties}
                 ${event_properties}
               }
 }
EOF
}

function create_typed_repository() {
  local -a newRepo=${1}
  local -a repoClass=${2}
  local -a URL="${STORE_URL}/system/accounts/${STORE_ACCOUNT}/repositories"

  echo "$testName : $newRepo $repoClass"
  ${CURL} -w "%{http_code}\n" -f -s -X POST \
    -H "Content-Type: application/json" \
    -H "Accept: application/n-quads" \
    --data-binary @- \
    -u ":${STORE_TOKEN_ADMIN}" ${URL} <<EOF
{"repository": { "name": "${newRepo}", "class": "lmdb-repository", "storageclass": "${repoClass}" } }
EOF
}

function delete_repository () {
  local -a curl_args=()
  local -a account="${STORE_ACCOUNT}"
  local -a repository="new"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  local -a URL="${STORE_URL}/system/accounts/${account}/repositories/${repository}"
  echo "delete repository: ${account}/${repository}" > $ECHO_OUTPUT
  ${CURL} -w "%{http_code}\n" -f -s -X DELETE "${curl_args[@]}" \
     -H "Accept: application/n-quads" \
     -u ":${STORE_TOKEN_ADMIN}" ${URL} \
     | tee ${ECHO_OUTPUT}
}

function delete_revisions () {
  local -a curl_args=()
  local -a account="${STORE_ACCOUNT}"
  local -a repository="new"
  local url_args=()
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      *=*) url_args+=("${1}"); shift 1;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done
  local -a curl_url="${STORE_URL}/system/accounts/${account}/repositories/${repository}/revisions"
  if [[ ${#url_args[*]} > 0 ]] ; then curl_url=$(IFS='&' ; echo "${curl_url}?${url_args[*]}") ; fi
  ${CURL} -w "%{http_code}\n" -f -s -X DELETE "${curl_args[@]}" \
     -o /dev/null \
     -H "Accept: application/n-quads" \
     -u ":${STORE_TOKEN_ADMIN}" ${curl_url}
  ##echo -e "\n\npress key to continue ${url_args[*]}" > /dev/tty; read
}

# repository_revision_count { --account $account } {--repository $repository}
# returns the revision count from dydra's repository introspection,
# 0 for an unrevisioned repository, >=1 for revisioned repositories
#
# the temporary file is used because as of "GNU bash, version 3.2.57(1)-release (arm64-apple-darwin22)"
# bash saw the "|" after inline data in the function definition as a syntax error

function curl_repository_revision_count () {
  local -a curl_args=()
  local -a account="${STORE_ACCOUNT}"
  local -a repository="new"
  while [[ "$#" > 0 ]] ; do
    case "$1" in
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      *) curl_args+=("${1}"); shift 1;;
    esac
  done

cat > /tmp/curl_repository_revision_count.rq <<EOF
prefix dydra: <http://dydra.com/sparql-functions#>
select (dydra:repository-revision-count() as ?revisionCount)
where {}
EOF

curl_sparql_request  --account "${account}" --repository "${repository}" revision-id=HEAD --data-binary @/tmp/curl_repository_revision_count.rq
}


function repository_revision_count () {
  curl_repository_revision_count "$@" | tee $ECHO_OUTPUT | jq -r '.results.bindings[].revisionCount.value'
}

# repository_is_revisioned { --account $account } {--repository $repository}
# tests whether the repository is revisioned or not,
# regardless of whether it has actually stored multiple revisions or not

function repository_is_revisioned () {
  repository_revision_count "$@" | egrep -q '^[1-9][0-9]*$'
}

# repository_list_revisions { --account $account } {--repository $repository}
# returns list of revision UUIDs

function repository_list_revisions () {
  local -a user=(-u ":${STORE_TOKEN}")
  local account=${STORE_ACCOUNT}
  local repository=${STORE_REPOSITORY}
  local -a curl_args=()
  local curl_url=""

  local -a accept_media_type=("-H" "Accept:text/plain")
  local -a method=("-X" "GET")
  local -a user=(-u ":${STORE_TOKEN}")
  local revision=""
  local repository="${STORE_REPOSITORY}"
  local path=""

  while [[ "$#" > 0 ]] ; do
    case "$1" in
      -H) case "$2" in
          Accept:*) accept_media_type[1]="${2}"; shift 2;;
#          Content-Type:*) content_media_type[1]="${2}"; shift 2;;
#          *) curl_args+=("${1}" "${2}"); shift 2;;
          esac ;;
      --account) account="${2}"; shift 2;;
      --repository) repository="${2}"; shift 2;;
      -u|--user) if [[ -z "${2}" ]]; then user=(); else user[1]="${2}"; fi; shift 2;;
    esac
  done
  if [[ ${#user[*]} > 0 ]] ; then curl_args+=(${user[@]}); fi
  curl_url="${STORE_URL}/system/accounts/${account}/repositories/${repository}/revisions";
  curl_args+=("${accept_media_type[@]}");

  echo ${CURL} -f -s "${curl_args[@]}" ${curl_url} > $ECHO_OUTPUT
  ${CURL} -f -s "${curl_args[@]}" ${curl_url}
}

# repository_number_of_revisions { --account $account } {--repository $repository}
# returns the number of actual revisions,
# that is, it returns at least 1,
# and, incidentally, also 1 for an unrevisioned repository
# sed in order to remove whitespace

function repository_number_of_revisions () {
  repository_list_revisions "$@" | wc -l | sed -e 's/ //g'
}

# repository_has_revisions { --account $account } {--repository $repository}
# tests whether the repository contains more than one revision
# this rather than whether it has the revision metadata sub-databases,
# as the tests require more than one revision

function repository_has_revisions () {
  repository_list_revisions "$@" | wc | fgrep -q -v "1      37"
}

function set_store_features () {
  # capture the service description
  bash sparql-protocol/service-description.sh
  if `fgrep -q statementAnnotation service-description.ttl`
    then export STORE_STATEMENT_ANNOTATION="true"
    else export STORE_STATEMENT_ANNOTATION="false"
  fi
  if `fgrep -q statementCollation service-description.ttl`
    then export STORE_STATEMENT_COLLATION="true"
    else export STORE_STATEMENT_COLLATION="false"
  fi
  if `fgrep -q indexedTimes service-description.ttl`
    then export STORE_INDEXED_TIMES="true"
    else export STORE_INDEXED_TIMES="false"
  fi
  if `fgrep -q indexedEvents service-description.ttl`
    then export STORE_INDEXED_EVENTS="true"
    else export STORE_INDEXED_EVENTS="false"
  fi
}

export -f create_account
export -f create_repository
export -f create_typed_repository
export -f delete_repository
export -f repository_has_revisions

export -f curl_sparql_request
export -f curl_sparql_update
export -f curl_sparql_query
export -f curl_sparql_view
export -f curl_graph_store_clear
export -f curl_graph_store_delete
export -f curl_graph_store_get
export -f curl_graph_store_get_nofail
export -f curl_graph_store_get_code
export -f curl_graph_store_get_code_nofail
export -f curl_graph_store_update
export -f curl_download
export -f curl_tpf_get
export -f set_store_features
export -f set_sparql_url
export -f set_graph_store_url
export -f set_download_url
export -f test_accepted
export -f test_bad_request
export -f test_delete_success
export -f test_not_found
export -f test_not_found_success
export -f test_not_acceptable
export -f test_not_acceptable_success
export -f test_not_implemented
export -f test_ok_success
export -f test_ok
export -f test_patch_success
export -f test_post_success
export -f test_put_success
export -f test_success
export -f test_unauthorized
export -f test_unauthorized_success
export -f test_unsupported_media
export -f test_updated

export -f clear_repository_content
export -f clear_repository_revisions
export -f initialize_account
export -f initialize_repository
export -f initialize_all_repositories
export -f initialize_repository_configuration
export -f initialize_repository_content
export -f initialize_repository_public
export -f initialize_repository_rdf_graphs
export -f initialize_profile
export -f initialize_collaboration
export -f initialize_prefixes
export -f initialize_privacy

export -f delete_revisions
export -f repository_revision_count
export -f curl_repository_revision_count
export -f repository_is_revisioned
export -f repository_number_of_revisions
export -f repository_list_revisions

# this records a script to clear environment variables prior to sourcing this file when changing STORE_HOST
  cat /dev/null > ./reset_environment.sh
  printenv | egrep '^STORE[^=]*=.*' \
  | sed -e 's/\(STORE[^=]*\)=.*/\1/' \
  | while read variable; do echo "unset $variable" >> ./reset_environment.sh ; done

set_store_features

