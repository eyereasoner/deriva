materialize(answer, 2).
parent(alice, bob).
parent(bob, clara).
answer(X, Z) :- parent(X, Y), parent(Y, Z).
