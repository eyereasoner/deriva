materialize(answer, 2).
answer(once_member, X) :- once(member(X, [a, b, c])).
