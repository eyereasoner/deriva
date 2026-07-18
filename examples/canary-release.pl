% Technology example: canary release decision.
%
% A canary deployment is rolled back when its measured error rate exceeds the
% allowed budget, even when latency is still acceptable.

% Output declarations: materialize/2 selects the relations written to this example's golden output.
materialize(errorRate, 2).
materialize(p95Latency_ms, 2).
materialize(latencyCheck, 2).
materialize(status, 2).
materialize(reason, 2).

% canary/4 records request count, error count, and p95 latency; thresholds
% make the rollout policy explicit data rather than constants hidden in rules.
canary(canary42, 5000.0, 75.0, 180.0).
threshold(canary42, maximum_error_rate, 0.01).
threshold(canary42, maximum_p95_latency_ms, 200.0).

% The latency and error-budget checks are independent so the final rollback
% reason can point to the failing guard.
error_rate(Release, Rate) :-
  canary(Release, Requests, Errors, _p95latency),
  div(Errors, Requests, Rate).

latency_ok(Release) :-
  canary(Release, _requests, _errors, P95latency),
  threshold(Release, maximum_p95_latency_ms, Maximum),
  lt(P95latency, Maximum).

error_budget_exceeded(Release) :-
  error_rate(Release, Rate),
  threshold(Release, maximum_error_rate, Maximum),
  gt(Rate, Maximum).

rollback_recommended(Release) :-
  error_budget_exceeded(Release).

errorRate(Release, Rate) :-
  error_rate(Release, Rate).

p95Latency_ms(Release, P95latency) :-
  canary(Release, _requests, _errors, P95latency).

latencyCheck(Release, ok) :-
  latency_ok(Release).

status(Release, rollback_recommended) :-
  rollback_recommended(Release).

reason(Release, "canary error rate exceeds the allowed budget") :-
  rollback_recommended(Release).
