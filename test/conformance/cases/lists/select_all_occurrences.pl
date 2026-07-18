materialize(answer, 2).
answer(Item, Rest) :- select(Item, [a, b, a], Rest).
