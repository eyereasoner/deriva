% Term-tool builtins for inspecting, constructing, rendering, and validating
% structured terms.
%
% Each report/2 answer demonstrates one meta-programming operation over ordinary
% Via terms: functor/3 and arg/3 inspect shape, compound_name_arguments/3 can
% decompose or rebuild a compound, term_string/2 renders a term, and forall/2
% validates all edge weights.
%
% This is a good reference example when writing rules that need to treat terms as
% data rather than only as predicate calls.
materialize(report, 2).

edge(a, b, 3).
edge(b, c, 4).

report(shape, shape(Name, Arity)) :-
  functor(edge(a, b, 3), Name, Arity).

report(second_argument, Node) :-
  arg(2, edge(a, b, 3), Node).

report(parts, parts(Name, Args)) :-
  compound_name_arguments(edge(a, b, 3), Name, Args).

report(rebuilt, Term) :-
  compound_name_arguments(Term, edge, [c, d, 5]).

report(rendered, Text) :-
  term_string(edge(a, [b, c]), Text).

report(all_weights_positive, yes) :-
  forall(edge(_from, _to, Weight), gt(Weight, 0)).
