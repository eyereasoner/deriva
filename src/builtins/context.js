// Context builtins that treat comma conjunctions as first-class data terms.
// These are used by examples that construct or inspect rule bodies programmatically.
import { atom, deref, isConjunction, listFromItems, unify } from '../term.js';

export const contextBuiltins = {
  register(registry) {
    registry.add('holds', 2, holdsTerm);
    registry.add('holds', 3, holdsParts);
  }
};

function* emitContextTerm(context, term, env) {
  context = deref(context, env);
  if (isConjunction(context)) {
    yield* emitContextTerm(context.args[0], term, env);
    yield* emitContextTerm(context.args[1], term, env);
    return;
  }
  const next = env.clone();
  if (unify(term, context, next)) yield next;
}

function* emitContextParts(context, name, args, env) {
  context = deref(context, env);
  if (isConjunction(context)) {
    yield* emitContextParts(context.args[0], name, args, env);
    yield* emitContextParts(context.args[1], name, args, env);
    return;
  }
  if (context.type !== 'atom' && context.type !== 'compound') return;
  const next = env.clone();
  const argList = context.type === 'compound' ? listFromItems(context.args) : listFromItems([]);
  if (unify(name, atom(context.name), next) && unify(args, argList, next)) yield next;
}

function* holdsTerm({ goal, env }) {
  yield* emitContextTerm(goal.args[0], goal.args[1], env);
}

function* holdsParts({ goal, env }) {
  yield* emitContextParts(goal.args[0], goal.args[1], goal.args[2], env);
}
