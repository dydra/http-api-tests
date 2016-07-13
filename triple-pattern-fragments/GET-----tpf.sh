#! /bin/bash

# test triple pattern fragment response to verify
# - statement count
# - existence of 

curl_tpf_get > result.nq

fgrep -q example.com/named-subject result.nq 
fgrep -q example.com/default-subject result.nq 
fgrep -c //example.com/ result.nq | fgrep -q 2

fgrep -c http://www.w3.org/ns/hydra/core#variable result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#property result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#mapping result.nq | fgrep -q 3
fgrep -c http://www.w3.org/ns/hydra/core#template result.nq | fgrep -q 1

