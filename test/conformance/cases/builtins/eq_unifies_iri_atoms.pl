% eq/2 unifies angle and quoted spellings of the same absolute IRI atom.
materialize(answer, 1).
answer(ok) :- eq('<urn:example:a>', 'urn:example:a').
