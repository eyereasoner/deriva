materialize(answer, 2).
answer(select_structured_duplicate, Rest) :- select(box(a), [box(a), box(b), box(a)], Rest).
