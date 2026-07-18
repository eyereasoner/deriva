materialize(answer, 2).
answer(join_iri_and_atom, X) :- join(['<urn:example:a>', path, 7], "/", X).
