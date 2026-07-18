materialize(answer, 1).
answer(ok) :- holds((likes(alice, tea), likes(bob, coffee)), likes(alice, tea)).
