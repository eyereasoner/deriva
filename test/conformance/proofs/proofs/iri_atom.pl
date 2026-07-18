% Reference 12: proof output preserves angle-bracket IRI atom read-back.
materialize(label, 2).
name('<urn:example:a>', "Alice").
label(Iri, Name) :- name(Iri, Name).
