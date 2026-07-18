materialize(answer, 1).
p(a, b) :- not(q(a, b)).
q(a, b) :- not(p(a, b)).
answer(ok).
