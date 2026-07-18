materialize(answer, 1).
p(a) :- not(q(a)).
q(a) :- not(r(a)).
r(a) :- not(p(a)).
answer(ok).
