materialize(answer, 1).
item(a).
answer(X) :- item(X), not(missing(X)).
