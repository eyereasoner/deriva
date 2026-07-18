materialize(answer, 1).
answer(ok) :- not_matches("abc", "x|y").
