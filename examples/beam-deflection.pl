% Engineering example: cantilever beam tip deflection.
% The beam is modeled with load, span length, elastic modulus, and second moment
% of area.  The rules compute F*L^3/(3*E*I), convert meters to millimeters, and
% classify the design against a deflection limit.

materialize(type, 2).
materialize(tipDeflection_m, 2).
materialize(tipDeflection_mm, 2).
materialize(limit_mm, 2).
materialize(status, 2).

beam(beam1, force_N, 1200.0).
beam(beam1, length_m, 2.5).
beam(beam1, elasticModulus_Pa, 200000000000.0).
beam(beam1, secondMoment_m4, 0.000008).
limit(beam1, maxDeflection_mm, 5.0).

tip_deflection_m(Beam, Deflection) :-
  beam(Beam, force_N, Force),
  beam(Beam, length_m, Length),
  beam(Beam, elasticModulus_Pa, Elasticmodulus),
  beam(Beam, secondMoment_m4, Secondmoment),
  pow(Length, 3.0, Lengthcubed),
  mul(Force, Lengthcubed, Numerator),
  mul(3.0, Elasticmodulus, Threee),
  mul(Threee, Secondmoment, Denominator),
  div(Numerator, Denominator, Deflection).

tip_deflection_mm(Beam, Deflectionmm) :-
  tip_deflection_m(Beam, Deflectionm),
  mul(Deflectionm, 1000.0, Deflectionmm).

type(Beam, cantilever_beam) :-
  beam(Beam, force_N, _force).

tipDeflection_m(Beam, Deflectionm) :-
  tip_deflection_m(Beam, Deflectionm).

tipDeflection_mm(Beam, Deflectionmm) :-
  tip_deflection_mm(Beam, Deflectionmm).

limit_mm(Beam, Limit) :-
  limit(Beam, maxDeflection_mm, Limit).

status(Beam, within_deflection_limit) :-
  tip_deflection_mm(Beam, Deflectionmm),
  limit(Beam, maxDeflection_mm, Limit),
  le(Deflectionmm, Limit).
