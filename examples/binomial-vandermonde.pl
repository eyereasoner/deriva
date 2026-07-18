% Binomial coefficients and Vandermonde's identity.
%
% choose(N,K,C) is computed by a multiplicative recurrence, then vandermonde/5 checks
% the finite convolution sum: sum_i C(R,i) C(S,N-i) = C(R+S,N).  Memoization keeps
% the binomial-row prefixes shared across both sides of the identity.
% choose_step/5 uses the multiplicative recurrence
%   C(N, I+1) = C(N, I) * (N-I) / (I+1)
% and is cached automatically because row sums and identities reuse prefixes.
materialize(binomial_answer, 2).


choose(N, K, C) :-
  ge(K, 0),
  le(K, N),
  choose_step(N, K, 0, 1, C).

choose_step(_n, K, K, Acc, Acc).
choose_step(N, K, I, Acc, C) :-
  lt(I, K),
  add(I, 1, I1),
  sub(N, I, Factor),
  mul(Acc, Factor, Numerator),
  div(Numerator, I1, Nextacc),
  choose_step(N, K, I1, Nextacc, C).

symmetric(N, K) :-
  choose(N, K, C),
  sub(N, K, Otherk),
  choose(N, Otherk, C).

vandermonde_sum(N, M, R, Sum) :-
  sumall(Product,
    (between(0, R, K),
     sub(R, K, Rk),
     choose(N, K, A),
     choose(M, Rk, B),
     mul(A, B, Product)),
    Sum).

vandermonde(N, M, R, Sum) :-
  add(N, M, Totaln),
  choose(Totaln, R, Sum),
  vandermonde_sum(N, M, R, Sum).

binomial_answer(choose_24_12, C) :- choose(24, 12, C).
binomial_answer(symmetry_24_7, true) :- symmetric(24, 7).
binomial_answer(vandermonde_12_10_8, Sum) :- vandermonde(12, 10, 8, Sum).
binomial_answer(row_12_sum, Sum) :- sumall(C, (between(0, 12, K), choose(12, K, C)), Sum).
