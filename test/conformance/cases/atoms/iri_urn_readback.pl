% URN IRI atoms read back in angle-bracket form.
materialize(answer, 1).
seed('<urn:example:alpha>').
answer(X) :- seed(X).
