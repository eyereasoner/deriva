% Cat Koko, adapted from Eyeling's examples/cat-koko.n3.
%
% The Eyeling output contains two existential witnesses. via has no blank
% node constructor in the portable core, so this adaptation names those
% witnesses sk_0 and sk_1.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(type, 2).
materialize(is, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
animal(koko).

witness(cat, sk_0).
witness(british_short_hair, sk_1).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
type(X, cat) :- animal(koko), witness(cat, X).
type(X, british_short_hair) :- animal(koko), witness(british_short_hair, X).

is(test, true) :-
  type(X, cat),
  type(Y, british_short_hair),
  neq(X, Y).
