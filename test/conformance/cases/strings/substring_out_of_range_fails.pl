materialize(answer, 1).
answer(ok) :- not(substring("abc", 2, 5, Text)).
