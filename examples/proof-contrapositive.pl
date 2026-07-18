% Proof by contrapositive example adapted from Eyelet input/proof-by-contrapositive.pl.
%
% The implication itself is represented as data with implies/2.  The proof
% rule remains ordinary via: if A implies B and B is false, then A is false.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(refutes, 2).
materialize(method, 2).
materialize(reason, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
implies(raining, wet_ground).
false(wet_ground).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
false(A) :-
  implies(A, B),
  false(B).

refutes(proof1, raining) :-
  false(raining).

method(proof1, contrapositive) :-
  false(raining).

reason(proof1, "if rain implies wet ground and the ground is not wet, then it is not raining") :-
  false(raining).
