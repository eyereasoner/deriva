% Reference 9.9: holds/3 enumerates nested comma contexts.
context(((ready, name(a, "A")), route(a, b, 7))).
answer(parts, exposed(Name, Args)) :- context(C), holds(C, Name, Args).
materialize(answer, 2).
