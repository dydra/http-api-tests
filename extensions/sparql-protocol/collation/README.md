
# SPARQL protocol collations tests

The SPARQL specification defines the order relation among a subset of possible argument combinations only.
It delegates the definition of comparisaon operators to the XPath specification -
in particular [XQuery 1.0 and XPath 2.0 Functions and Operators](http://www.w3.org/TR/xpath-functions/), whereby
SPOCQ implements [XPath and XQuery Functions and Operators 3.0](http://www.w3.org/TR/xpath-functions-30/),
but SPARQL is explicitly incomplete, in that it does not define how to supply the collation argument to `fn:compare`
and indicates that the order between two plain strings, even if they share the same language tag.
At the same time, the ["Operator Extensibility" rules](http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#operatorExtensibility)
permit an implemntation to define results for combinations which the specification does not cover.

SPOCQ chooses to augment the standard definitions with the following:
- plain literals which share a language tag are ordered according to the collation rules for the respective language.
- blank nodes are ordered lexicographically by label.
- the partial order specified in [SPARQL 1.1 Query Language](http://www.w3.org/TR/2013/REC-sparql11-query-20130321/#modOrderBy)
  applies to the = and < operators in general, not just in the context of a sort operation.

This directory comprises tests which demonstrate this ordering.
The target repository is the "collation" repository of the test account, in which, the tests expect to
the content which is present here as "collation.ttl"
The repository combines statements about the location city for several nodes with an arbitrary numeric value.
The scripts validate the results of queries which specify variaous order combinations agains the
respective expected results.

for the particular initial case, danish, see also the [ICU page](http://demo.icu-project.org/icu-bin/locexp?d_=en&x=col&_=da).

