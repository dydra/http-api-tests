#! /bin/bash
set -o errexit

# the protocol target is the default graph, the statements include quads and the content type is n-triples:
# - triples are added to the document graph.
# - quads are added to the document graph.
# - statements are removed from the default graph
# with a protocol target, the effect is as for PUT.

initialize_repository --repository "${STORE_REPOSITORY}-write"

# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object" .

curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default \
     --data-binary @- <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF

# rdfcache/dydrad:
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdfcache-sesame/mem-rdf/graph-name> .
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <http://dydra.com/openrdfcache-sesame/mem-rdf/graph-name-two> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .

# rlmdb:
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" .

if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' \
   | fgrep '"default object PATCH1"' | fgrep '"named object PATCH1"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
else
# rlmdb:
curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' \
   | fgrep '"default object PATCH1"' | fgrep '"named object PATCH1"' | fgrep -v  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
fi

curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default \
     --data-binary @- <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH2" <${STORE_NAMED_GRAPH}-two> .
EOF

# rdfcache/dydrad:
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdfcache-sesame/mem-rdf/graph-name> .
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH2" <http://dydra.com/openrdfcache-sesame/mem-rdf/graph-name-two> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH2"

# rdlmb:
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH2" .
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH2" .

if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PATCH1"' | fgrep -v '"named object PATCH1"' \
   | fgrep '"default object PATCH2"' | fgrep '"named object PATCH2"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
else
# rlmdb
curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PATCH1"' | fgrep -v '"named object PATCH1"' \
   | fgrep '"default object PATCH2"' | fgrep '"named object PATCH2"' | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
fi
