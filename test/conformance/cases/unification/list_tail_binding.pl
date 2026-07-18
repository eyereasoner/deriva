materialize(answer, 1).
answer(Tail) :- eq([a, b, c], [a | Tail]).
