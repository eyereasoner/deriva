% Towers of Hanoi adapted from Eyeling hanoi.n3.
% hanoi/5 recursively builds the move list by moving N-1 disks aside, moving the
% largest disk, then moving N-1 disks onto the target peg.  The size-3 answer is
% small enough for a readable golden output while still exercising list append.

materialize(answer, 2).


hanoi(0, _from, _to, _via, []).
hanoi(N, From, To, Via, Moves) :-
  gt(N, 0),
  sub(N, 1, N1),
  hanoi(N1, From, Via, To, Before),
  hanoi(N1, Via, To, From, After),
  append(Before, [[From, To]|After], Moves).

answer(3, Moves) :-
  hanoi(3, left, right, center, Moves).
