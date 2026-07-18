% Derived backward rule example adapted from Eyeling derived-backward-rule.n3.
%
% Eyeling source shape:
%   parentOf invOf childOf.
%   alice parentOf bob.
%   { P invOf Q. } => { { X Q Y. } <= { Y P X. }. }.
%   { X childOf Y. } => { X hasParent Y. }.
%
% The generated backward rule is represented as quoted formula data in
% log_impliedBy/2, then mirrored as an ordinary via rule so the generated
% childOf relation can feed the ordinary hasParent rule.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(log_impliedBy, 2).
materialize(childOf, 2).
materialize(hasParent, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
invOf(parentOf, childOf).
parentOf(alice, bob).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
log_impliedBy(childOf(var(x), var(y)), parentOf(var(y), var(x))) :-
  invOf(parentOf, childOf).

childOf(X, Y) :-
  log_impliedBy(childOf(var(x), var(y)), parentOf(var(y), var(x))),
  parentOf(Y, X).

hasParent(X, Y) :- childOf(X, Y).
