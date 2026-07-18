% Memoize interval computations reused across width, midpoint, gradient, step,
% objective, and contraction report relations.
% Output declarations: materialize/2 selects the relations written to this example's golden output.
%
% This is a proof-friendly optimization trace: every numeric fact needed to
% justify the step is materialized, so proof output can certify why the update
% is accepted.
materialize(eta, 2).
materialize(etaLeHalf, 2).
materialize(xBounds, 2).
materialize(midpoint, 2).
materialize(width, 2).
materialize(gradientBounds, 2).
materialize(stepBounds, 2).
materialize(objectiveBounds, 2).
materialize(widthContractsAt, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.

% Adapted from Eyeling's gd-step-certified.n3.
% One-dimensional gradient descent over certified interval bounds.

max_k(10).
target(1.0).
% Derivation rules: each rule below contributes one logical step toward the displayed results.
eta(Eta) :- div(1.0, 5, Eta).
x_bounds(0, 0.0, 2.0).

index(0). index(1). index(2). index(3). index(4). index(5).
index(6). index(7). index(8). index(9). index(10).

previous(1, 0). previous(2, 1). previous(3, 2). previous(4, 3). previous(5, 4).
previous(6, 5). previous(7, 6). previous(8, 7). previous(9, 8). previous(10, 9).

g_bounds(K, Gl, Gu) :-
  target(A),
  x_bounds(K, L, U),
  sub(L, A, Dl),
  sub(U, A, Du),
  mul(2, Dl, Gl),
  mul(2, Du, Gu).

p_bounds(K, Pl, Pu) :-
  eta(Eta),
  g_bounds(K, Gl, Gu),
  mul(Eta, Gl, Pl),
  mul(Eta, Gu, Pu).

x_bounds(K1, L1, U1) :-
  previous(K1, K),
  x_bounds(K, L, U),
  target(A),
  eta(Eta),
  sub(L, A, Dl),
  sub(U, A, Du),
  mul(2, Dl, Gl),
  mul(2, Du, Gu),
  mul(Eta, Gl, Pl),
  mul(Eta, Gu, Pu),
  sub(L, Pu, L1),
  sub(U, Pl, U1).

width(K, W) :-
  x_bounds(K, L, U),
  sub(U, L, W).

midpoint(K, M, Halfw) :-
  x_bounds(K, L, U),
  width(K, W),
  div(W, 2, Halfw),
  add(L, U, Sum),
  div(Sum, 2, M).

eta_le_half(true) :-
  eta(Eta),
  div(1.0, 2, Half),
  le(Eta, Half).

width_contracts_at(K1, true) :-
  eta_le_half(true),
  previous(K1, K),
  width(K, W),
  width(K1, W1),
  le(W1, W).

max2(A, B, A) :- ge(A, B).
max2(A, B, B) :- lt(A, B).
min2(A, B, A) :- le(A, B).
min2(A, B, B) :- gt(A, B).

end_squares(K, Sl, Su) :-
  target(A),
  x_bounds(K, L, U),
  sub(L, A, Dl),
  sub(U, A, Du),
  mul(Dl, Dl, Sl),
  mul(Du, Du, Su).

f_upper(K, Fu) :-
  end_squares(K, Sl, Su),
  max2(Sl, Su, Fu).

f_lower(K, 0.0) :-
  target(A),
  x_bounds(K, L, U),
  le(L, A),
  le(A, U).

f_lower(K, Fl) :-
  target(A),
  x_bounds(K, L, U),
  lt(U, A),
  end_squares(K, Sl, Su),
  min2(Sl, Su, Fl).

f_lower(K, Fl) :-
  target(A),
  x_bounds(K, L, U),
  lt(A, L),
  end_squares(K, Sl, Su),
  min2(Sl, Su, Fl).

eta(result, Eta) :-
  eta(Eta).

etaLeHalf(result, true) :-
  eta_le_half(true).

xBounds(result, bounds(K, L, U)) :-
  index(K),
  x_bounds(K, L, U).

midpoint(result, midpoint(K, M, Halfw)) :-
  index(K),
  midpoint(K, M, Halfw).

width(result, width(K, W)) :-
  index(K),
  width(K, W).

gradientBounds(result, gradient(K, Gl, Gu)) :-
  index(K),
  g_bounds(K, Gl, Gu).

stepBounds(result, step(K, Pl, Pu)) :-
  index(K),
  p_bounds(K, Pl, Pu).

objectiveBounds(result, f(K, Fl, Fu)) :-
  index(K),
  f_lower(K, Fl),
  f_upper(K, Fu).

widthContractsAt(result, K) :-
  width_contracts_at(K, true).
