% Animal classification, adapted from Eyelet's input/animal.pl.
%
% The Eyelet source uses Unicode predicate names; this via version keeps the
% same tiny inheritance idea with plain vocabulary names.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(type, 2).
materialize(subclassOf, 2).
materialize(succeeds, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
human(joe).
animal(human).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
animal(X) :- human(X).

type(joe, human) :- human(joe).
type(joe, animal) :- animal(joe).
subclassOf(human, animal) :- animal(human).
succeeds(animalExample, true) :- animal(_).
