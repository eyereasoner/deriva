% Quoted absolute IRI atoms read back in angle-bracket form.
materialize(answer, 1).
item('https://example.org/alice').
item('urn:example:bob').
answer(Iri) :- item(Iri).
