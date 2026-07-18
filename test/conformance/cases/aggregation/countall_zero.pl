materialize(answer, 1).
answer(N) :- countall(missing(X), N).
