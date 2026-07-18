% Web names as first-class Via atoms.
%
% Angle-bracket IRI atoms are ordinary atoms with globally meaningful names.
% They are self-contained, require no prefix declarations, and can be joined
% directly across rules just like any other atom.

materialize(affiliated_with, 2).
materialize(project_contact, 3).


% A tiny graph using absolute IRI atoms directly.
triple('<https://data.ugent.be/id/josd>', '<https://schema.org/name>', "Jos De Roo").
triple('<https://data.ugent.be/id/josd>', '<https://schema.org/email>', "josderoo@gmail.com").
triple('<https://data.ugent.be/id/josd>', '<https://schema.org/affiliation>', '<https://data.ugent.be/id/idlab>').
triple('<https://data.ugent.be/id/idlab>', '<https://schema.org/parentOrganization>', '<https://data.ugent.be/id/ugent>').

triple('<https://github.com/josd/via>', '<https://schema.org/name>', "via").
triple('<https://github.com/josd/via>', '<https://schema.org/codeRepository>', '<https://github.com/josd/via>').
triple('<https://github.com/josd/via>', '<https://schema.org/maintainer>', '<https://data.ugent.be/id/josd>').

% Organization membership follows parentOrganization links transitively.
parent_organization(Unit, Org) :-
    triple(Unit, '<https://schema.org/parentOrganization>', Org).
parent_organization(Unit, Org) :-
    triple(Unit, '<https://schema.org/parentOrganization>', Mid),
    parent_organization(Mid, Org).

affiliated_with(Person, Org) :-
    triple(Person, '<https://schema.org/affiliation>', Org).
affiliated_with(Person, Org) :-
    triple(Person, '<https://schema.org/affiliation>', Unit),
    parent_organization(Unit, Org).

% A project contact is derived by joining the project's maintainer with the
% maintainer's email.  The join works because both facts use the same IRI atom.
project_contact(Project, Person, Email) :-
    triple(Project, '<https://schema.org/maintainer>', Person),
    triple(Person, '<https://schema.org/email>', Email).
