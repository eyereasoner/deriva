% Warnings report unstratified negation without changing normal execution.
materialize(answer, 1).
p(a) :- not(q(a)).
q(a) :- not(p(a)).
answer(ok).
