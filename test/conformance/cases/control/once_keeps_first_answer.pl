materialize(answer, 1).
choice(a).
choice(b).
answer(X) :- once(choice(X)).
