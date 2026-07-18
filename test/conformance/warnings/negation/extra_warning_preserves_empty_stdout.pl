materialize(answer, 1).
p(a) :- not(q(a)).
q(a) :- not(p(a)).
