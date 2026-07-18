% Angle-bracket and quoted spellings denote the same absolute IRI atom.
materialize(answer, 1).
answer(ok) :- eq('<urn:example:a>', 'urn:example:a').
