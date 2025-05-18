#!/bin/bash
cd /opt/spocq
repository=${1}
output_path=${2}
if [ -z "$output_path" ]; then
    echo "Usage: $0 <repository> <output_path>"
    exit 1
fi
# Run the test with a distinct name for the application
./spocq-listener <<EOF

(in-package :spocq.i)
(initialize-spocq)

(defun test-spo (repository-name &key (start 1000000) (maximum-limit 1000000000) (repeat-count 4))
  (let ((process-start-time (get-universal-time))
	(results '())) ;; List to store results
    (loop with current-limit = start
          with count = 0
          do (loop for repeat from 1 to repeat-count
                   for start-time = (get-universal-time) ;; Record the start time
                   for result = (progn
                                  (format t "Executing query with limit: ~A x~a~%" current-limit repeat)
                                  (format-iso-time *trace-output* start-time)
                                  (sb-ext:gc :full t)
                                  (time (test-sparql (format nil "
  select (count(*) as ?count)
  where { select ?s ?p ?o ?g
          where { {?s ?p ?o} union { graph ?g {?s ?p ?o} } }
          limit ~A
        }
        " current-limit)
                                            :repository-id repository-name)))
                   for end-time = (get-universal-time) ;; Record the end time
                   do (progn
                        (setf count (caar result))
                        ;; Display the ISO start time, end time, and count
                        (format *trace-output* "Start Time: ~/format-iso-time/, End Time: ~/format-iso-time/, Count: ~A~%"
                                start-time  end-time count)
                        (finish-output *trace-output*)
                        ;; Save the result for this step
                        (push (list start-time end-time count) results)
			;; ensure that the intervales are distinct
			(sleep 5)))
          while (and (>= count current-limit) (<= count maximum-limit)) ;; Test the count before increasing the limit
          do (setf current-limit (* 2 current-limit)))
    ;; Generate a timestamped file name
    (let* ((timestamp (multiple-value-bind (second minute hour day month year)
					   (decode-universal-time process-start-time)
                        (format nil "~4,'0D~2,'0D~2,'0D-~2,'0D~2,'0D~2,'0D"
				year month day hour minute second)))
           (file-name "${output_path}"))
      ;; Emit the results as a CSV
      (with-open-file (stream file-name
                              :direction :output
                              :if-exists :supersede
                              :if-does-not-exist :create)
        ;; Write the CSV header
        (format stream "start_time,end_time,count~%")
        ;; Write each result as a CSV row
        (dolist (result (reverse results)) ;; Reverse to preserve order
          (destructuring-bind (start-time end-time count) result
            (format stream "~/format-iso-time/,~/format-iso-time/,~A~%"
                    start-time ;; Format start time
                    end-time   ;; Format end time
                    count))))
      (format t "Results saved @~A to ~A~%" timestamp file-name))))

(test-spo "${repository}")

EOF
