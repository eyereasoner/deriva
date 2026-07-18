% Stirling numbers of the second kind and Bell numbers.
%
% The Stirling count S(N,K) is computed with the inclusion-exclusion formula
%   S(N,K) = (1/K!) * sum(I=0..K, (-1)^(K-I) * C(K,I) * I^N)
% instead of the overlapping two-branch recurrence.  Bell numbers use
%   B(0) = 1, B(N) = sum(K=0..N-1, C(N-1,K) * B(K)).
% The table declarations memoize the smaller helper relations used by both formulas.
materialize(stirling_bell_answer, 2).


factorial(0, 1).
factorial(N, Value) :-
  gt(N, 0),
  sub(N, 1, N1),
  factorial(N1, Previous),
  mul(N, Previous, Value).

binomial(0, 0, 1).
binomial(N, 0, 1) :- gt(N, 0).
binomial(N, N, 1) :- gt(N, 0).
binomial(N, K, Value) :-
  gt(N, 0),
  gt(K, 0),
  lt(K, N),
  sub(N, 1, N1),
  sub(K, 1, K1),
  binomial(N1, K1, Left),
  binomial(N1, K, Right),
  add(Left, Right, Value).

signed_term(N, K, I, Term) :-
  binomial(K, I, C),
  pow(I, N, P),
  mul(C, P, Unsigned),
  sub(K, I, D),
  mod(D, 2, 0),
  eq(Term, Unsigned).
signed_term(N, K, I, Term) :-
  binomial(K, I, C),
  pow(I, N, P),
  mul(C, P, Unsigned),
  sub(K, I, D),
  mod(D, 2, 1),
  neg(Unsigned, Term).

stirling2(0, 0, 1).
stirling2(N, 0, 0) :- gt(N, 0).
stirling2(0, K, 0) :- gt(K, 0).
stirling2(N, K, Count) :-
  gt(N, 0),
  gt(K, 0),
  sumall(Term, (between(0, K, I), signed_term(N, K, I, Term)), Sum),
  factorial(K, Factorial),
  div(Sum, Factorial, Count).

bell(0, 1).
bell(N, Count) :-
  gt(N, 0),
  sub(N, 1, N1),
  sumall(Term, (between(0, N1, K), binomial(N1, K, Choose), bell(K, Bell), mul(Choose, Bell, Term)), Count).

stirling_bell_answer(stirling_10_4, Count) :- stirling2(10, 4, Count).
stirling_bell_answer(stirling_12_5, Count) :- stirling2(12, 5, Count).
stirling_bell_answer(bell_10, Count) :- bell(10, Count).
stirling_bell_answer(bell_12, Count) :- bell(12, Count).
