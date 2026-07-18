materialize(answer, 2).
answer(nested_list_binding, Tail) :- eq([a, b | Tail], [a, b, c]).
