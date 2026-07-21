% Project an RDF 1.2 triple term into an ordinary asserted relationship.
rdf(S, iri("https://example.org/knows"), O, G) :-
  rdf(
    _,
    iri("https://example.org/claims"),
    triple(S, iri("https://example.org/knows"), O),
    G
  ).
