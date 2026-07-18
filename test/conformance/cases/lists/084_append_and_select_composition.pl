% Reference 9.7: relational list predicates compose and preserve enumeration order.
materialize(answer, 2).
answer(split, pair(A, B)) :- append(A, B, [x, y, z]).
answer(select_middle, Rest) :- select(y, [x, y, z], Rest).
answer(select_duplicate, pair(Value, Rest)) :- select(Value, [a, b, a], Rest).
answer(rebuild, Whole) :- append([a, b], [c, d], Whole).
answer(no_select_rejected, ok) :- not(select(z, [a, b], Rest)).
