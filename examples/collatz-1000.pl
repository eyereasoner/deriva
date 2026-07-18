% Collatz conjecture suite translated from Eyeling's examples/collatz-1000.n3.
% It enumerates starts N = 1000, 999, ..., 1 by deriving N = 1000 - N0
% from a repeat relation, then materializes each full trajectory.
%
% Source N3:
% https://raw.githubusercontent.com/eyereasoner/eyeling/refs/heads/main/examples/collatz-1000.n3

% Output declarations: materialize/2 selects the relations written to this example's golden output.
% Automatic tabling caches shared suffix trajectories so the 1000 starts do not recompute
% the same Collatz tails hundreds of times.
materialize(collatzTrajectory, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.
% The N3 source defines repeat/2 recursively; this Via version uses the
% equivalent bounded generator so the 1000-case regression remains stack-safe.

% Query / materialization of the test suite.
% Generate N in {1000..1} and ask the backward-defined collatz/2 predicate
% for the full trajectory list M.
collatzTrajectory(N, M) :-
  repeat(1000, N0),
  sub(1000, N0, N),
  collatz(N, M).

% Range generator.
% repeat(N, I) enumerates all integers I in the half-open interval [0..N-1].
repeat(N, I) :-
  sub(N, 1, Last),
  between(0, Last, I).

% Backward Collatz relation.
% collatz(N, M) relates a start value N to its full trajectory list M.
collatz(1, [1]).
collatz(N, [N|J]) :-
  gt(N, 1),
  mod(N, 2, 0),
  div(N, 2, N1),
  collatz(N1, J).
collatz(N, [N|J]) :-
  gt(N, 1),
  mod(N, 2, 1),
  mul(3, N, T),
  add(T, 1, N1),
  collatz(N1, J).
