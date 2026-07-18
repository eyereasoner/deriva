% Non-http absolute IRI atoms are ordinary atoms.
materialize(answer, 1).
seed('<mailto:alice@example.org>').
answer(X) :- seed(X).
