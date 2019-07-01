# HTTP API tests : inference, abstraction, extension functions

This directory comprises tests for three extensions
- pattern-directed entailment :
  a library of pattern BGPs is interpreted as abstract pattern entailments.
- extension functions :
  pattern predicates which bind functions are invoked with the bindings from the
  respective BGP nested-loop context and yield the results to the respective continuation.
- view abstractions :
  pattern predicates which designate views invoke those spaql expression as sub-queries.

