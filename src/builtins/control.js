// Control builtins.  These intentionally use bounded nested solvers so not/1 and once/1 only ask for the answers they need.
export const controlBuiltins = {
  register(registry) {
    registry.add('not', 1, notBuiltin);
    registry.add('once', 1, onceBuiltin);
    registry.add('forall', 2, forallBuiltin);
  }
};

function* notBuiltin({ solver, goal, env }) {
  const limited = solver.cloneForInnerGoal(1);
  let found = false;
  for (const _ of limited.solve([goal.args[0]], env.clone(), 0)) { found = true; break; }
  solver.absorbStatsFrom(limited);
  if (!found) yield env;
}

function* onceBuiltin({ solver, goal, env }) {
  const limited = solver.cloneForInnerGoal(1);
  let first = null;
  for (const answerEnv of limited.solve([goal.args[0]], env.clone(), 0)) {
    first = answerEnv;
    break;
  }
  solver.absorbStatsFrom(limited);
  if (first) yield first;
}

function* forallBuiltin({ solver, goal, env }) {
  const generator = solver.cloneForInnerGoal(10000000);
  for (const answerEnv of generator.solve([goal.args[0]], env.clone(), 0)) {
    const checker = solver.cloneForInnerGoal(1);
    let ok = false;
    for (const _ of checker.solve([goal.args[1]], answerEnv.clone(), 0)) { ok = true; break; }
    solver.absorbStatsFrom(checker);
    if (!ok) {
      solver.absorbStatsFrom(generator);
      return;
    }
  }
  solver.absorbStatsFrom(generator);
  yield env;
}
