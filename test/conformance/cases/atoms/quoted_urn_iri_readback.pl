% Quoted absolute IRI atoms use canonical angle-bracket read-back.
materialize(answer, 1).
seed('urn:example:quoted').
answer(X) :- seed(X).
