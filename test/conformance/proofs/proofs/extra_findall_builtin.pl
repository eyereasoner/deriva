materialize(answer, 2).
item(a).
item(b).
answer(findall_builtin, Bag) :- findall(X, item(X), Bag).
