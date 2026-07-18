person(alice).
has_parent(Child, parent_of(Child)) :- person(Child).
materialize(has_parent, 2).
