% Existential-style consequence with one universal variable represented as a Herbrand term.
materialize(answer, 2).
person(alice).
person(bob).
answer(Child, parent_of(Child)) :- person(Child).
