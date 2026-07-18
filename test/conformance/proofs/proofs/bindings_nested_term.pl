% Reference 12: proof bindings preserve nested compound terms.
materialize(answer, 1).
source(pair(a, [b, c])).
answer(Term) :- source(Term).
