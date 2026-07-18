// Program representation and clause indexing.
// Indexes are deliberately conservative: they speed up common scalar arguments but never replace unification as the final check.
import { ATOM, COMPOUND, Env, compound, deref, flattenConjunction, isScalar, properListItems, termToString } from './term.js';
import { parseClauses } from './parser.js';

export class Program {
  constructor(clauses = [], options = {}) {
    this.clauses = clauses;
    this.groups = new Map();
    this.materializedGroups = new Set();
    this.hasMaterialize = false;
    for (let index = 0; index < this.clauses.length; index++) {
      const clause = this.clauses[index];
      clause.index = index;
      this.indexClause(clause);
    }
    this._negationAnalysis = null;
    this.applyDeclarations(options);
  }
  static parse(source, options = {}) {
    return new Program(parseSourceClauses(source, options), options);
  }
  static parseSources(sources = [], options = {}) {
    const clauses = [];
    for (const source of sources) {
      const parsed = typeof source === 'string'
        ? parseSourceClauses(source, options)
        : parseSourceClauses(source?.text ?? source?.source ?? '', { ...options, filename: source?.filename ?? '<input>' });
      for (const clause of parsed) clauses.push(clause);
    }
    return new Program(clauses, options);
  }
  makeGroup(name, arity) {
    // A group corresponds to one predicate indicator, for example edge/3.
    // Single-argument and pair indexes cover the common case where queries bind
    // one or two scalar arguments before calling the predicate.
    const group = {
      name,
      arity,
      clauses: [],
      argIndexes: Array.from({ length: arity }, () => ({ buckets: new Map(), fallback: [] })),
      pairIndexes: [],
      tabled: false,
      mode: null,
      determinism: null,
      recursive: false,
      tableInputPositions: [],
      scalarFactsOnly: true,
      negationStratum: null,
    };
    if (arity > 2) {
      for (let left = 0; left < arity; left++) {
        for (let right = left + 1; right < arity; right++) {
          group.pairIndexes.push({ left, right, buckets: new Map(), fallback: [] });
        }
      }
    }
    return group;
  }
  indexClause(clause) {
    const head = clause.head;
    if (head.type !== COMPOUND) return;
    const key = `${head.name}/${head.arity}`;
    let group = this.groups.get(key);
    if (!group) {
      group = this.makeGroup(head.name, head.arity);
      this.groups.set(key, group);
    }
    clause.groundHead = termHasNoVariables(head);
    clause.scalarHead = head.type === COMPOUND && head.args.every(isScalar);
    if (clause.body.length !== 0 || !clause.scalarHead) group.scalarFactsOnly = false;
    group.clauses.push(clause);
    for (let i = 0; i < head.arity; i++) indexOne(group.argIndexes[i], head.args[i], clause);
    for (const pair of group.pairIndexes) indexPair(pair, head, clause);
  }
  findGroup(name, arity) {
    return this.groups.get(`${name}/${arity}`) ?? null;
  }
  applyDeclarations(options = {}) {
    for (const clause of this.clauses) {
      const h = clause.head;
      if (clause.body.length !== 0 || h.type !== COMPOUND) continue;

      if (h.arity === 2) {
        const indicator = declarationIndicator(h.args[0], h.args[1]);
        if (!indicator) continue;
        const group = this.groups.get(indicator.key);
        if (h.name === 'materialize') {
          this.hasMaterialize = true;
          this.materializedGroups.add(indicator.key);
        } else if ((h.name === 'det' || h.name === 'semidet') && group) {
          group.determinism = h.name;
        }
        continue;
      }

      if (h.name === 'mode' && h.arity === 3) {
        const indicator = declarationIndicator(h.args[0], h.args[1]);
        if (!indicator) continue;
        const modes = declarationModes(h.args[2]);
        if (modes && modes.length === indicator.arity) {
          const group = this.groups.get(indicator.key);
          if (group) group.mode = modes;
        }
      }
    }
    // Hybrid planning is part of normal execution, so dependency analysis is
    // always performed. `markRecursive` is retained as a compatible parse
    // option but no longer disables the engine's automatic table decisions.
    this.markRecursivePredicates();
    if (options.analyzeNegation === true || options.strictNegation === true) this.analyzeNegationStratification();
    if (options.strictNegation === true) this.assertStratifiedNegation();
  }
  markRecursivePredicates() {
    // Recursion is a group-level diagnostic hint. It is computed from predicate
    // dependencies rather than from individual clauses when callers explicitly ask
    // for it.
    const groups = [...this.groups.values()];
    const indexByGroup = new Map(groups.map((group, i) => [group, i]));
    const deps = groups.map(() => new Set());
    const negativeEdges = [];
    for (const group of groups) {
      const groupIndex = indexByGroup.get(group);
      for (const clause of group.clauses) {
        for (const goal of clause.body) {
          for (const dependency of collectGoalDependencies(goal, false)) {
            const dep = this.groups.get(dependency.key);
            if (dep) {
              const dependencyIndex = indexByGroup.get(dep);
              deps[groupIndex].add(dependencyIndex);
              if (dependency.negative) negativeEdges.push([groupIndex, dependencyIndex]);
            }
          }
        }
      }
    }
    for (const group of groups) {
      const start = indexByGroup.get(group);
      const seen = new Set();
      const stack = [start];
      let recursive = false;
      while (stack.length && !recursive) {
        const current = stack.pop();
        if (seen.has(current)) continue;
        seen.add(current);
        for (const next of deps[current]) {
          if (next === start) { recursive = true; break; }
          if (!seen.has(next)) stack.push(next);
        }
      }
      group.recursive = recursive;
      group.tableInputPositions = recursive
        ? inferStructuralInputPositions(group)
        : [];
      // Recursive predicates are proved with tabling automatically, keeping
      // search control inside the engine. Cycles through negation retain
      // guarded resolution because positive least-fixed-point tabling is not
      // sound for an unstratified negative component.
      group.tabled = recursive && !componentHasNegativeEdge(start, deps, negativeEdges);
    }
  }

  analyzeNegationStratification() {
    // Stratified negation is a portability diagnostic. A program is stratified
    // when no predicate depends negatively on itself, directly or indirectly.
    const groups = [...this.groups.values()];
    const groupKeys = new Map(groups.map((group) => [group, `${group.name}/${group.arity}`]));
    const groupByKey = new Map(groups.map((group) => [`${group.name}/${group.arity}`, group]));
    const indexByKey = new Map(groups.map((group, i) => [`${group.name}/${group.arity}`, i]));
    const edges = [];

    for (const group of groups) {
      const from = groupKeys.get(group);
      for (const clause of group.clauses) {
        for (const goal of clause.body) {
          for (const dep of collectGoalDependencies(goal, false)) {
            if (!groupByKey.has(dep.key)) continue;
            edges.push({ from, to: dep.key, negative: dep.negative });
          }
        }
      }
    }

    const adjacency = groups.map(() => []);
    for (const edge of edges) {
      const from = indexByKey.get(edge.from);
      const to = indexByKey.get(edge.to);
      if (from == null || to == null) continue;
      adjacency[from].push(to);
    }

    const sccs = stronglyConnectedComponents(adjacency);
    const componentByIndex = new Map();
    for (let component = 0; component < sccs.length; component++) {
      for (const index of sccs[component]) componentByIndex.set(index, component);
    }

    const violations = [];
    const seen = new Set();
    for (const edge of edges) {
      if (!edge.negative) continue;
      const from = indexByKey.get(edge.from);
      const to = indexByKey.get(edge.to);
      if (from == null || to == null) continue;
      if (componentByIndex.get(from) !== componentByIndex.get(to)) continue;
      const key = `${edge.from}->${edge.to}`;
      if (seen.has(key)) continue;
      seen.add(key);
      violations.push({ from: edge.from, to: edge.to });
    }

    const strata = computeNegationStrata(groups, edges, indexByKey);
    for (const group of groups) group.negationStratum = strata.get(groupKeys.get(group)) ?? null;

    this._negationAnalysis = {
      dependencies: edges,
      errors: violations,
      stratified: violations.length === 0,
    };
    return violations;
  }
  ensureNegationStratification() {
    if (!this._negationAnalysis) this.analyzeNegationStratification();
    return this._negationAnalysis;
  }
  get negationDependencies() {
    return this.ensureNegationStratification().dependencies;
  }
  get negationStratificationErrors() {
    return this.ensureNegationStratification().errors;
  }
  get stratifiedNegation() {
    return this.ensureNegationStratification().stratified;
  }
  assertStratifiedNegation() {
    const violations = this.ensureNegationStratification().errors;
    if (violations.length === 0) return true;
    const details = violations.map((edge) => `${edge.from} depends negatively on ${edge.to}`).join('; ');
    throw new Error(`unstratified negation: ${details}`);
  }
  isStratifiedNegation() {
    return this.ensureNegationStratification().stratified;
  }

  hasMaterializeDeclarations() {
    return this.hasMaterialize;
  }
  groupIsMaterialized(group) {
    return this.materializedGroups.has(`${group.name}/${group.arity}`);
  }
  groupHasRule(group) {
    return group.clauses.some((clause) => clause.body.length > 0);
  }
  sourceFactLines(predicateKeys = null) {
    // Only facts for predicates that may be materialized need to be remembered.
    // On data-heavy examples this avoids formatting tens of thousands of
    // unrelated source facts just to suppress duplicate derived output.
    const lines = new Set();
    const env = new Env();
    for (const clause of this.clauses) {
      if (clause.body.length !== 0 || clause.head.type !== COMPOUND) continue;
      if (predicateKeys && !predicateKeys.has(`${clause.head.name}/${clause.head.arity}`)) continue;
      lines.add(`${termToString(clause.head, env, true)}.\n`);
    }
    return lines;
  }
  materializationGoals() {
    const hasMaterialize = this.hasMaterializeDeclarations();
    const goals = [];
    for (const group of this.groups.values()) {
      if (hasMaterialize) {
        if (!this.groupIsMaterialized(group)) continue;
      } else if (group.arity !== 2) {
        continue;
      }
      if (!this.groupHasRule(group)) continue;
      const args = [];
      for (let i = 0; i < group.arity; i++) args.push({ type: 'var', name: `X${i}`, args: [] });
      goals.push(compound(group.name, args));
    }
    return goals;
  }
}

function componentHasNegativeEdge(start, deps, negativeEdges) {
  const forward = reachableIndexes(start, deps);
  const component = new Set([...forward].filter((index) => reachableIndexes(index, deps).has(start)));
  return negativeEdges.some(([from, to]) => component.has(from) && component.has(to));
}

function reachableIndexes(start, deps) {
  const seen = new Set();
  const stack = [start];
  while (stack.length) {
    const current = stack.pop();
    if (seen.has(current)) continue;
    seen.add(current);
    for (const next of deps[current]) if (!seen.has(next)) stack.push(next);
  }
  return seen;
}

function inferStructuralInputPositions(group) {
  const patternedPositions = new Set();
  const linkedInputPositions = new Set();
  for (const clause of group.clauses) {
    const recursiveGoals = clause.body.filter((goal) =>
      goal.type === COMPOUND && goal.name === group.name && goal.arity === group.arity
    );
    if (recursiveGoals.length === 0) continue;
    const clauseChangedPositions = new Set();
    for (let index = 0; index < clause.head.args.length; index++) {
      if (clause.head.args[index].type !== 'var') patternedPositions.add(index);
      if (recursiveGoals.some((goal) => !sameClauseTerm(clause.head.args[index], goal.args[index]))) {
        clauseChangedPositions.add(index);
      }
    }
    for (let index = 0; index < clause.head.args.length; index++) {
      const headArg = clause.head.args[index];
      if (headArg.type !== 'var' || !clauseChangedPositions.has(index)) continue;
      if (clause.head.args.some((pattern, patternIndex) =>
        patternIndex !== index && pattern.type !== 'var' && termContainsVariable(pattern, headArg.name)
      )) linkedInputPositions.add(index);
    }
  }
  if (linkedInputPositions.size > 0) {
    return [[...linkedInputPositions].sort((left, right) => left - right)[0]];
  }
  if (patternedPositions.size > 0) {
    return [[...patternedPositions].sort((left, right) => left - right)[0]];
  }
  return Array.from({ length: group.arity }, (_, index) => index);
}

function termContainsVariable(term, name) {
  if (term.type === 'var') return term.name === name;
  return term.args.some((arg) => termContainsVariable(arg, name));
}

function sameClauseTerm(left, right) {
  if (left.type !== right.type || left.name !== right.name || left.args.length !== right.args.length) return false;
  return left.args.every((arg, index) => sameClauseTerm(arg, right.args[index]));
}

function termHasNoVariables(term) {
  if (!term || term.type === 'var') return false;
  return !term.args?.some((arg) => !termHasNoVariables(arg));
}

function collectGoalDependencies(goal, negated) {
  if (goal.type !== COMPOUND) return [];
  if (goal.name === ',' && goal.arity === 2) {
    return [
      ...collectGoalDependencies(goal.args[0], negated),
      ...collectGoalDependencies(goal.args[1], negated),
    ];
  }
  if (goal.name === 'not' && goal.arity === 1) {
    return collectGoalDependencies(goal.args[0], !negated);
  }
  if (goal.name === 'once' && goal.arity === 1) {
    return collectGoalDependencies(goal.args[0], negated);
  }
  if (goal.name === 'forall' && goal.arity === 2) {
    return [
      ...collectGoalDependencies(goal.args[0], negated),
      ...collectGoalDependencies(goal.args[1], negated),
    ];
  }
  if ((goal.name === 'findall' || goal.name === 'sumall') && goal.arity === 3) {
    return collectGoalDependencies(goal.args[1], negated);
  }
  if (goal.name === 'countall' && goal.arity === 2) return collectGoalDependencies(goal.args[0], negated);
  if ((goal.name === 'aggregate_min' || goal.name === 'aggregate_max') && goal.arity === 5) {
    return collectGoalDependencies(goal.args[2], negated);
  }
  return [{ key: `${goal.name}/${goal.arity}`, negative: negated }];
}

function stronglyConnectedComponents(adjacency) {
  let index = 0;
  const stack = [];
  const onStack = new Set();
  const indexes = new Map();
  const lowlinks = new Map();
  const components = [];

  function visit(v) {
    indexes.set(v, index);
    lowlinks.set(v, index);
    index++;
    stack.push(v);
    onStack.add(v);

    for (const w of adjacency[v]) {
      if (!indexes.has(w)) {
        visit(w);
        lowlinks.set(v, Math.min(lowlinks.get(v), lowlinks.get(w)));
      } else if (onStack.has(w)) {
        lowlinks.set(v, Math.min(lowlinks.get(v), indexes.get(w)));
      }
    }

    if (lowlinks.get(v) === indexes.get(v)) {
      const component = [];
      while (true) {
        const w = stack.pop();
        onStack.delete(w);
        component.push(w);
        if (w === v) break;
      }
      components.push(component);
    }
  }

  for (let v = 0; v < adjacency.length; v++) {
    if (!indexes.has(v)) visit(v);
  }
  return components;
}

function computeNegationStrata(groups, edges, indexByKey) {
  const strata = new Map(groups.map((group) => [`${group.name}/${group.arity}`, 0]));
  if (groups.length === 0) return strata;

  for (let pass = 0; pass < groups.length; pass++) {
    let changed = false;
    for (const edge of edges) {
      if (!indexByKey.has(edge.from) || !indexByKey.has(edge.to)) continue;
      const fromStratum = strata.get(edge.from) ?? 0;
      const required = (strata.get(edge.to) ?? 0) + (edge.negative ? 1 : 0);
      if (fromStratum < required) {
        strata.set(edge.from, required);
        changed = true;
      }
    }
    if (!changed) return strata;
  }
  return new Map(groups.map((group) => [`${group.name}/${group.arity}`, null]));
}

function declarationIndicator(name, arity) {
  if (name?.type !== ATOM || arity?.type !== 'number') return null;
  if (!/^\d+$/.test(arity.name)) return null;
  const arityNumber = Number(arity.name);
  return { name: name.name, arity: arityNumber, key: `${name.name}/${arityNumber}` };
}

function declarationModes(term) {
  const items = properListItems(term, new Env());
  if (!items) return null;
  const modes = [];
  for (const item of items) {
    if (item.type !== ATOM) return null;
    if (!['in', 'out', 'any'].includes(item.name)) return null;
    modes.push(item.name);
  }
  return modes;
}

function indexOne(index, arg, clause) {
  if (isScalar(arg)) {
    const bucket = index.buckets.get(arg.name);
    if (bucket) bucket.push(clause);
    else index.buckets.set(arg.name, [clause]);
  } else {
    index.fallback.push(clause);
  }
}

function pairKey(left, right) {
  return `${left.name}\x1f${right.name}`;
}

function indexPair(pair, head, clause) {
  const left = head.args[pair.left];
  const right = head.args[pair.right];
  if (isScalar(left) && isScalar(right)) {
    const key = pairKey(left, right);
    const bucket = pair.buckets.get(key);
    if (bucket) bucket.push(clause);
    else pair.buckets.set(key, [clause]);
  } else {
    pair.fallback.push(clause);
  }
}

export function selectClauseCandidates(group, goal, env) {
  // Pick the narrowest applicable index. Fallback clauses remain in the result
  // because clauses with variables or compound heads can still unify later.
  let bestPrimary = group.clauses;
  let bestFallback = [];
  let bestLen = group.clauses.length;
  let indexed = false;
  if (goal.type !== COMPOUND) return { primary: bestPrimary, fallback: bestFallback };

  for (let i = 0; i < goal.arity; i++) {
    const arg = deref(goal.args[i], env);
    if (!isScalar(arg)) continue;
    const index = group.argIndexes[i];
    const bucket = index.buckets.get(arg.name) ?? [];
    const candidateLen = bucket.length + index.fallback.length;
    if (!indexed || candidateLen < bestLen) {
      bestPrimary = bucket;
      bestFallback = index.fallback;
      bestLen = candidateLen;
      indexed = true;
      if (bestLen === 0) break;
    }
  }

  for (const pair of group.pairIndexes) {
    const left = deref(goal.args[pair.left], env);
    const right = deref(goal.args[pair.right], env);
    if (!isScalar(left) || !isScalar(right)) continue;
    const bucket = pair.buckets.get(pairKey(left, right)) ?? [];
    const candidateLen = bucket.length + pair.fallback.length;
    if (!indexed || candidateLen < bestLen) {
      bestPrimary = bucket;
      bestFallback = pair.fallback;
      bestLen = candidateLen;
      indexed = true;
      if (bestLen === 0) break;
    }
  }

  return { primary: bestPrimary, fallback: bestFallback };
}

export function makeProgram(source, options = {}) {
  return Program.parse(source, options);
}

export function parseSourceClauses(source, options = {}) {
  return parseClauses(source, options);
}
