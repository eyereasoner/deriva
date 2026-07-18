materialize(answer, 2).
answer(once_preserves_binding, X) :- once(member(X, [a, b])).
