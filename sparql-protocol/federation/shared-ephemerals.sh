#! /bin/bash
# federated subselects must share ephemeral terms

curl_sparql_request \
     -H "Content-Type: application/sparql-update" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee ${ECHO_OUTPUT} \
   | jq '.results.bindings | .[].count.value' | fgrep -q '"1"'
select (count(*) as ?count) where {
 { ?s1 <http://example.com/default-predicate> ?o1
    bind (concat(?o1, '++') as ?o_plus)
 }
 { service  <http://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}> {
     ?s2 <http://example.com/default-predicate> ?o2
      bind (concat(?o2, '++') as ?o_plus)
   }
 }
}
EOF

cat > /dev/null <<EOF

(in-package :spocq.i)
(initialize-spocq)

(trace initiate-task terminate-task finalize-task close-task
       run-service-task
       complete-field send-response-message
       transaction-close
       setf-transaction-lmdb-transaction
       destroy-transaction
       task-run-algebra-thread
       get-task-transaction)
(trace call-with-task-transaction
       call-with-revision-transaction)
(trace finalize-task :print (backtrace-thread (bt:current-thread)))

(test-sparql "
select * where { 
 { ?s1 <http://example.com/default-predicate> ?o1
    bind (concat(?o1, '++') as ?o_plus)
 }
 { service  <http://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}> {
     ?s2 <http://example.com/default-predicate> ?o2
      bind (concat(?o2, '++') as ?o_plus)
   }
 }
}"
             :repository-id "${STORE_ACCOUNT}/${STORE_REPOSITORY}"
             :response-content-type mime:application/sparql-results+json
             )

(defmethod transaction-close :around ((transaction t) (disposition t))
  (call-next-method))
  (multiple-value-prog1 (call-next-method)
    (print (cons :tc transaction))))

;;; works 8252cdbdf6a715feb86642b43dee6a6315f36895
(test-sparql "
select (count(*) as ?count) where {
# { ?s1 <http://example.com/default-predicate> ?o1
#    bind (concat(?o1, '++') as ?o_plus)
# }
# { ?s2 <http://example.com/default-predicate> ?o2
#    bind (concat(?o2, '++') as ?o_plus)
# }

 { service  <http://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}> {
     ?s2 <http://example.com/default-predicate> ?o2
      bind (concat(?o2, '++') as ?o_plus)
   }
 }
}"
             :repository-id "${STORE_ACCOUNT}/${STORE_REPOSITORY}")
             :response-content-type mime:application/sparql-results+json
             )

(expand-query "
select (count(*) as ?count) where {
 { ?s1 <http://example.com/default-predicate> ?o1
    bind (concat(?o1, '++') as ?o_plus)
 }
 { service  <http://localhost/${STORE_ACCOUNT}/${STORE_REPOSITORY}> {
     ?s2 <http://example.com/default-predicate> ?o2
      bind (concat(?o2, '++') as ?o_plus)
   }
 }
}"
             :repository-id "${STORE_ACCOUNT}/${STORE_REPOSITORY}"
             :agent (system-agent)
             )

(test-sparql "
select (count(*) as ?count) where {
 { ?s1 <http://example.com/default-predicate> ?o1
    bind (concat(?o1, '++') as ?o_plus)
 }
}"
             :repository-id "${STORE_ACCOUNT}/${STORE_REPOSITORY}"
             :response-content-type mime:application/sparql-results+json
             )

EOF
