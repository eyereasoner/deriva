% Burn the witch, adapted from Eyeling's examples/witch.n3.
%
% This is the classic N3/Semantic Web rule chain in via form: a duck
% floats; something with the same weight as something that floats also floats;
% things that float are made of wood; things made of wood burn; and a woman
% who burns is a witch.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(floats, 1).
materialize(madeOfWood, 1).
materialize(burns, 1).
materialize(witch, 1).
materialize(is, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
% Derivation rules: each rule below contributes one logical step toward the displayed results.
witch(X) :-
  burns(X),
  woman(X).

woman(girl).

burns(X) :-
  madeOfWood(X).

madeOfWood(X) :-
  floats(X).

floats(duck).

floats(Y) :-
  sameWeight(X, Y),
  floats(X).

sameWeight(duck, girl).

is(witchExample, true) :-
  witch(girl).
