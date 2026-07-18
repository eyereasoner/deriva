materialize(answer, 3).
answer(head_and_rest_improper, H, R) :- head([a | b], H), rest([a | b], R).
