materialize(answer, 1).
answer(ok) :- not(aggregate_max(Key, Value, missing(Value), BestKey, BestValue)).
