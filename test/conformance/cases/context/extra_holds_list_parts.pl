materialize(answer, 3).
answer(holds_list_parts, Name, Args) :- holds(([a, b], tail), Name, Args).
