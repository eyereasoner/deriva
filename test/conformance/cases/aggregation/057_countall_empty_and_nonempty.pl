item(a).
item(b).
answer(counts, counts(C, Z)) :- countall(item(X), C), countall(missing(X), Z).
materialize(answer, 2).
