% Age checker adapted from Eyeling.
% The example combines date literals, ISO-8601 duration values, local_time/1,
% difference/3, and duration comparison.  It deliberately uses the current
% local date so the derived ageAbove/2 fact remains an executable temporal
% check rather than a precomputed constant.

materialize(birthDay, 2).
materialize(duration, 2).
materialize(ageAbove, 2).
materialize(is, 2).

birthDay(patH, "1944-08-21").
duration(check, "P80Y").

% A person is above a duration if the local date minus the birthday is greater
% than that duration.
ageAbove(S, A) :-
  birthDay(S, B),
  duration(check, A),
  local_time(D),
  difference(D, B, F),
  gt(F, A).

% Test mirroring the Eyeling example.
is(test, true) :-
  ageAbove(S, "P80Y").
