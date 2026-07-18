% Stratified negation is portable and produces ordinary answers.
materialize(open, 1).
place(a).
place(b).
closed(b).
open(X) :- place(X), not(closed(X)).
