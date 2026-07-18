materialize(answer, 1).
answer(Parts) :- split("abc", ",", Parts).
