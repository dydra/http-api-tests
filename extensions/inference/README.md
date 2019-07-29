# HTTP API tests : inference, abstraction, extension functions

This directory comprises tests SPARQL abstraction extensions.
It is intended to cover the following mechanisms:

- pattern-directed entailment :
  a library of pattern BGPs is interpreted as entailment rules.
- extension functions :
  pattern predicates which bind functions are invoked with the bindings from the
  respective BGP nested-loop context and yield the results to the respective continuation.
- view abstractions :
  pattern predicates which designate views invoke those SPARQL expression as sub-queries.


## Pattern-Directed entailment

The library's construct and n3 rules are are compiled into filter which activated
BGP transformations. These tests cover

- test different rule formats for simple rdfs entailment

They should include also

- the full set of standard rdfs entailment rules
- published spin examples
- a class subtyping use-case

### rule formats

rule-format.sh uses simplified SPIN, spin and N3 rules.

### RDFS entailment

### SPIN

### class subtyping

## Extension Functions

## View Abstractions



