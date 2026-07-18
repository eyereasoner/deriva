% Engineering example: RC low-pass filter sizing.
%
% A resistor and capacitor define the time constant tau = R*C.  The cutoff
% frequency rule then computes fc = 1/(2*pi*tau).
%
% The model uses key/value component facts so the same pattern can be extended to
% multiple named filters or extra component attributes without changing the rules.

materialize(type, 2).
materialize(timeConstant_s, 2).
materialize(cutoffFrequency_Hz, 2).

component(filter1, resistor_ohm, 10000.0).
component(filter1, capacitor_f, 0.000001).
constant(pi, 3.141592653589793).

time_constant(Filter, Tau) :-
  component(Filter, resistor_ohm, R),
  component(Filter, capacitor_f, C),
  mul(R, C, Tau).

cutoff_frequency(Filter, Frequency) :-
  time_constant(Filter, Tau),
  constant(pi, Pi),
  mul(2.0, Pi, Twopi),
  mul(Twopi, Tau, Denominator),
  div(1.0, Denominator, Frequency).

type(Filter, first_order_low_pass) :-
  component(Filter, resistor_ohm, _r),
  component(Filter, capacitor_f, _c).

timeConstant_s(Filter, Tau) :-
  time_constant(Filter, Tau).

cutoffFrequency_Hz(Filter, Frequency) :-
  cutoff_frequency(Filter, Frequency).
