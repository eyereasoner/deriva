% Reference 9.2: integer arithmetic keeps exact BigInt paths where possible.
materialize(answer, 2).
answer(add_big, X) :- add(9007199254740993, 7, X).
answer(sub_big, X) :- sub(9007199254741000, 7, X).
answer(mul_big, X) :- mul(123456789, 987654321, X).
answer(pow_big, X) :- pow(2, 63, X).
answer(div_big, X) :- div(9223372036854775808, 2, X).
answer(mod_big, X) :- mod(9223372036854775809, 10, X).
