materialize(answer, 1).
item(a).
item(b).
blocked(b).
answer(X) :- item(X), not(blocked(X)).
