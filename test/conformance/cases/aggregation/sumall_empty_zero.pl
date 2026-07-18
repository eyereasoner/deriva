materialize(answer, 1).
answer(N) :- sumall(X, missing(X), N).
