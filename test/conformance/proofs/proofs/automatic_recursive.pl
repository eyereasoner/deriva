% Reference 12: automatically tabled recursive proofs still explain the successful derivation path.
materialize(path, 2).
edge(a, b).
edge(b, c).
path(X, Y) :- edge(X, Y).
path(X, Z) :- edge(X, Y), path(Y, Z).
