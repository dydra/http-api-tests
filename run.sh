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
source ./define.sh
export CURL="curl -v"
set -v
#SCRIPT_PATTERN='*.sh*' 
SCRIPT_PATTERN=math-operators.sh
SCRIPT_ROOT='.'

echo "SCRIPT_PATTERN: '${SCRIPT_PATTERN}' SCRIPT_ROOT: '${SCRIPT_ROOT}'"
# iterate over all '.sh' scripts in the current wd tree, run each, record if it succeeds
# report and total failures.
#
# nb. the outer binding scope includes the loop for the "for in do" form,
# but not the "while read do" due to the pipe
#   find ./*/ -name '*.sh*' | while read file; do
# this limits the test complement to the number of arguments the shell permits

function expand_test_path () {
  path=$1;
  if [[ $path =~ .*/.* ]] ; then     # if it is a path, 
    if [[ $path =~ .*\.sh ]] ; then  # if the leaves are constrained, expand that
      ls $path
    else                           # otherwise look for all shell scripts from that root
      find $path -name '*.sh*';
    fi
  else                             # if not a path, then use as a leaf pattern
    find $SCRIPT_ROOT -name $path;
  fi
}

echo script patterh :  $SCRIPT_PATTERN

if [[ "$#" == "0" ]] ; then
  SCRIPTS=`expand_test_path $SCRIPT_PATTERN`
else 
  SCRIPTS="";
  for script_pattern in $@; do
    expanded_pattern=`expand_test_path $script_pattern`
    SCRIPTS="${SCRIPTS} ${expanded_pattern}"
  done
fi
echo "run scripts: $SCRIPTS"

## osx lacks truncate
cat /dev/null > failed.txt

EXPECTED_FAILURES=""
UNEXPECTED_FAILURES=""
WD_PREFIX=`pwd`/
set +e     # allow failure in order to record it
for script_pathname in $SCRIPTS
do
  script_pathname=`echo -n ${script_pathname} | sed 's.//./.g'`
  if [[ "/" == "${script_pathname:0:1}" ]]
  then
    script_pathname=${script_pathname#$WD_PREFIX}
  fi
  if [[ "./" == "${script_pathname:0:2}" ]]
  then
    script_pathname="${script_pathname:2}"
  fi
  echo -n "${script_pathname} :  ";
  script_filename=`basename $script_pathname`
  script_directory=`dirname $script_pathname`
  script_tag=`basename $script_directory`"/${script_filename}"
  ( cd $script_directory;
    bash -e -u $script_filename;
  )
  if [[ $? == "0" ]]
  then
    echo "   ok"
  else
    fgrep -q "${script_pathname}" known-to-fail.txt
    if [ $? -eq 0 ]
    then EXPECTED=" KNOWN TO FAIL"; EXPECTED_FAILURES="${EXPECTED_FAILURES} ${script_tag}";
    else EXPECTED=" FAILED"; UNEXPECTED_FAILURES="${UNEXPECTED_FAILURES} ${script_tag}"
    fi
    ENTRY="${script_pathname}  : ${EXPECTED}"
    (( STORE_ERRORS = $STORE_ERRORS + 1))
    echo "${ENTRY}" >> failed.txt
    echo "${EXPECTED}"
    echo "${script_filename}" | egrep -q -e '^.*GET.*sh$' # allow bash 2.0
    if [[ $? != 0 ]]
    then
      initialize_repository | egrep -q "${STATUS_UPDATED}"
    fi
  fi
done

if [[ "${STORE_ERRORS}" != "0" ]]
then
  echo "${STORE_ERRORS} errors"
  if [[ "${EXPECTED_FAILURES}" != "" ]]
  then
    echo "expected: ${EXPECTED_FAILURES}"
  fi
  if [[ "${UNEXPECTED_FAILURES}" != "" ]]
  then
    echo "new: ${UNEXPECTED_FAILURES}"
  fi
fi

exit ${STORE_ERRORS}
