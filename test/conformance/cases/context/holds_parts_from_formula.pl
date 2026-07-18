materialize(answer, 3).
answer(Name, Left, Right) :- holds((edge(a, b), label(a, "A")), Name, [Left, Right]).
