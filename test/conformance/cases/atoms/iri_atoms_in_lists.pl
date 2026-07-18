% IRI atoms can appear anywhere ordinary atoms can appear, including lists.
materialize(answer, 1).
route(['<urn:example:a>', '<urn:example:b>', '<urn:example:c>']).
answer(Route) :- route(Route).
