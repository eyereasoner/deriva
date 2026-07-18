materialize(answer, 1).
p(X) :- q(X), not(r(X)).
q(a).
r(X) :- p(X).
answer(ok).
