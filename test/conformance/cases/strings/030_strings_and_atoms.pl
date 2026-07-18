% Reference 9.6: atom and string built-ins.
answer(str_concat, X) :- str_concat("v", "ia", X).
answer(contains, true) :- contains("via", "vi").
materialize(answer, 2).
