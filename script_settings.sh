#! /bin/bash


# echo the environment settings for http api tests
#

if [[ "" == "${STORE_URL}" ]]
then
  export STORE_URL="http://localhost"
fi
STORE_HOST=${STORE_URL#http://}
export STORE_HOST=${STORE_HOST%:*}
export STORE_ACCOUNT="openrdf-sesame"
export STORE_REPOSITORY="mem-rdf"
export STORE_REPOSITORY_PUBLIC="public"
export STORE_TOKEN=`cat ~/.dydra/token-${STORE_ACCOUNT}`
export STORE_TOKEN_JHACKER=`cat ~/.dydra/token-jhacker`
export STORE_PREFIX="rdf"
export STORE_DGRAPH="sesame"
export STORE_IGRAPH="http://example.org"
export STORE_NAMED_GRAPH="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/graph-name"
export STORE_IS_LOCAL=false
fgrep 127.0.0.1 /etc/hosts | fgrep -q ${STORE_HOST} &&  export STORE_IS_LOCAL=true


echo STORE_URL=${STORE_URL}
echo STORE_HOST=${STORE_HOST}
echo STORE_ACCOUNT=${STORE_ACCOUNT}
echo STORE_REPOSITORY=${STORE_REPOSITORY}
echo STORE_REPOSITORY_PUBLIC=${STORE_REPOSITORY_PUBLIC}
echo STORE_TOKEN=${STORE_TOKEN}
echo STORE_TOKEN_JHACKER=${STORE_TOKEN_JHACKER}
echo STORE_PREFIX=${STORE_PREFIX}
echo STORE_DGRAPH=${STORE_DGRAPH}
echo STORE_IGRAPH=${STORE_IGRAPH}
echo STORE_NAMED_GRAPH=${STORE_NAMED_GRAPH}
echo STORE_IS_LOCAL=${STORE_IS_LOCAL}
