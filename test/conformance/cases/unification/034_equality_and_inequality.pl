% Reference 9.1: eq/2 unifies terms and neq/2 succeeds on non-unifiable terms.
answer(eq_variable, X) :- eq(X, pair(a, [b, c])).
answer(eq_nested, true) :- eq(pair(X, X), pair(same, same)).
answer(neq_atoms, true) :- neq(alice, bob).
answer(neq_structures, true) :- neq(pair(a), pair(a, b)).
materialize(answer, 2).
