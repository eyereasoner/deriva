materialize(answer, 1).
answer(ok) :- not(holds((p(a), q(b)), r(c))).
