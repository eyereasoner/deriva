% Eyelet-inspired combinations example using findall/3 and sort/2.
%
% combination/3 generates the same subset in several selection orders.  findall/3
% collects those candidates, and sort/2 canonicalizes the list so each unordered
% 3-combination of five items is reported once.
materialize(combinations, 2).
materialize(count, 2).
materialize(reason, 2).

% select/3 nondeterministically removes one item from a list; because it is an
% ordinary rule, the example also demonstrates user-level list recursion.
select(Item, [Item | Rest], Rest).
% The recursive clause keeps the non-selected head and searches the tail.
select(Item, [Head | Tail], [Head | Rest]) :-
  select(Item, Tail, Rest).

% combination/3 builds an unordered K-combination by repeated selection.
combination(0, _items, []).
combination(I, Items, Combination) :-
  gt(I, 0),
  select(Item, Items, Remaining),
  sub(I, 1, J),
  combination(J, Remaining, Partial),
  sort([Item | Partial], Combination).

% findall collects all generation orders; sort canonicalizes and deduplicates.
unique_combinations(K, Items, Unique) :-
  findall(C, combination(K, Items, C), All),
  sort(All, Unique).

combinations(combinations_5_choose_3, Unique) :-
  unique_combinations(3, [1, 2, 3, 4, 5], Unique).

count(combinations_5_choose_3, Count) :-
  unique_combinations(3, [1, 2, 3, 4, 5], Unique),
  length(Unique, Count).

reason(combinations_5_choose_3, "findall gathers generated combinations and sort removes duplicates").
