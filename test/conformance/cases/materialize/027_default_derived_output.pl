% Reference 11: default output prints new ground binary derivations, not source facts.
parent(pat, jan).
parent(jan, emma).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
