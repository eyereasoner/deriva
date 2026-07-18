% A direct negative self-dependency is reported as unstratified.
materialize(answer, 1).
p(a) :- not(p(a)).
answer(ok).
