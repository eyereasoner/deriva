% atom_string/2 converts an IRI atom to its lexical string.
materialize(answer, 1).
answer(Text) :- atom_string('<urn:example:a>', Text).
