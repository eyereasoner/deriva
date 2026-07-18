materialize(answer, 1).
p(a).
answer(not_unbound_existing_goal_fails) :- not(p(X)).
