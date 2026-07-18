materialize(answer, 1).
answer(X) :- compound_name_arguments(X, pair, [a, b]).
