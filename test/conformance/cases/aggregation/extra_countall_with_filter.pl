materialize(answer, 2).
num(1).
num(2).
num(3).
answer(countall_with_filter, N) :- countall((num(X), gt(X, 1)), N).
