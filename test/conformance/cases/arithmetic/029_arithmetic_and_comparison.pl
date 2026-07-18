% Reference 9.2, 9.3: arithmetic and comparison built-ins.
answer(sum, X) :- add(2, 3, X).
answer(diff, X) :- sub(7, 4, X).
answer(product, X) :- mul(6, 7, X).
answer(integer_division, X) :- div(7, 2, X).
answer(remainder, X) :- mod(7, 2, X).
answer(power, X) :- pow(2, 8, X).
answer(minimum, X) :- min(3, 9, X).
answer(less_than, true) :- lt(3, 9).
answer(greater_equal, true) :- ge(9, 9).
materialize(answer, 2).
