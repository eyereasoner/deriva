% Memoize shared inference layers: the score vector, disease likelihood tails,
% and expected therapy success are reused by several report relations.
% Output declarations: materialize/2 selects the relations written to this example's golden output.
%
% Read this as two stacked inference problems: first infer disease posterior
% probabilities from symptoms, then score each therapy by averaging outcomes
% over that posterior distribution. The recursive predicates are
% shared layers used by several materialized reports.
materialize(diseases, 2).
materialize(therapies, 2).
materialize(evidence, 2).
materialize(scores, 2).
materialize(evidenceTotal, 2).
materialize(posteriors, 2).
materialize(posterior, 2).
materialize(expectedSuccess, 2).
materialize(expectedAdverse, 2).
materialize(utility, 2).
materialize(recommendedTherapy, 2).

% Program structure: facts set up the scenario, and rules derive the materialized conclusions.

% Bayes therapy decision support adapted from Eyeling bayes-therapy.n3.
% Probabilities are illustrative and are not medical advice.
% The example combines a tiny Naive Bayes diagnosis model with a therapy
% utility layer: expected utility = 10 * expectedSuccess - 3 * expectedAdverse.

diseases(case, [covid19, influenza, allergicRhinitis, bacterialPneumonia]).
therapies(case, [paxlovid, oseltamivir, supportiveCare, antibiotic, antihistamine]).
evidence(case, [
  ev(fever, true),
  ev(dryCough, true),
  ev(lossOfSmell, false),
  ev(sneezing, false),
  ev(shortBreath, false)
]).

prior(covid19, 0.05).
prior(influenza, 0.03).
prior(allergicRhinitis, 0.10).
prior(bacterialPneumonia, 0.01).

p_given(covid19, fever, 0.70).
p_given(covid19, dryCough, 0.65).
p_given(covid19, lossOfSmell, 0.40).
p_given(covid19, sneezing, 0.15).
p_given(covid19, shortBreath, 0.20).

p_given(influenza, fever, 0.80).
p_given(influenza, dryCough, 0.50).
p_given(influenza, lossOfSmell, 0.05).
p_given(influenza, sneezing, 0.20).
p_given(influenza, shortBreath, 0.10).

p_given(allergicRhinitis, fever, 0.05).
p_given(allergicRhinitis, dryCough, 0.15).
p_given(allergicRhinitis, lossOfSmell, 0.10).
p_given(allergicRhinitis, sneezing, 0.80).
p_given(allergicRhinitis, shortBreath, 0.05).

p_given(bacterialPneumonia, fever, 0.70).
p_given(bacterialPneumonia, dryCough, 0.60).
p_given(bacterialPneumonia, lossOfSmell, 0.02).
p_given(bacterialPneumonia, sneezing, 0.05).
p_given(bacterialPneumonia, shortBreath, 0.60).

therapy(paxlovid).
therapy(oseltamivir).
therapy(antihistamine).
therapy(antibiotic).
therapy(supportiveCare).

success_by_disease(paxlovid, [0.75, 0.05, 0.02, 0.05]).
success_by_disease(oseltamivir, [0.05, 0.60, 0.02, 0.05]).
success_by_disease(antihistamine, [0.10, 0.10, 0.75, 0.05]).
success_by_disease(antibiotic, [0.05, 0.05, 0.02, 0.80]).
success_by_disease(supportiveCare, [0.30, 0.30, 0.25, 0.20]).

adverse(paxlovid, 0.10).
adverse(oseltamivir, 0.08).
adverse(antihistamine, 0.03).
adverse(antibiotic, 0.07).
adverse(supportiveCare, 0.01).

benefit_weight(10).
harm_weight(3).

% Derivation rules: each rule below contributes one logical step toward the displayed results.
factor(Disease, ev(Symptom, true), P) :- p_given(Disease, Symptom, P).
factor(Disease, ev(Symptom, false), Q) :-
  p_given(Disease, Symptom, P),
  sub(1.0, P, Q).

likelihood(_disease, [], 1.0).
likelihood(Disease, [Evidence|Rest], Likelihood) :-
  factor(Disease, Evidence, Factor),
  likelihood(Disease, Rest, Taillikelihood),
  mul(Factor, Taillikelihood, Likelihood).

% score/2 combines prior probability with the likelihood of the observed evidence.
score(Disease, Score) :-
  prior(Disease, Prior),
  evidence(case, Evidence),
  likelihood(Disease, Evidence, Likelihood),
  mul(Prior, Likelihood, Score).

scores_for([], []).
scores_for([Disease|Restdiseases], [Score|Restscores]) :-
  score(Disease, Score),
  scores_for(Restdiseases, Restscores).

score_sum([], 0.0).
score_sum([Value|Rest], Sum) :-
  score_sum(Rest, Tailsum),
  add(Value, Tailsum, Sum).

normalize_scores([], _total, []).
normalize_scores([Score|Restscores], Total, [Posterior|Restposteriors]) :-
  div(Score, Total, Posterior),
  normalize_scores(Restscores, Total, Restposteriors).

disease_posterior([Disease|_restdiseases], [Posterior|_restposteriors], Disease, Posterior).
disease_posterior([_otherdisease|Restdiseases], [_otherposterior|Restposteriors], Disease, Posterior) :-
  disease_posterior(Restdiseases, Restposteriors, Disease, Posterior).

dot_product([], [], 0.0).
dot_product([Left|Restleft], [Right|Restright], Sum) :-
  mul(Left, Right, Term),
  dot_product(Restleft, Restright, Tailsum),
  add(Term, Tailsum, Sum).

expected_success(Therapy, Expectedsuccess) :-
  posteriors(case, Posteriors),
  success_by_disease(Therapy, Successbydisease),
  dot_product(Posteriors, Successbydisease, Expectedsuccess).

% utility/2 turns expected success and adverse effects into a ranking score.
utility(Therapy, Utility) :-
  expected_success(Therapy, Expectedsuccess),
  adverse(Therapy, Adverse),
  benefit_weight(Benefitweight),
  harm_weight(Harmweight),
  mul(Benefitweight, Expectedsuccess, Benefit),
  mul(Harmweight, Adverse, Harmcost),
  sub(Benefit, Harmcost, Utility).

better_of(Therapy1, Therapy2, Therapy1) :-
  utility(Therapy1, Utility1),
  utility(Therapy2, Utility2),
  ge(Utility1, Utility2).
better_of(Therapy1, Therapy2, Therapy2) :-
  utility(Therapy1, Utility1),
  utility(Therapy2, Utility2),
  lt(Utility1, Utility2).

best_therapy([Therapy], Therapy).
best_therapy([Head, Next|Rest], Best) :-
  best_therapy([Next|Rest], Bestrest),
  better_of(Head, Bestrest, Best).

scores(case, Scores) :-
  diseases(case, Diseases),
  scores_for(Diseases, Scores).
evidenceTotal(case, Total) :-
  scores(case, Scores),
  score_sum(Scores, Total).
posteriors(case, Posteriors) :-
  scores(case, Scores),
  evidenceTotal(case, Total),
  normalize_scores(Scores, Total, Posteriors).
posterior(Disease, Posterior) :-
  diseases(case, Diseases),
  posteriors(case, Posteriors),
  disease_posterior(Diseases, Posteriors, Disease, Posterior).
expectedSuccess(Therapy, Expectedsuccess) :-
  therapy(Therapy),
  expected_success(Therapy, Expectedsuccess).
expectedAdverse(Therapy, Adverse) :-
  therapy(Therapy),
  adverse(Therapy, Adverse).
utility(Therapy, Utility) :-
  therapy(Therapy),
  utility(Therapy, Utility).
recommendedTherapy(case, Best) :-
  therapies(case, Therapies),
  best_therapy(Therapies, Best).
