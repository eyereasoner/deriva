% Leg Length Discrepancy Measurement, adapted from Eyeling lldm.n3.
%
% The measurement and intermediate geometry are kept in helper predicates so
% the default relation materialization stays concise.  The visible output is
% the alarm plus the small set of relations explaining why the alarm fired.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(type, 2).
materialize(lld_left_length_cm, 2).
materialize(lld_right_length_cm, 2).
materialize(lld_discrepancy_cm, 2).
materialize(lld_threshold_cm, 2).
materialize(lld_reason, 2).

% val/3 stores raw landmark coordinates, derived deltas, line coefficients,
% projected landmarks, lengths, and alarm values in one measurement namespace.
measurement(meas47).

% measured landmark coordinates, in centimetres
val(meas47, p1xCm, 10.1).
val(meas47, p1yCm, 7.8).
val(meas47, p2xCm, 45.1).
val(meas47, p2yCm, 5.6).
val(meas47, p3xCm, 3.6).
val(meas47, p3yCm, 29.8).
val(meas47, p4xCm, 54.7).
val(meas47, p4yCm, 28.5).

% threshold used by the alarm rule, in centimetres
threshold(meas47, lld_alarm_threshold_cm, 1.25).

% geometric intermediate values
% The geometry rules build from coordinate differences to projected knee points,
% then compute left/right leg lengths and compare the discrepancy with a threshold.
val(M, dx12Cm, Z) :- measurement(M), val(M, p1xCm, X), val(M, p2xCm, Y), sub(X, Y, Z).
val(M, dx51Cm, Z) :- measurement(M), val(M, p5xCm, X), val(M, p1xCm, Y), sub(X, Y, Z).
val(M, dx53Cm, Z) :- measurement(M), val(M, p5xCm, X), val(M, p3xCm, Y), sub(X, Y, Z).
val(M, dx62Cm, Z) :- measurement(M), val(M, p6xCm, X), val(M, p2xCm, Y), sub(X, Y, Z).
val(M, dx64Cm, Z) :- measurement(M), val(M, p6xCm, X), val(M, p4xCm, Y), sub(X, Y, Z).
val(M, dy12Cm, Z) :- measurement(M), val(M, p1yCm, X), val(M, p2yCm, Y), sub(X, Y, Z).
val(M, dy13Cm, Z) :- measurement(M), val(M, p1yCm, X), val(M, p3yCm, Y), sub(X, Y, Z).
val(M, dy24Cm, Z) :- measurement(M), val(M, p2yCm, X), val(M, p4yCm, Y), sub(X, Y, Z).
val(M, dy53Cm, Z) :- measurement(M), val(M, p5yCm, X), val(M, p3yCm, Y), sub(X, Y, Z).
val(M, dy64Cm, Z) :- measurement(M), val(M, p6yCm, X), val(M, p4yCm, Y), sub(X, Y, Z).
val(M, cL1, Z) :- measurement(M), val(M, dy12Cm, Y), val(M, dx12Cm, X), div(Y, X, Z).
val(M, dL3m, Z) :- measurement(M), val(M, cL1, X), div(1, X, Z).
val(M, cL3, Z) :- measurement(M), val(M, dL3m, X), sub(0, X, Z).
val(M, pL1x1Cm, Z) :- measurement(M), val(M, cL1, X), val(M, p1xCm, Y), mul(X, Y, Z).
val(M, pL1x2Cm, Z) :- measurement(M), val(M, cL1, X), val(M, p2xCm, Y), mul(X, Y, Z).
val(M, pL3x3Cm, Z) :- measurement(M), val(M, cL3, X), val(M, p3xCm, Y), mul(X, Y, Z).
val(M, pL3x4Cm, Z) :- measurement(M), val(M, cL3, X), val(M, p4xCm, Y), mul(X, Y, Z).
val(M, dd13Cm, Z) :- measurement(M), val(M, pL1x1Cm, X), val(M, pL3x3Cm, Y), sub(X, Y, Z).
val(M, ddy13Cm, Z) :- measurement(M), val(M, dd13Cm, X), val(M, dy13Cm, Y), sub(X, Y, Z).
val(M, dd24Cm, Z) :- measurement(M), val(M, pL1x2Cm, X), val(M, pL3x4Cm, Y), sub(X, Y, Z).
val(M, ddy24Cm, Z) :- measurement(M), val(M, dd24Cm, X), val(M, dy24Cm, Y), sub(X, Y, Z).
val(M, ddL13, Z) :- measurement(M), val(M, cL1, X), val(M, cL3, Y), sub(X, Y, Z).
val(M, pL1dx51Cm, Z) :- measurement(M), val(M, cL1, X), val(M, dx51Cm, Y), mul(X, Y, Z).
val(M, pL1dx62Cm, Z) :- measurement(M), val(M, cL1, X), val(M, dx62Cm, Y), mul(X, Y, Z).
val(M, p5xCm, Z) :- measurement(M), val(M, ddy13Cm, X), val(M, ddL13, Y), div(X, Y, Z).
val(M, p5yCm, Z) :- measurement(M), val(M, pL1dx51Cm, X), val(M, p1yCm, Y), add(X, Y, Z).
val(M, p6xCm, Z) :- measurement(M), val(M, ddy24Cm, X), val(M, ddL13, Y), div(X, Y, Z).
val(M, p6yCm, Z) :- measurement(M), val(M, pL1dx62Cm, X), val(M, p2yCm, Y), add(X, Y, Z).
val(M, sdx53Cm2, Z) :- measurement(M), val(M, dx53Cm, X), pow(X, 2, Z).
val(M, sdx64Cm2, Z) :- measurement(M), val(M, dx64Cm, X), pow(X, 2, Z).
val(M, sdy53Cm2, Z) :- measurement(M), val(M, dy53Cm, X), pow(X, 2, Z).
val(M, sdy64Cm2, Z) :- measurement(M), val(M, dy64Cm, X), pow(X, 2, Z).
val(M, ssd53Cm2, Z) :- measurement(M), val(M, sdx53Cm2, X), val(M, sdy53Cm2, Y), add(X, Y, Z).
val(M, ssd64Cm2, Z) :- measurement(M), val(M, sdx64Cm2, X), val(M, sdy64Cm2, Y), add(X, Y, Z).
val(M, d53Cm, Z) :- measurement(M), val(M, ssd53Cm2, X), pow(X, 0.5, Z).
val(M, d64Cm, Z) :- measurement(M), val(M, ssd64Cm2, X), pow(X, 0.5, Z).
val(M, dCm, Z) :- measurement(M), val(M, d53Cm, X), val(M, d64Cm, Y), sub(X, Y, Z).

% concise output layer
type(M, lld_alarm) :- measurement(M), val(M, dCm, D), threshold(M, lld_alarm_threshold_cm, T), sub(0, T, Negt), lt(D, Negt).
type(M, lld_alarm) :- measurement(M), val(M, dCm, D), threshold(M, lld_alarm_threshold_cm, T), gt(D, T).
lld_left_length_cm(M, L) :- type(M, lld_alarm), val(M, d53Cm, L).
lld_right_length_cm(M, R) :- type(M, lld_alarm), val(M, d64Cm, R).
lld_discrepancy_cm(M, D) :- type(M, lld_alarm), val(M, dCm, D).
lld_threshold_cm(M, T) :- type(M, lld_alarm), threshold(M, lld_alarm_threshold_cm, T).
lld_reason(M, "discrepancy below negative threshold") :- type(M, lld_alarm).
