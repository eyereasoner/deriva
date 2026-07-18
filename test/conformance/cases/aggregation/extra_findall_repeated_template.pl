materialize(answer, 2).
item(a).
item(b).
answer(findall_repeated_template, Bag) :- findall(pair(X, X), item(X), Bag).
