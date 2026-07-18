materialize(answer, 1).
answer(ok) :- not(arg(0, pair(a, b), X)).
