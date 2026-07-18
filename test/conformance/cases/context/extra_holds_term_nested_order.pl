materialize(answer, 2).
answer(holds_term_nested_order, X) :- holds((a, (b, c)), X).
