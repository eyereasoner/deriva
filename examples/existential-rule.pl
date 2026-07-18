% Existential-style introduction with explicit Herbrand witnesses.
%
% Via has no blank nodes and no existential variables in rule heads.  A
% rule can still express the practical executable shape of an existential
% consequence by putting a named functional term directly in the head.

materialize(is, 2).

type(socrates, human).
type(plato, human).

% In proof output this rule is the step that explains each visible witness.
is(Person, human_witness(Person)) :-
  type(Person, human).
