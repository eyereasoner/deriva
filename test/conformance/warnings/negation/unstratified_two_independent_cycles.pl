materialize(answer, 1).
p(a) :- not(q(a)).
q(a) :- not(p(a)).
r(a) :- not(s(a)).
s(a) :- not(r(a)).
answer(ok).
