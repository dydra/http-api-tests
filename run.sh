#! /bin/bash

# run http api tests :
# 
# incorporate the standard function and environment definitions and then run
# a group of test scripts -- either as specified by shell arguments, or
# hard-wired as the default. 
#
# environment :
# STORE_URL : host http url
# STORE_ACCOUNT : account name
# STORE_REPOSITORY : individual repository
# STORE_TOKEN : the authentication token

set -e
if [[ "$STATUS_OK" == "" ]] ; then
  source ./define.sh
fi
VERBOSE=""

while [[ "$#" > 0 ]] ; do
  case "$1" in
    -v) VERBOSE=-v; CURL="$CURL -v"; shift;;
     *) break ;;
  esac
done

STORE_ERRORS="0"
SCRIPT_PATTERN='*.sh' 
SCRIPT_ROOT='.'
if [[ "$#" == "0" ]] ; then
  echo "test: "`pwd`
  SCRIPTS=`find . -mindepth 2 -name "${SCRIPT_PATTERN}"`
elif [[ "$#" == "1" ]] ; then
  echo "test: $1"
  SCRIPTS=`find $1 -name "${SCRIPT_PATTERN}"`
else
  SCRIPTS=$@
fi
## echo $SCRIPTS

## osx lacks truncate
cat /dev/null > failed.txt

# iterate over all '.sh' scripts in the current wd tree, run each, record if it succeeds
# report and total failures.
#
# nb. the outer binding scope includes the loop for the "for in do" form,
# but not the "while read do" due to the pipe
#   find ./*/ -name '*.sh*' | while read file; do
# this limits the test complement to the number of arguments the shell permits

# echo "STORE_URL        : '${STORE_URL}'"
# echo "STORE_ACCOUNT    : '${STORE_ACCOUNT}'"
# echo "STORE_REPOSITORY : '${STORE_REPOSITORY}'"
# echo "CURL             : '${CURL}'"
# echo "SPARQL_URL       : '${SPARQL_URL}'"
# echo "GRAPH_STORE_URL  : '${GRAPH_STORE_URL}'"

EXPECTED_FAILURES=""
UNEXPECTED_FAILURES=""
WD_PREFIX=`pwd`/

set +e     # allow failure in order to record it
for script_pathname in $SCRIPTS
do
  script_pathname=`echo -n "${script_pathname}" | sed 's.//./.g'`
  if [[ "/" == "${script_pathname:0:1}" ]]
  then
    script_pathname=${script_pathname#$WD_PREFIX}
  fi
  if [[ "./" == "${script_pathname:0:2}" ]]
  then
    script_pathname="${script_pathname:2}"
  fi
  echo -n "  ${script_pathname} :  ";
  script_filename=`basename $script_pathname`
  script_directory=`dirname $script_pathname`
  script_tag=`basename $script_directory`"/${script_filename}"

  egrep -v '^#'  known-to-fail.txt | fgrep -q "${script_pathname}"
  if [ $? -eq 0 ]
  then
    EXPECTED=" KNOWN TO FAIL"; EXPECTED_FAILURES="${EXPECTED_FAILURES} ${script_tag}";
    ENTRY="${script_pathname}  : ${EXPECTED}"
    echo "${ENTRY}" >> failed.txt
    echo "${EXPECTED}"
  else
    ( cd $script_directory;
      # -u caused curl_args=() to fail unless something was added to it
      # bash -e -u $script_filename;
      bash -e $script_filename;
    )
    if [[ $? == "0" ]]
    then
      echo "   ok"
    else
      EXPECTED=" FAILED"; UNEXPECTED_FAILURES="${UNEXPECTED_FAILURES} ${script_tag}"
      (( STORE_ERRORS = $STORE_ERRORS + 1))
      ENTRY="${script_pathname}  : ${EXPECTED}"
      echo "${ENTRY}" >> failed.txt
      echo "${EXPECTED}"
    fi
  fi
done

if [[ "${STORE_ERRORS}" != "0" ]]
then
  echo "${STORE_ERRORS} errors"
  if [[ "${UNEXPECTED_FAILURES}" != "" ]]
  then
    echo "new: ${UNEXPECTED_FAILURES}"
  fi
fi
if [[ "${EXPECTED_FAILURES}" != "" ]]
then
  echo "expected failures: ${EXPECTED_FAILURES}"
fi

exit ${STORE_ERRORS}
