#! /bin/bash

# reset core repository contents and configuration for http api tests
#
# environment :
# STORE_URL : host http url
# STORE_ACCOUNT : account name
# STORE_REPOSITORY : individual repository
# STORE_TOKEN : the authentication token

source ./define.sh

initialize_account | fgrep -q "${PUT_SUCCESS}"
initialize_repository | fgrep -q "${PUT_SUCCESS}"
initialize_repository_public | fgrep -q "${PUT_SUCCESS}"
initialize_about | fgrep -q "${PUT_SUCCESS}"
initialize_collaboration | fgrep -q "${PUT_SUCCESS}"
initialize_prefixes | fgrep -q "${PUT_SUCCESS}"
initialize_privacy | fgrep -q "${PUT_SUCCESS}"
