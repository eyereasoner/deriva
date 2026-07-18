materialize(answer, 1).
p('<urn:example:a>') :- not(q('<urn:example:a>')).
q('<urn:example:a>') :- not(p('<urn:example:a>')).
answer(ok).
