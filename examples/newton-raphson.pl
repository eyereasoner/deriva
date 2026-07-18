% Newton-Raphson root finding, adapted from Eyelet input/newton-raphson.pl.
% Each want_root/1 case names a function, starting point, and tolerance.  The
% recursive finder stops when |f(x)| is below tolerance; otherwise it applies
% x := x - f(x)/f'(x) using the corresponding derivative rule.

materialize(findRoot, 2).

want_root([1, 1.0, 1.0e-15]).
want_root([2, 2.0, 1.0e-15]).
want_root([3, 3.0, 1.0e-15]).

findRoot(Input, Root) :-
  want_root(Input),
  find_root(Input, Root).

% f(1, X) = X^2 - 2
f(1, X, Y) :-
  mul(X, X, Xx),
  sub(Xx, 2, Y).

% f(2, X) = log(X) - 1
f(2, X, Y) :-
  log(X, Lx),
  sub(Lx, 1, Y).

% f(3, X) = sin(X)
f(3, X, Y) :-
  sin(X, Y).

fd(1, X, Y) :-
  mul(2, X, Y).
fd(2, X, Y) :-
  div(1, X, Y).
fd(3, X, Y) :-
  cos(X, Y).

find_root([N, X, Tolerance], X) :-
  f(N, X, Fx),
  abs(Fx, Afx),
  lt(Afx, Tolerance).
find_root([N, X, Tolerance], Root) :-
  f(N, X, Fx),
  abs(Fx, Afx),
  ge(Afx, Tolerance),
  fd(N, X, Fdx),
  div(Fx, Fdx, Step),
  sub(X, Step, Newx),
  find_root([N, Newx, Tolerance], Root).
