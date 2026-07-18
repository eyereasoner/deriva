materialize(answer, 2).
answer(empty, X) :- length([], X).
answer(nested, X) :- length([[a], [b, c]], X).
