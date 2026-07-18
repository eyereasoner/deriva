% Floating-point arithmetic and comparisons.
%
% Integer-only arithmetic stays exact, but decimal inputs use JavaScript numbers.
% This example keeps the calculations small and transparent so differences between
% add/sub/mul/div/pow and comparison predicates are visible.
%
% The thermostat facts provide a concrete comparison setting, while standalone
% value/2 reports exercise individual decimal operations.
materialize(value, 2).
materialize(than, 2).

% Sample facts provide a small thermostat scenario used by the comparison
% rules; separate value/2 facts below exercise standalone decimal arithmetic.
sample(roomC, 21.5).
sample(targetC, 19.25).

% Each value/2 fact is a small arithmetic check; than/2 and comfortable/2
% show that comparisons work over decimal results too.
value(sum, X) :- add(1.5, 2.25, X).
value(difference, X) :- sub(10.0, 3.125, X).
value(product, X) :- mul(2.5, 4.0, X).
value(quotient, X) :- div(7.5, 2, X).
value(sqrtByPower, X) :- pow(9.0, 0.5, X).
value(mathSum, X) :- add(0.125, 0.875, X).
value(mathProduct, X) :- mul(6.0, 0.5, X).
than(warmer, targetC) :- sample(roomC, R), sample(targetC, T), gt(R, T).
% Boolean-like conclusions remain ordinary atoms.
value(comfortable, true) :- sample(roomC, R), ge(R, 21.0), le(R, 22.0).
