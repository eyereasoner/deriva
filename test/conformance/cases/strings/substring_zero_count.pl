materialize(answer, 1).
answer(Text) :- substring("abcdef", 2, 0, Text).
