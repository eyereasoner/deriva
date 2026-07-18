% Cryptarithm search for SEND + MORE = MONEY.
%
% The solver assigns distinct decimal digits to letters while enforcing the
% column-by-column carries.  Rather than generate all digit assignments first,
% each column constraint is applied as soon as its letters are chosen.
materialize(cryptarithm_answer, 2).

% The search domain is a shrinking digit list threaded through select/3 calls.
all_digits([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).

send_more_money(solution(S, E, N, D, M, O, R, Y)) :-
  all_digits(Digits),
  eq(M, 1),
  eq(O, 0),
  select(M, Digits, D0),
  select(O, D0, D1),

  select(D, D1, D2),
  select(E, D2, D3),
  add(D, E, Onessum),
  mod(Onessum, 10, Y),
  div(Onessum, 10, Carry1),
  select(Y, D3, D4),

  select(N, D4, D5),
  select(R, D5, D6),
  add(N, R, Tenspartial),
  add(Tenspartial, Carry1, Tenssum),
  mod(Tenssum, 10, E),
  div(Tenssum, 10, Carry2),

  add(E, O, Hundredspartial),
  add(Hundredspartial, Carry2, Hundredssum),
  mod(Hundredssum, 10, N),
  div(Hundredssum, 10, Carry3),

  select(S, D6, _d7),
  neq(S, 0),
  add(S, M, Thousandspartial),
  add(Thousandspartial, Carry3, Thousandssum),
  mod(Thousandssum, 10, O),
  div(Thousandssum, 10, M).

% Number constructors are used only for readable output after a solution is found.
number4(A, B, C, D, Value) :-
  mul(A, 1000, Apart),
  mul(B, 100, Bpart),
  mul(C, 10, Cpart),
  add(Apart, Bpart, Ab),
  add(Ab, Cpart, Abc),
  add(Abc, D, Value).

number5(A, B, C, D, E, Value) :-
  mul(A, 10000, Apart),
  mul(B, 1000, Bpart),
  mul(C, 100, Cpart),
  mul(D, 10, Dpart),
  add(Apart, Bpart, Ab),
  add(Ab, Cpart, Abc),
  add(Abc, Dpart, Abcd),
  add(Abcd, E, Value).

cryptarithm_answer(assignments, solution(S, E, N, D, M, O, R, Y)) :-
  send_more_money(solution(S, E, N, D, M, O, R, Y)).
cryptarithm_answer(equation, equation(Send, More, Money)) :-
  send_more_money(solution(S, E, N, D, M, O, R, Y)),
  number4(S, E, N, D, Send),
  number4(M, O, R, E, More),
  number5(M, O, N, E, Y, Money).
cryptarithm_answer(solution_count, Count) :-
  countall(send_more_money(_solution), Count).
