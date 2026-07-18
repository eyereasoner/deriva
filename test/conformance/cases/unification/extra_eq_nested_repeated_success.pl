materialize(answer, 2).
answer(eq_nested_repeated_success, X) :- eq(pair(X, X), pair(a, a)).
