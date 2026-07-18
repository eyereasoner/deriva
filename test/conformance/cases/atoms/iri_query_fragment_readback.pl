% Query strings and fragments are part of the IRI atom text.
materialize(answer, 1).
seed('<https://example.org/path?x=1#frag>').
answer(X) :- seed(X).
