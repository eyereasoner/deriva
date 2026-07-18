% `_name` is a named variable and must be reused within a clause.
materialize(answer, 1).
pair(a, a).
pair(a, b).
answer(_value) :- pair(_value, _value).
