// Term-inspection builtins for reusable meta-programming over via terms.
import { atom, compound, deref, listFromItems, lexicalValue, numberTerm, properListItems, stringTerm, unify } from '../term.js';

export const termBuiltins = {
  register(registry) {
    registry.add('functor', 3, functorBuiltin, { deterministic: true, fallbackWhenNotReady: true, ready: firstNonvarReady });
    registry.add('arg', 3, argBuiltin, { deterministic: true, fallbackWhenNotReady: true, ready: argReady });
    registry.add('compound_name_arguments', 3, compoundNameArguments, { deterministic: true, fallbackWhenNotReady: true, ready: compoundNameArgumentsReady });
  }
};


function firstNonvarReady(goal, env) {
  return deref(goal.args[0], env).type !== 'var';
}

function argReady(goal, env) {
  return /^\d+$/.test(lexicalValue(goal.args[0], env) ?? '') && deref(goal.args[1], env).type === 'compound';
}

function compoundNameArgumentsReady(goal, env) {
  const term = deref(goal.args[0], env);
  if (term.type === 'compound' || term.type === 'atom') return true;
  return term.type === 'var' && lexicalValue(goal.args[1], env) !== null && properListItems(goal.args[2], env) !== null;
}

function* functorBuiltin({ goal, env }) {
  const term = deref(goal.args[0], env);
  if (term.type === 'var') return;
  const nameTerm = term.type === 'compound' ? atom(term.name) : scalarNameTerm(term);
  const arity = term.type === 'compound' ? term.arity : 0;
  const next = env.clone();
  if (unify(goal.args[1], nameTerm, next) && unify(goal.args[2], numberTerm(arity), next)) yield next;
}

function* argBuiltin({ goal, env }) {
  const indexText = lexicalValue(goal.args[0], env);
  if (!/^\d+$/.test(indexText ?? '')) return;
  const index = Number(indexText);
  const term = deref(goal.args[1], env);
  if (term.type !== 'compound' || !Number.isSafeInteger(index) || index < 1 || index > term.arity) return;
  const next = env.clone();
  if (unify(goal.args[2], term.args[index - 1], next)) yield next;
}

function* compoundNameArguments({ goal, env }) {
  const term = deref(goal.args[0], env);
  if (term.type === 'compound' || term.type === 'atom') {
    const next = env.clone();
    const args = term.type === 'compound' ? term.args : [];
    if (unify(goal.args[1], atom(term.name), next) && unify(goal.args[2], listFromItems(args), next)) yield next;
    return;
  }
  if (term.type !== 'var') return;

  const name = lexicalValue(goal.args[1], env);
  const args = properListItems(goal.args[2], env);
  if (name == null || !args) return;
  const next = env.clone();
  const built = args.length === 0 ? atom(name) : compound(name, args);
  if (unify(goal.args[0], built, next)) yield next;
}


function scalarNameTerm(term) {
  if (term.type === 'atom') return atom(term.name);
  if (term.type === 'number') return numberTerm(term.name);
  return stringTerm(term.name);
}
