% Preserve RDF 1.2 base-direction metadata while deriving display labels.
rdf(S, iri("https://example.org/displayLabel"), Label, G) :-
  rdf(S, iri("https://example.org/label"), Label, G).
