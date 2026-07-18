export interface ViaStats {
  [key: string]: number;
}

export interface ViaRunOptions {
  proof?: boolean;
  why?: boolean;
  explain?: boolean;
  maxDepth?: number;
  solutionLimit?: number;
  registry?: BuiltinRegistry;
  sourceMetadata?: boolean;
  markRecursive?: boolean;
  strictNegation?: boolean;
  analyzeNegation?: boolean;
  [key: string]: unknown;
}

export interface ViaRunResult {
  stdout: string;
  stats: ViaStats;
}

export interface ViaSourcePart {
  text?: string;
  source?: string;
  filename?: string;
}

export interface ViaClause {
  head: ViaTerm;
  body: ViaTerm[];
  index?: number;
  filename?: string;
  clauseNumber?: number;
}

export interface ViaPredicateGroup {
  name: string;
  arity: number;
  clauses: ViaClause[];
  argIndexes: unknown[];
  pairIndexes: unknown[];
  tabled: boolean;
  mode: string[] | null;
  determinism: 'det' | 'semidet' | null;
  recursive: boolean;
  tableInputPositions: number[];
  negationStratum: number | null;
}

export type ViaTerm = Term | { type: string; name: string; args?: ViaTerm[]; arity?: number };

export class Term {
  constructor(type: string, name?: unknown, args?: ViaTerm[]);
  type: string;
  name: string;
  args: ViaTerm[];
  get arity(): number;
}

export class Env {
  constructor(bindings?: Iterable<readonly [string, ViaTerm]> | null);
  bindings: Map<string, ViaTerm>;
  clone(): Env;
  has(name: string): boolean;
  get(name: string): ViaTerm | undefined;
  bind(name: string, term: ViaTerm): void;
}

export class Program {
  constructor(clauses?: ViaClause[], options?: ViaRunOptions);
  clauses: ViaClause[];
  groups: Map<string, ViaPredicateGroup>;
  materializedGroups: Set<string>;
  hasMaterialize: boolean;
  negationDependencies: Array<{ from: string; to: string; negative: boolean }>;
  negationStratificationErrors: Array<{ from: string; to: string }>;
  stratifiedNegation: boolean;
  static parse(source: string, options?: ViaRunOptions): Program;
  static parseSources(sources?: Array<string | ViaSourcePart>, options?: ViaRunOptions): Program;
  makeGroup(name: string, arity: number): ViaPredicateGroup;
  indexClause(clause: ViaClause): void;
  findGroup(name: string, arity: number): ViaPredicateGroup | null;
  applyDeclarations(options?: ViaRunOptions): void;
  markRecursivePredicates(): void;
  analyzeNegationStratification(): Array<{ from: string; to: string }>;
  assertStratifiedNegation(): true;
  isStratifiedNegation(): boolean;
  hasMaterializeDeclarations(): boolean;
  groupIsMaterialized(group: ViaPredicateGroup): boolean;
  groupHasRule(group: ViaPredicateGroup): boolean;
  sourceFactLines(predicateKeys?: Set<string> | null): Set<string>;
  materializationGoals(): ViaTerm[];
}

export interface BuiltinDefinition {
  name: string;
  arity: number;
  handler: BuiltinHandler;
  deterministic: boolean;
  ready: ((solver: Solver, goal: ViaTerm, env: Env) => boolean) | null;
  fallbackWhenNotReady: boolean;
  shouldUse: ((solver: Solver, goal: ViaTerm, env: Env) => boolean) | null;
}

export type BuiltinHandler = (context: { solver: Solver; goal: ViaTerm; env: Env }) => Iterable<Env>;

export class BuiltinRegistry {
  constructor();
  defs: Map<string, BuiltinDefinition>;
  add(name: string, arity: number, handler: BuiltinHandler, options?: Partial<BuiltinDefinition>): this;
  get(name: string, arity: number): BuiltinDefinition | null;
}

export class Solver {
  constructor(program: Program, options?: ViaRunOptions);
  program: Program;
  registry: BuiltinRegistry;
  maxDepth: number;
  solutionLimit: number;
  solutionsSeen: number;
  active: unknown[];
  memo: Map<string, unknown>;
  stats: ViaStats;
  cloneForInnerGoal(solutionLimit?: number): Solver;
  solve(goals: ViaTerm | ViaTerm[], env?: Env, depth?: number): Iterable<Env>;
  activeVariant(goal: ViaTerm, env: Env): boolean;
}

export const VAR: 'var';
export const ATOM: 'atom';
export const STRING: 'string';
export const NUMBER: 'number';
export const COMPOUND: 'compound';

export function variable(name: string): Term;
export function atom(name: string): Term;
export function stringTerm(value: string): Term;
export function numberTerm(value: string | number): Term;
/** Construct a compound term; an empty argument list is canonicalized to atom(name). */
export function compound(name: string, args?: ViaTerm[]): Term;
export function emptyList(): Term;
export function cons(head: ViaTerm, tail: ViaTerm): Term;
export function deref(term: ViaTerm, env: Env): ViaTerm;
export function isScalar(term: ViaTerm | null | undefined): boolean;
export function isEmptyList(term: ViaTerm | null | undefined): boolean;
export function isCons(term: ViaTerm | null | undefined): boolean;
export function isConjunction(term: ViaTerm | null | undefined): boolean;
export function unify(left: ViaTerm, right: ViaTerm, env: Env): boolean;
export function cloneTerm(term: ViaTerm): Term;
export function freshTerm(term: ViaTerm, suffix: string | number): Term;
export function copyResolved(term: ViaTerm, env: Env): Term;
export function termIsGround(term: ViaTerm, env?: Env): boolean;
export function termToString(term: ViaTerm, env?: Env, quoteStrings?: boolean): string;
export function lexicalValue(term: ViaTerm, env: Env): string | null;
export function properListItems(list: ViaTerm, env: Env): ViaTerm[] | null;
export function listFromItems(items: ViaTerm[], start?: number, end?: number, tail?: ViaTerm): Term;
export function flattenConjunction(goal: ViaTerm): ViaTerm[];
export function termSignature(term: ViaTerm | null | undefined): string | null;
export function variantTerms(left: ViaTerm, leftEnv: Env, right: ViaTerm, rightEnv: Env, pairs?: Map<string, string>, reverse?: Map<string, string>): boolean;
export function compareTerms(left: ViaTerm, right: ViaTerm): number;
export function isDecimalInteger(text: string | null | undefined): boolean;
export function compareIntegerText(left: string, right: string): number;
export function parseFiniteNumber(text: string | null | undefined): number | null;
export function numberTextFromDouble(value: number): string | null;
export function compareNumberText(left: string, right: string): number;

export function makeProgram(source: string, options?: ViaRunOptions): Program;
export function parseClauses(source: string, options?: ViaRunOptions): ViaClause[];
export function parseProgramText(source: string, options?: ViaRunOptions): ViaClause[];
export function createDefaultRegistry(): BuiltinRegistry;
export function getDefaultRegistry(): BuiltinRegistry;
export function run(source: string | Program, options?: ViaRunOptions): ViaRunResult;
export function whyProof(program: Program, goal: ViaTerm, options?: ViaRunOptions): { ok: boolean; text: string };
export function whyNoProof(goal: ViaTerm): string;
export function explainProof(program: Program, goal: ViaTerm, options?: ViaRunOptions): { ok: boolean; text: string };

declare const via: {
  VAR: typeof VAR;
  ATOM: typeof ATOM;
  STRING: typeof STRING;
  NUMBER: typeof NUMBER;
  COMPOUND: typeof COMPOUND;
  Term: typeof Term;
  Env: typeof Env;
  Program: typeof Program;
  Solver: typeof Solver;
  BuiltinRegistry: typeof BuiltinRegistry;
  variable: typeof variable;
  atom: typeof atom;
  stringTerm: typeof stringTerm;
  numberTerm: typeof numberTerm;
  compound: typeof compound;
  emptyList: typeof emptyList;
  cons: typeof cons;
  deref: typeof deref;
  isScalar: typeof isScalar;
  isEmptyList: typeof isEmptyList;
  isCons: typeof isCons;
  isConjunction: typeof isConjunction;
  unify: typeof unify;
  cloneTerm: typeof cloneTerm;
  freshTerm: typeof freshTerm;
  copyResolved: typeof copyResolved;
  termIsGround: typeof termIsGround;
  termToString: typeof termToString;
  lexicalValue: typeof lexicalValue;
  properListItems: typeof properListItems;
  listFromItems: typeof listFromItems;
  flattenConjunction: typeof flattenConjunction;
  termSignature: typeof termSignature;
  variantTerms: typeof variantTerms;
  compareTerms: typeof compareTerms;
  isDecimalInteger: typeof isDecimalInteger;
  compareIntegerText: typeof compareIntegerText;
  parseFiniteNumber: typeof parseFiniteNumber;
  numberTextFromDouble: typeof numberTextFromDouble;
  compareNumberText: typeof compareNumberText;
  makeProgram: typeof makeProgram;
  parseClauses: typeof parseClauses;
  parseProgramText: typeof parseProgramText;
  createDefaultRegistry: typeof createDefaultRegistry;
  getDefaultRegistry: typeof getDefaultRegistry;
  run: typeof run;
  whyProof: typeof whyProof;
  whyNoProof: typeof whyNoProof;
  explainProof: typeof explainProof;
};

export default via;
