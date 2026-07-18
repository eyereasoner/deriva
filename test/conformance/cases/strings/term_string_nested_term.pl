materialize(answer, 1).
answer(Text) :- term_string(pair('<urn:example:a>', [1, two]), Text).
