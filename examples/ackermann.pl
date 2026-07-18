% Ackermann-style hyperoperation benchmark adapted from Eyeling ackermann.n3.
% The public ackermann/2 answers are small, but the helper relation exercises
% deeply nested arithmetic recursion: hyper/4 encodes successor, addition,
% multiplication, exponentiation, and then the Ackermann-style offset
% ackermann(X, Y) = hyper(X, Y + 3, 2) - 3.
% Keeping the selected inputs explicit avoids unbounded generation while still
% testing the solver's recursive numeric workload.

materialize(ackermann, 2).

ackermann(X, Y, A) :-
  add(Y, 3, B),
  hyper(X, B, 2, C),
  sub(C, 3, A).

% Successor, addition, multiplication, and exponentiation levels.
hyper(0, Y, _z, A) :- add(Y, 1, A).
hyper(1, Y, Z, A) :- add(Y, Z, A).
hyper(2, Y, Z, A) :- mul(Y, Z, A).
hyper(3, Y, Z, A) :- pow(Z, Y, A).

% Higher levels recurse over the previous hyperoperation.
hyper(X, 0, _z, 1) :- gt(X, 3).
hyper(X, Y, Z, A) :-
  gt(X, 3),
  neq(Y, 0),
  sub(Y, 1, B),
  hyper(X, B, Z, C),
  sub(X, 1, D),
  hyper(D, C, Z, A).

ack_case(0, 0).
ack_case(0, 6).
ack_case(1, 2).
ack_case(1, 7).
ack_case(2, 2).
ack_case(2, 9).
ack_case(3, 4).
ack_case(3, 1000).
ack_case(4, 0).
ack_case(4, 1).
ack_case(4, 2).
ack_case(5, 0).

ackermann([X, Y], A) :-
  ack_case(X, Y),
  ackermann(X, Y, A).
