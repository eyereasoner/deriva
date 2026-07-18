materialize(answer, 1).
answer(Bag) :- findall(X, missing(X), Bag).
