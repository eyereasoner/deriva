materialize(answer, 2).
answer(lower, X) :- lowercase("HelloWorld", X).
answer(upper, X) :- uppercase(helloWorld, X).
