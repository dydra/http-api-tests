#! /bin/bash

# requires bin/frame script
# for test in 0001 0002 0003 0004 0005 0006 0007 0008 0009 0010  0011 0012 0013 0014 0015 0016 0017 0018 0019 0020  0021 ; do 
for test in 0014 0015 0016  0021 ; do 
  echo $test;
  frame $test | json_reformat > result.json 
  echo ""; echo "frame: ";
  curl https://raw.githubusercontent.com/json-ld/json-ld.org/master/test-suite/tests/frame-${test}-frame.jsonld;
  echo ""; echo "expected: ";
  cat frame-${test}-out.jsonld ;
  json_reformat < frame-${test}-out.jsonld | diff - result.json
  done
