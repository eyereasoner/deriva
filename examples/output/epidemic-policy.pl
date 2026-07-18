status(no_mandate, insufficient_control).
status(vaccination_campaign, insufficient_control).
status(indoor_masks, insufficient_control).
status(vaccination_and_masks, acceptable_control).
riskScore(no_mandate, 1.3999999999999999).
riskScore(vaccination_campaign, 0.77000000000000002).
riskScore(indoor_masks, 0.90999999999999992).
riskScore(vaccination_and_masks, 0.50050000000000006).
cost(no_mandate, 0).
cost(vaccination_campaign, 3).
cost(indoor_masks, 2).
cost(vaccination_and_masks, 5).
recommendedPolicy(epidemic_policy, vaccination_and_masks).
reason(epidemic_policy, "combined vaccination and indoor masks are the only policy below the outbreak threshold").
