% Derived rule example adapted from Eyeling derived-rule.n3.
%
% Eyeling source shape:
%   minka a cat.
%   charly a dog.
%   { X a cat. } => { { Y a dog. } => { test is true. }. }.
%
% The inner implication is represented directly as quoted formula data.
% var(y) is not a via variable; it is a ground term that names
% a variable placeholder inside the quoted formula.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(type, 2).
materialize(log_implies, 2).
materialize(is, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
type(minka, cat).
type(charly, dog).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
log_implies(type(var(y), dog), is(test, true)) :-
  type(_x, cat).

is(test, true) :-
  log_implies(type(var(y), dog), is(test, true)),
  type(_y, dog).
