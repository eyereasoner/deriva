materialize(answer, 1).
answer(ok) :- not(compound_name_arguments(X, pair, [a | b])).
