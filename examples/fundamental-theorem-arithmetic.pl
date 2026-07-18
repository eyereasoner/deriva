% Adapted from Eyeling's fundamental-theorem-arithmetic.n3.
% Compute a prime factorization by repeated smallest-divisor decomposition,
% then check product reconstruction and primality of the distinct factors.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
%
% The goal is not to be a production factorizer; it is a readable encoding of
% divisibility, primality, two factorization strategies, and agreement between
% normalized factor lists.
materialize(n, 2).
materialize(factorsSmallest, 2).
materialize(factorsLargest, 2).
materialize(product, 2).
materialize(expectedFactorsMatched, 2).
materialize(productReconstructsInput, 2).
materialize(distinctPrimeCount, 2).
materialize(smallestPrimeFactor, 2).
materialize(largestPrimeFactor, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
case(fta, 202692987).
expected_factors(fta, [3, 3, 7, 829, 3881]).

% A divides B in positive integers.
% Derivation rules: each rule below contributes one logical step toward the displayed results.
divides(A, B) :-
  gt(A, 0),
  gt(B, 0),
  mod(B, A, 0).

smallest_divisor_from(N, D, D) :-
  divides(D, N).

smallest_divisor_from(N, D, N) :-
  mul(D, D, D2),
  gt(D2, N).

smallest_divisor_from(N, D, S) :-
  not(divides(D, N)),
  mul(D, D, D2),
  le(D2, N),
  add(D, 1, D1),
  smallest_divisor_from(N, D1, S).

trial_prime(2).
trial_prime(3).
% trial_prime/1 is the bounded primality test used by the factorization rules.
trial_prime(P) :-
  gt(P, 3),
  smallest_divisor_from(P, 2, P).

factor_smallest(N, []) :-
  lt(N, 2).

factor_smallest(N, [N]) :-
  ge(N, 2),
  smallest_divisor_from(N, 2, N).

% factor_smallest/2 repeatedly removes the least divisor, producing ascending factors.
factor_smallest(N, Factors) :-
  ge(N, 2),
  smallest_divisor_from(N, 2, D),
  neq(D, N),
  div(N, D, Q),
  factor_smallest(D, Left),
  factor_smallest(Q, Right),
  append(Left, Right, Factors).

factor_largest(N, Factors) :-
  factor_smallest(N, Smallest),
  reverse(Smallest, Factors).

product([], 1).
product([X|Rest], P) :-
  product(Rest, P0),
  mul(X, P0, P).

all_expected_primes(true) :-
  trial_prime(3),
  trial_prime(7),
  trial_prime(829),
  trial_prime(3881).

n(case, N) :-
  case(fta, N).

factorsSmallest(case, Factors) :-
  case(fta, N),
  factor_smallest(N, Factors).

factorsLargest(case, Factors) :-
  case(fta, N),
  factor_largest(N, Factors).

product(case, Product) :-
  case(fta, N),
  factor_smallest(N, Factors),
  product(Factors, Product).

expectedFactorsMatched(case, true) :-
  case(fta, N),
  expected_factors(fta, Factors),
  factor_smallest(N, Factors).

productReconstructsInput(case, true) :-
  case(fta, N),
  factor_smallest(N, Factors),
  product(Factors, N).

distinctPrimeCount(case, 4) :-
  all_expected_primes(true).

smallestPrimeFactor(case, 3) :-
  case(fta, N),
  factor_smallest(N, [3|_]).

largestPrimeFactor(case, 3881) :-
  case(fta, N),
  factor_largest(N, [3881|_]).
