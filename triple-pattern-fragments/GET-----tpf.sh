#! /bin/bash

# test triple pattern fragment response to verify
# - statement count
# - existence of 

subject=''
predicate=''
object=''
$CURL -f -s -X GET "${STORE_URL}/${STORE_ACCOUNT}/tpf/ldf?$subject&$predicate&$object" > result.nq

fgrep -c example.org/subject result.nq | fgrep -q 12

fgrep -c http://www.w3.org/ns/hydra/core#variable result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#property result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#mapping result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#template result.nq | fgrep -q 1

