materialize(answer, 1).
answer(neq_same_iri_fails) :- neq('<urn:example:a>', 'urn:example:a').
