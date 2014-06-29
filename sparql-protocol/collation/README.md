
# SPARQL protocol collations tests

The SPARQL specification defines the order relation among a subset of possible argument combinations only.
It delegates the definition to the XPath specification (), which is incomplete.
It is even explicit, in that it does not specify the
order between tow plain strings, even if they share the same language tag.
At the same time, the extension ruules () prmit an imlemntation to define results
for combinations which the specification does not cover.

SPOCQ chooses to augment the standard definitions with the following:
- plain literals which share a language tag are ordered according to the collation rules for the respective language.
- blank nodes are order lexicographically by label.
- the partial order specified in () applies to the = and < operators in general. not just in th context of a ort operation.

Thie directory comprises tests which demonstrate this ordering.
The target repository is "system/collation", for which the intended content is present here as "collation.ttl"
The repository combines statements about the location city for several nodes with an arbitrary numeric value.
The scripts validate the results of queries which specify variaous order combinations agains the
respective expected results.
