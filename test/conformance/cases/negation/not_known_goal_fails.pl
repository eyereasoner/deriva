% Negation fails when its inner goal succeeds.
materialize(answer, 1).
seen(a).
answer(ok) :- not(seen(a)).
