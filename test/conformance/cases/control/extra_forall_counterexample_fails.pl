materialize(answer, 1).
answer(forall_counterexample_fails) :- forall(member(X, [1, 2, 3]), lt(X, 3)).
