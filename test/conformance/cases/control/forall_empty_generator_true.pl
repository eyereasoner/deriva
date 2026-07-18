materialize(answer, 1).
answer(ok) :- forall(missing(X), fail(X)).
