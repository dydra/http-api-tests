#! /bin/sh

# test replication
#
# create three replicable repositories
cat <<EOF > /dev/null
(in-package :spocq.i)
(create-repository "openrdf-sesame/replica1" :if-exists nil)
(create-repository "openrdf-sesame/replica2" :if-exists nil)
(create-repository "openrdf-sesame/replica3" :if-exists nil)
(main-metadata-sync :account "openrdf-sesame")
(main-metadata-sync :account "openrdf-sesame" :repository "replica3")

(rlmdb:clear-repository (spocq.i::repository-lmdb-repository (spocq.i::repository "openrdf-sesame/replica1")))
(rlmdb:clear-repository (spocq.i::repository-lmdb-repository (spocq.i::repository "openrdf-sesame/replica1")))
(rlmdb:clear-repository (spocq.i::repository-lmdb-repository (spocq.i::repository "openrdf-sesame/replica3")))
;;; define spocq.i::*authentication-data-key*
(rem-registry "de8.dydra.com" *users*)
(store-authority-properties "de8.dydra.com"
  :name "openrdf-sesame"
  :token "YtGwUWq1kY7nAL1ocIvl")

;;; initialize the server
;;; override the default implementation
(setf (spocq.i::repository "openrdf-sesame/replica1")
      (spocq.i::make-replicable-repository :id "openrdf-sesame/replica1"))
(setf (repository "openrdf-sesame/replica2")
      (make-replicable-repository :id "openrdf-sesame/replica2"))
(setf (repository "openrdf-sesame/replica3")
      (make-replicable-repository :id "openrdf-sesame/replica3"))
(setq spocq.i::*authentication-data-key*
  ;; (spocq.i::rsa-gen-key "spocq")
  #S(spocq.i::RSA-KEY
   :NAME "spocq"
   :NAME-BASE64 "c3BvY3E="
   :LENGTH 2048
   :N 20878296332310867292627883793629499812414452437330187585912693977559259337743774926354414321700605802603058265031877539046062818735541939438169926071735648198590266921194699206440502618360194277242376839845932999084546388018995755212296552375668566958389541352347679094956544202908709738892270059113172442850869190730609766006218925743221560777555812541075522617931476401599268881964745752640882723277026691980855290969579926616440624164322811615700235078213471498429512331220269096582927353638237820393675450131227531740079340464297043556419792552700548721073921936176156049702592440020088339596144914794866466364913
   :E 17
   :D 17193891097197184829222963124165470433753078477801330953104571510931154748730167586409517676694616543320165630026252090979110556605740420713786997941429357340015513935101516993539237450414277640081957397520180116893155848956820033704244219603491761024556092878403971019375977578865996255558340048681436129406359656272720055252585542044108265432501545131267041684901629502970606397331043072099904460148394773288526520279589492625706472076778643574807844322939097877198326819106748287866075964382483861613531514089356469214861784619039306175540818422874634170222459926635171210217545194163345305475804291013015703585009)
)
(setq *exit-on-errors* nil)

EOF

# connect two as recipients from the first with head requests
# post content to the first
# test content from the second and third
# delete one statement from the third
# test that it has been deleted from the second

$CURL -s -L -I \
  -H "Location: https://${STORE_HOST}/${STORE_ACCOUNT}/replica2/replication" \
  -u ":${STORE_TOKEN}" \
  "https://${STORE_HOST}/${STORE_ACCOUNT}/replica1/replication"

$CURL -s -L -I \
  -H "Location: https://${STORE_HOST}/${STORE_ACCOUNT}/replica3/replication" \
  -u ":${STORE_TOKEN}" \
  "https://${STORE_HOST}/${STORE_ACCOUNT}/replica1/replication"

# write context yields the transcription list

# in order to get replication to work
# need to define authority for the target host
# need to define the respective authorization
# --- actually need also to make the authorization specific to active agent
$CURL -s -L -X PATCH --trace-ascii - --data-binary @- \
  -H "Accept: text/turtle" \
  -H 'Content-Type: multipart/related; boundary="part"' \
  -u ":${STORE_TOKEN}" \
  "https://${STORE_HOST}/${STORE_ACCOUNT}/replica1/replication" <<EOF

--part
Content-Type: Application/n-quads
X-HTTP-Method-Override: PUT

<http://example.org/subject> <http://example.org/predicate> "object 1" .
<http://example.org/subject> <http://example.org/predicate> "object 2" .
--part--
EOF


cat <<EOF > /dev/null
(trace spocq.si::replication-propagate tbnl::call-with-open-request-stream
       drakma:http-request)
(trace http:request-header http:request-query-argument dydra:repository-revision-id)
(spocq.i::test-sparql "select * where {?s ?p ?o}" :repository-id "openrdf-sesame/replica1")
(rlmdb:get-revision-records "openrdf-sesame/replica1")
(rlmdb:get-metadata "openrdf-sesame/replica1")

(spocq.i::test-sparql "select * where {graph ?g {?s ?p ?o}}" :repository-id "openrdf-sesame/replica1")
(spocq.i::test-sparql "select * where {?s ?p ?o}" :repository-id "openrdf-sesame/replica2")
(spocq.i::test-sparql "select * where {?s ?p ?o}" :repository-id "openrdf-sesame/replica3")

(rlmdb::dump-repository (repository "openrdf-sesame/replica1") :verbose t :stream *standard-output*)
(rlmdb::dump-repository (repository "openrdf-sesame/replica2") :verbose t :stream *standard-output*)
(rlmdb::dump-repository (repository "openrdf-sesame/replica3") :verbose t :stream *standard-output*)

(trace spocq.si::graph-store-get-graph spocq.si::graph-store-response
       dydra:read-repository-statement-count)
EOF

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica1/service \
  | tr '\n' ' ' | fgrep "object 1" | fgrep -q "object 2"

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica2/service \
  | tr '\n' ' ' | fgrep "object 1" | fgrep -q "object 2"

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica3/service \
  | tr '\n' ' ' | fgrep "object 1" | fgrep -q "object 2"



$CURL -s -L -X DELETE --data-binary @- \
  -H "Accept: text/turtle" \
  -H 'Content-Type: application/n-quads' \
  -u ":${STORE_TOKEN}" \
  "https://${STORE_HOST}/${STORE_ACCOUNT}/replica2/replication" <<EOF
<http://example.org/subject> <http://example.org/predicate> "object 1" .
EOF

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica1/service \
  | tr '\n' ' ' | fgrep -v "object 1" | fgrep -q "object 2"

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica2/service \
  | tr '\n' ' ' | fgrep -v "object 1" | fgrep -q "object 2"

$CURL -L -H "Accept: application/n-quads" -X GET \
  -u ":${STORE_TOKEN}" \
  https://${STORE_HOST}/${STORE_ACCOUNT}/replica3/service \
  | tr '\n' ' ' | fgrep -v "object 1" | fgrep -q "object 2"



