materialize(answer, 1).
seed(a).
p(X) :- seed(X), not(blocked(X)).
blocked(X) :- p(X).
answer(ok).
