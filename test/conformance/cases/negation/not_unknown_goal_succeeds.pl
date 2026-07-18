% Negation succeeds when its inner goal has no solution.
materialize(answer, 1).
answer(ok) :- not(missing(fact)).
