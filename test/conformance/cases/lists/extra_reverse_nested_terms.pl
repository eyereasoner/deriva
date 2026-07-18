materialize(answer, 2).
answer(reverse_nested_terms, X) :- reverse([box(a), [b, c], '<urn:example:d>'], X).
