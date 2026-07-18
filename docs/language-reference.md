# Via Language Reference

## Table of contents

- [Abstract](#abstract)
- [1. Terminology and normative language](#1-terminology-and-normative-language)
- [2. Design goals](#2-design-goals)
- [3. Lexical structure](#3-lexical-structure)
  - [3.1 Character stream](#31-character-stream)
  - [3.2 Unicode and UTF-8](#32-unicode-and-utf-8)
  - [3.3 Comments](#33-comments)
  - [3.4 Punctuation tokens](#34-punctuation-tokens)
  - [3.5 Variables](#35-variables)
  - [3.6 Atom constants](#36-atom-constants)
  - [3.7 Strings](#37-strings)
  - [3.8 Numbers](#38-numbers)
- [4. Surface grammar](#4-surface-grammar)
  - [4.1 EBNF grammar](#41-ebnf-grammar)
  - [4.2 Grammar notes](#42-grammar-notes)
- [5. Terms](#5-terms)
  - [5.1 Variables](#51-variables)
  - [5.2 Atom constants, strings, and numbers](#52-atom-constants-strings-and-numbers)
  - [5.3 Compound terms and atomic formulas](#53-compound-terms-and-atomic-formulas)
  - [5.4 Lists](#54-lists)
  - [5.5 Comma terms](#55-comma-terms)
- [6. Clauses and predicates](#6-clauses-and-predicates)
- [7. Goals and proof search](#7-goals-and-proof-search)
  - [7.1 Unification](#71-unification)
  - [7.2 Failure](#72-failure)
  - [7.3 Finite search expectation](#73-finite-search-expectation)
- [8. Logical reading: Herbrand semantics](#8-logical-reading-herbrand-semantics)
  - [8.1 Variables and quantification](#81-variables-and-quantification)
  - [8.2 Equality, identity, and unification](#82-equality-identity-and-unification)
  - [8.3 Goal-directed execution versus model-theoretic meaning](#83-goal-directed-execution-versus-model-theoretic-meaning)
  - [8.4 Built-ins and operational extensions](#84-built-ins-and-operational-extensions)
- [9. Standard built-in predicates](#9-standard-built-in-predicates)
  - [9.1 Equality and unification](#91-equality-and-unification)
  - [9.2 Arithmetic](#92-arithmetic)
  - [9.3 Comparison](#93-comparison)
  - [9.4 Dates and durations](#94-dates-and-durations)
  - [9.5 Generators](#95-generators)
  - [9.6 Strings and atom constants](#96-strings-and-atom-constants)
  - [9.7 Lists](#97-lists)
  - [9.8 Aggregation and ordering](#98-aggregation-and-ordering)
  - [9.9 Context and term inspection](#99-context-and-term-inspection)
  - [9.10 Search control](#910-search-control)
- [10. Implementation-specific built-ins](#10-implementation-specific-built-ins)
- [11. Declarations](#11-declarations)
  - [11.1 Automatic hybrid reasoning](#111-automatic-hybrid-reasoning)
  - [11.2 Default-output materialization](#112-default-output-materialization)
- [12. via Sockets](#12-via-sockets)
  - [12.1 Socket vocabulary](#121-socket-vocabulary)
  - [12.2 Socket example](#122-socket-example)
  - [12.3 Sockets and AI agents](#123-sockets-and-ai-agents)
- [13. Output and read-back profile](#13-output-and-read-back-profile)
  - [13.1 Explanation output](#131-explanation-output)
- [14. Conformance](#14-conformance)
- [15. Relationship to ISO Prolog](#15-relationship-to-iso-prolog)
- [16. Examples](#16-examples)
  - [16.1 Transitive closure](#161-transitive-closure)
  - [16.2 Arithmetic](#162-arithmetic)
  - [16.3 Lists](#163-lists)
  - [16.4 Negation as failure](#164-negation-as-failure)
- [17. Security and portability considerations](#17-security-and-portability-considerations)

## Abstract

Via is a compact definite-clause language whose surface syntax is Prolog-like term and clause syntax with deliberate via choices for rule-based programs over ordinary terms, lists, arithmetic, strings, and finite search. A Via program is a finite sequence of facts and Horn clauses. The underlying declarative semantics of the pure language is **Herbrand semantics**: constants, compound terms, and lists denote themselves, and predicates denote sets of ground atomic formulas over those terms. Evaluation is goal-directed: goals are solved by unification against facts, rules, and a fixed set of built-in predicates.

Via is intentionally smaller than ISO Prolog. It supports compact Horn-clause reasoning, list processing, arithmetic examples, finite search, and context data, without operators, cut, modules, dynamic predicates, DCGs, zero-arity compound syntax, or a complete ISO standard library.

## 1. Terminology and normative language

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are to be interpreted as normative requirements.

A **term** is a variable, atom constant, string, number, list, or compound term.

An **atom constant** is a symbolic scalar term, such as `pat`, `type`, or `'atom with spaces'`. It is a term and may appear as an argument, list element, functor name, or predicate name.

An **atomic formula** is a predicate application such as `parent(pat, jan)` or `status(case1, accepted)`. It is the unit of truth in a Herbrand interpretation. In some logic-programming literature atomic formulas are called "atoms"; this specification avoids that shorthand. Whenever the noun "atom" appears here outside the phrase "atomic formula", it means **atom constant**.

This distinction is normative: `pat` is an atom constant and can appear as a term argument; `parent(pat, jan)` is an atomic formula and can appear as a fact, rule head, or goal. A compound term such as `pair(pat, jan)` has the same surface shape as an atomic formula, but its role is determined by context: as data it is a compound term, and as a clause head or goal it is an atomic formula with predicate symbol `pair/2`.

A **clause** is either a fact such as `parent(pat, jan).` or a rule such as `ancestor(X, Y) :- parent(X, Y).`.

A **goal** is an atomic formula, a built-in call, or a comma conjunction.

A **source fact** is a fact written directly in the input program. A **new derivation** is a ground consequence found through at least one rule and not merely repeated from the source facts.

The **Herbrand universe** of a program is the set of all ground via terms constructible from the constants and functors in the program, together with the built-in list constructors `[]` and `./2` where lists are used. The **Herbrand base** is the set of all ground atomic formulas whose predicate symbols occur in the program and whose arguments are terms from the Herbrand universe.

## 2. Design goals

Via is designed to be:

- small enough to embed and audit;
- deterministic in textual output order after duplicate suppression;
- useful for relation-style `p(S, O)` output through ordinary predicate names;
- practical for examples involving recursion, lists, arithmetic, strings, aggregation, finite search, and context-valued data.

Non-goals include complete ISO Prolog compatibility, operator declarations, module systems, dynamic database updates, cut-based control, and full bottom-up closure semantics.

## 3. Lexical structure

### 3.1 Character stream
Input is Unicode text. Whitespace separates tokens and is otherwise insignificant outside quoted strings and quoted atom constants.


### 3.2 Unicode and UTF-8
Via source files are UTF-8.

Quoted atoms and strings may contain Unicode text:

```via
name(alice, 'Élodie').
city('München').
message("café").
```

Unquoted atoms and variables intentionally use ASCII syntax. This keeps programs portable and makes the Prolog-style distinction between atoms and variables clear: lowercase names are atoms, while uppercase and underscore names are variables.

Use quoted atoms for non-ASCII names.

### 3.3 Comments
A percent sign starts a line comment outside quoted strings and quoted atom constants. The comment extends to the end of the line.

```via
parent(pat, jan).  % this is a comment
```

### 3.4 Punctuation tokens
The punctuation tokens are:

```text
(  )  [  ]  ,  |  .  :-
```

A colon outside `:-` is not part of the language. Namespace-like names SHOULD be written as explicit atom constants such as `person_type`, `odrl_permission`, or quoted atoms such as `'org.schema'`.

### 3.5 Variables
A variable is either the bare anonymous variable `_`, or starts with an uppercase ASCII letter or underscore and then zero or more ASCII letters, digits, or underscores. This is the source-level variable spelling used by ISO Prolog.

Examples:

```via
X
Person
_thing
_
```

Each bare `_` anonymous variable occurrence is fresh. A name such as `_thing` is a named variable and is reused within its clause.

### 3.6 Atom constants
A plain atom constant starts with a lowercase ASCII letter and is followed by zero or more ASCII letters, digits, or underscores. A dot is not part of a plain atom; dotted web spaces such as `'be.ugent'` or `'org.schema'` MUST be quoted if they are meant as one atom constant. Names such as `a-b` MUST also be quoted if they are meant as one atom constant:

```via
pat
type
case_123
'be.ugent'
'org.schema'
'eyereasoner.github'
'a-b'
```

IRI-shaped atom constants SHOULD be written as quoted atoms containing the angle brackets. This keeps the surface syntax ISO Prolog-compatible while preserving the visible web identifier text:

```via
'<https://example.org/alice>'
'<urn:example:bob>'
triple('<https://example.org/alice>', '<https://schema.org/name>', "Alice").
```

Unquoted angle-bracket IRI syntax is not part of the source language. If the angle brackets are part of the atom name, include them inside the quoted atom, for example `'<https://example.org/alice>'`.

A quoted atom constant is enclosed in single quotes. A single quote inside a quoted atom constant is represented by doubling it:

```via
'atom with spaces'
'needs''quote'
''
```

A graphic atom constant is one or more graphic characters from this set:

```text
#$&*+-/<=>@^~\
```

Graphic atoms such as `<=>`, `<`, and `>=` remain graphic atoms. Longer names containing letters or punctuation outside the graphic set should be quoted, for example `'<abc>'`.

### 3.7 Strings
A string is enclosed in double quotes. The implementation supports common escapes such as `\n`, `\t`, `\"`, and `\\`.

### 3.8 Numbers
Numbers are scalar terms. Integers, decimal numbers, and scientific notation are accepted:

```via
0
-42
0.25
1.25e-3
1.25e+3
```

Integer arithmetic built-ins use arbitrary-precision decimal strings where possible. Floating operations use the host implementation's IEEE-754 double-precision behavior.

## 4. Surface grammar

This section gives the portable source grammar in EBNF. Lexical tokens are defined in section 3. Whitespace and comments may appear between tokens and are otherwise ignored.

### 4.1 EBNF grammar

```text
program             ::= { clause } ;

clause              ::= head, "."
                      | head, ":-", goal-list, "." ;

head                ::= term ;

goal-list           ::= term, { ",", term } ;

term                ::= variable
                      | atom-constant
                      | string
                      | number
                      | compound
                      | list
                      | parenthesized-term ;

compound            ::= atom-constant, "(", term, { ",", term }, ")" ;

list                ::= "[", "]"
                      | "[", list-items, "]" ;

list-items          ::= term, { ",", term }, [ "|", term ] ;

parenthesized-term  ::= "(", term, [ ",", term, { ",", term } ], ")" ;

variable            ::= "_"
                      | variable-start, { name-continue } ;

atom-constant       ::= plain-atom
                      | quoted-atom
                      | graphic-atom ;

plain-atom          ::= lowercase-letter, { name-continue } ;

quoted-atom         ::= "'", { quoted-atom-char }, "'" ;

quoted-atom-char    ::= non-single-quote-char
                      | "''"
                      | escape-sequence ;

string              ::= '"', { string-char }, '"' ;

string-char         ::= non-double-quote-char
                      | '""'
                      | escape-sequence ;

number              ::= [ "-" ], digits, [ ".", digits ], [ exponent ] ;

exponent            ::= ( "e" | "E" ), [ "+" | "-" ], digits ;

graphic-atom        ::= graphic-char, { graphic-char } ;

variable-start      ::= uppercase-letter | "_" ;

name-continue       ::= uppercase-letter | lowercase-letter | digit | "_" ;

digits              ::= digit, { digit } ;

escape-sequence     ::= "\\", any-char ;

uppercase-letter    ::= "A" | ... | "Z" ;
lowercase-letter    ::= "a" | ... | "z" ;
digit               ::= "0" | ... | "9" ;

non-single-quote-char ::= any source character except "'", "\\", or end of input ;
non-double-quote-char ::= any source character except '"', "\\", or end of input ;
any-char           ::= any source character except end of input ;

graphic-char        ::= "#" | "$" | "&" | "*" | "+" | "-" | "/" | "<"
                      | "=" | ">" | "@" | "^" | "~" | "\\" ;
```

### 4.2 Grammar notes

The `atom-constant` nonterminal is a lexical class for symbolic scalar terms, not an atomic formula. Atomic formulas are represented by the `compound` alternative when such a term appears as a clause head, rule body, or selected goal. The functor or predicate name is always an atom constant; Via does not support variables in functor or predicate position.

A portable clause head SHOULD be a compound term. Non-compound heads are parsed, but they are not useful in the current predicate index.

Compound syntax always has at least one argument. Arity-zero data is written as an atom constant, not as a zero-arity compound:

```via
value(example, nil).
```

The syntax `nil()` is intentionally rejected so Via source and read-back output use one representation for arity-zero data. Host APIs SHOULD follow the same rule: constructing a term with an atom name and an empty argument list is canonicalized to the atom constant itself.

Parentheses around a single term are accepted and denote that same term. Parentheses around two or more comma-separated terms denote a right-associated comma term using the functor `','/2`. When such a comma term appears as a goal, it is evaluated as conjunction.

A quoted atom represents an atom constant. A doubled single quote inside a quoted atom represents one literal single quote. A backslash may introduce an escaped character in quoted atoms and strings. Portable source SHOULD use the common escapes `\\`, `\n`, `\t`, `\'` in quoted atoms, and `\\`, `\n`, `\t`, `\"` in strings.

A percent sign outside a quoted atom or string starts a line comment that extends to the end of the line.

## 5. Terms

### 5.1 Variables

Variables are scoped to a single clause or selected goal. A variable in a rule head and body denotes the same logical variable within that clause. Names preserve their spelling, so repeated `X` occurrences in one clause refer to the same variable.

### 5.2 Atom constants, strings, and numbers

Atom constants, strings, and numbers are distinct scalar term kinds. Two scalar terms unify only when their type and lexical value match, except where a built-in explicitly interprets lexical values.

### 5.3 Compound terms and atomic formulas

A compound term has a functor name and arity:

```via
parent(pat, jan)
pair(3, nested(atom, [x, y]))
```

The same concrete syntax is used for atomic formulas when the compound appears as a fact, rule head, or goal. In `parent(pat, jan).`, `parent/2` is a predicate symbol and the whole expression is an atomic formula. In `value(x, parent(pat, jan)).`, the inner `parent(pat, jan)` is ordinary compound data.

The functor or predicate name is fixed syntactically and is written as an atom constant. via does not support variables in predicate or functor position.

### 5.4 Lists

Lists use Prolog surface syntax and are represented internally with `./2` and `[]`:

```via
[]
[a, b, c]
[a, b | tail]
```

### 5.5 Comma terms

Parenthesized comma terms may be goals or data:

```via
(parent(pat, jan), parent(jan, emma))
(name(alice, "Alice"), knows(alice, bob))
```

When a comma term appears as a goal, it is evaluated as conjunction. When it appears as data, it remains a term. `holds/2` enumerates member terms inside such contexts, and `holds/3` exposes each member as a predicate name plus an argument list for any arity.

## 6. Clauses and predicates

A fact has no body:

```via
parent(pat, jan).
```

A rule has a head and a body:

```via
ancestor(X, Y) :-
  parent(X, Y).

ancestor(X, Z) :-
  parent(X, Y),
  ancestor(Y, Z).
```

Clauses with the same predicate name and arity define one predicate group. Predicate name and arity are both significant: `p/1` and `p/2` are different predicates.

## 7. Goals and proof search

Goals are solved left-to-right. For a user-defined atomic-formula goal, via selects candidate clauses by predicate name, arity, and available indexes. A candidate clause is freshened, its head is unified with the goal, and then its body is solved.

A conjunction goal succeeds when all conjunct goals succeed in order. An answer is printed as the resolved answer term followed by a period.

### 7.1 Unification

Unification follows the ordinary first-order term structure used by the language. The implementation does not perform an occurs check.

### 7.2 Failure

A goal fails when no built-in case or user clause can prove it. via has no exception term language; parse errors and resource failures are implementation errors reported to the host.

### 7.3 Finite search expectation

Programs and selected output goals SHOULD be written so the relevant search space is finite. via includes recursion guards and tabling support, but it is not required to terminate for arbitrary recursive logic programs.

## 8. Logical reading: Herbrand semantics

The pure Via language is interpreted over the **Herbrand universe** and **Herbrand base**. The Herbrand universe is the first-order universe made only of the ground terms that can be built from the program's atom constants, strings, numbers, list constructors, and compound functors. There are no hidden domain elements: a term denotes itself. For example, the atom constant `pat` denotes the Herbrand constant `pat`, and the number `3` denotes the numeric Herbrand constant written `3`. The Herbrand base is separate from the universe: it contains ground atomic formulas such as `parent(pat, jan)`, whose predicate symbol is `parent/2` and whose arguments are Herbrand terms.

An atom constant by itself is not true or false. For example, `pat` is a term, not a proposition. Truth applies to atomic formulas: `person(pat)` may be true or false in a Herbrand interpretation, while `pat` is simply one possible argument term.

A **Herbrand interpretation** for a program is a set of ground atomic formulas that are considered true. A source fact such as:

```via
parent(pat, jan).
```

places the ground atomic formula `parent(pat, jan)` in the interpretation. A rule such as:

```via
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
```

is read universally over Herbrand terms: for every substitution of `X`, `Y`, and `Z` by ground Herbrand terms, if both ground body atomic formulas are true, then the ground head atomic formula is true. The declarative meaning of a pure program is the **least Herbrand model**: the smallest set of ground atomic formulas that contains all facts and is closed under all rules.

Equivalently, the least Herbrand model is obtained by repeatedly applying the immediate-consequence operation: start with the source facts, add every ground rule head whose ground body is already true, and continue to the least fixed point. This definition is mathematical; an implementation does not have to compute the model bottom-up.

### 8.1 Variables and quantification

Variables do not range over external objects, records, pointers, or host-language values. In the logical reading, variables range over Herbrand terms. A rule is implicitly universally quantified over its variables. A selected goal is existential in the usual logic-programming sense: via searches for substitutions of its variables by Herbrand terms that make the goal true with respect to the program.

via has no blank nodes and no existential variables in rule heads. Existential-style consequences SHOULD be represented by explicit Herbrand witness terms written directly in rule heads:

```via
has_parent(Child, parent_of(Child)) :-
  person(Child).

registration(Student, Course, registration_of(Student, Course)) :-
  takes(Student, Course).
```

These rules may derive `parent_of(alice)` or `registration_of(alice, logic)` as ordinary visible Herbrand terms. The witness is deterministic: the same functor and inputs produce the same term, while different inputs produce different terms by normal syntactic identity. This is the practical executable form of existential-style consequences in Via; it does not introduce hidden blank nodes or special quantifier syntax.

### 8.2 Equality, identity, and unification

Because the domain is Herbrand, equality in the pure language is syntactic identity of terms after substitution. Two distinct atom constants are distinct. Two compound terms are equal only when they have the same functor, the same arity, and pairwise equal arguments. Lists follow the same rule through their `[]` and `./2` representation.

Operationally, via uses first-order unification to find substitutions. The implementation does not perform an occurs check, so cyclic terms are not part of the portable Herbrand reading even if a particular implementation can temporarily construct recursive bindings internally. Portable programs SHOULD avoid relying on occurs-check-sensitive cases such as `eq(X, f(X))`.

### 8.3 Goal-directed execution versus model-theoretic meaning

via's CLI and library evaluator are goal-directed. They try to prove requested goals by resolving them against facts, rules, and built-ins, using clause order, goal order, indexing, tabling, and deterministic built-in execution. This operational strategy is intended to enumerate answers that are true in the least Herbrand model for the pure Horn-clause fragment, but it is not a complete bottom-up model enumerator. Non-terminating recursion or infinite generators can prevent an answer from being found even when the answer belongs to the least Herbrand model.

Default CLI output is also a host behavior, not a separate semantics. It asks broad materialization goals, suppresses duplicates, excludes source facts, keeps ground answers, and prints selected consequences. Embedders can still access the goal-directed solver directly through the implementation API.

### 8.4 Built-ins and operational extensions

Built-ins are specified relations or operations added to the Herbrand core. A built-in call in a goal has the syntax of an atomic formula, but its success relation is specified procedurally here rather than by source clauses. Some built-ins, such as `eq/2`, `append/3`, `member/2`, and `length/2`, can be understood as relations over Herbrand terms. Others, such as arithmetic, string matching, date/time predicates, aggregation, `once/1`, and negation-as-failure, are operational extensions whose behavior is defined by this specification rather than by pure least-Herbrand-model semantics alone.

Arithmetic and string built-ins do not introduce a separate semantic universe. They inspect the lexical values of already represented Herbrand constants and, when they succeed, bind output arguments to via terms such as numbers, strings, or atom constants. For example, `add(2, 3, X)` may bind `X` to the number term `5`; it does not mean that variables range over host-language numbers outside the Herbrand universe.

Negation-as-failure `not(Goal)` is especially operational: it succeeds when the current goal-directed search finds no solution for `Goal`. It is not classical negation and should not be read as adding negative facts to the Herbrand model. Programs using negation SHOULD keep the negated goal sufficiently ground and finite.

### 8.5 Stratified negation

Portable programs using user-defined predicates under `not/1` SHOULD be **stratified**. A program is stratified when no predicate depends negatively on itself, either directly or through a cycle of other predicate dependencies. In a stratified program, predicates can be assigned strata so that positive dependencies stay in the same or a lower stratum and negative dependencies point strictly to a lower stratum.

For example, this is stratified because `open/1` depends negatively on `closed/1`, but `closed/1` does not depend back on `open/1`:

```via
closed(X) :- blocked(X).
open(X) :- candidate(X), not(closed(X)).
```

This is not stratified because `p/1` and `q/1` form a cycle that contains a negative dependency:

```via
p(X) :- q(X).
q(X) :- not(p(X)).
```

The JavaScript implementation records stratification metadata on `Program` instances: `stratifiedNegation`, `negationStratificationErrors`, `negationDependencies`, and per-group `negationStratum`. This diagnostic is computed lazily when one of those properties or helper methods is first read, or eagerly when parsing with `{ analyzeNegation: true }` or `{ strictNegation: true }`. The CLI option `-w` / `--warnings` requests this diagnostic and prints non-fatal warnings to stderr. Embedders that want to reject non-portable negation can parse with `{ strictNegation: true }` or call `program.assertStratifiedNegation()`.

## 9. Standard built-in predicates

This section specifies the **standard built-ins** of the Via language. An implementation that claims support for this standard built-in profile MUST implement the predicates in this section with the meanings described here.

A built-in call is still written as an atomic formula, but the relation is provided by the host implementation rather than by source clauses. Several built-ins are mode-sensitive: they are intended to run when their input arguments are sufficiently ground, and implementations may leave user-defined clauses visible when that mode is not yet satisfied.

Implementations MAY provide additional built-ins, but such built-ins are implementation-specific and are not part of this normative catalog. Implementation-specific built-ins are discussed separately in section 10.

### 9.1 Equality and unification

| Built-in | Meaning |
|---|---|
| `eq(A, B)` | Succeeds when `A` and `B` unify. |
| `neq(A, B)` | Succeeds when `A` and `B` do not unify. |

### 9.2 Arithmetic

| Built-in | Meaning |
|---|---|
| `neg(A, B)` | `B` is the numeric negation of `A`. |
| `abs(A, B)` | `B` is the absolute value of `A`. |
| `sin(A, B)`, `cos(A, B)`, `tan(A, B)` | Trigonometric floating functions. |
| `asin(A, B)`, `acos(A, B)`, `atan2(Y, X, Angle)` | Inverse trigonometric floating functions. |
| `sqrt(A, B)` | Square root. Fails for negative inputs. |
| `floor(A, B)`, `ceiling(A, B)`, `trunc(A, B)`, `rounded(A, B)` | Integer-valued numeric rounding functions. |
| `exp(A, B)`, `log(A, B)` | Natural exponent and logarithm. `log/2` fails for non-positive inputs. |
| `add(A, B, C)` | `C = A + B`. |
| `sub(A, B, C)` | `C = A - B`. |
| `mul(A, B, C)` | `C = A * B`. |
| `div(A, B, C)` | `C = A / B`; integer inputs use integer division. |
| `mod(A, B, C)` | Integer remainder. |
| `pow(A, B, C)` | `C = A^B`. |
| `min(A, B, C)`, `max(A, B, C)` | Numeric minimum and maximum. |

### 9.3 Comparison

| Built-in | Meaning |
|---|---|
| `lt(A, B)` | `A < B`. |
| `gt(A, B)` | `A > B`. |
| `le(A, B)` | `A =< B`. |
| `ge(A, B)` | `A >= B`. |

Comparisons interpret numeric-looking terms numerically. Other scalar terms are compared lexically.

### 9.4 Dates and durations

| Built-in | Meaning |
|---|---|
| `local_time(T)` | Binds `T` to the local date string. For deterministic runs, `VIA_LOCAL_TIME=YYYY-MM-DD` overrides the current date. |
| `difference(A, B, D)` | Computes an ISO-like date/duration difference. |

### 9.5 Generators

| Built-in | Meaning |
|---|---|
| `between(Low, High, X)` | Enumerates integers from `Low` through `High`. |
| `smallest_divisor_from(N, Start, D)` | Finds a divisor of `N` starting at `Start`. |

### 9.6 Strings and atom constants

| Built-in | Meaning |
|---|---|
| `str_concat(A, B, C)` | String concatenation. |
| `contains(Text, Needle)` | `Text` contains `Needle`. |
| `matches(Text, Pattern)` | Text matches a simple implementation regex/search pattern. |
| `matches(Text, Pattern, Context)` | `Text` matches a JavaScript regular expression with named capture groups; `Context` is a comma context containing one unary term per matched capture group. |
| `not_matches(Text, Pattern)` | Negation of `matches/2`. |
| `split(Text, Separator, Parts)` | Splits text into a proper list of strings. |
| `join(Parts, Separator, Text)` | Joins a proper list of scalar terms into a string. |
| `substring(Text, Start, Length, Out)` | Extracts a zero-based substring. |
| `replace(Text, Search, Replacement, Out)` | Replaces all non-empty literal occurrences of `Search`. |
| `lowercase(Text, Out)`, `uppercase(Text, Out)`, `trim(Text, Out)` | Text normalization helpers. |
| `number_string(Number, String)` | Converts a number to a string or parses a numeric string into a number. |
| `atom_string(Atom, String)` | Converts between atom constants and strings. |
| `term_string(Term, String)` | Renders a ground term as its via source string. |

### 9.7 Lists

| Built-in | Meaning |
|---|---|
| `append(A, B, C)` | List append/split relation. |
| `nth0(Index, List, Value)` | Zero-based list lookup. |
| `set_nth0(Index, List, Value, Out)` | Functional list update. |
| `head(List, Head)` | Head of a non-empty list. |
| `rest(List, Tail)` | Tail of a non-empty list. |
| `last(List, Last)` | Last element of a non-empty proper list. |
| `take(N, List, Prefix)` | First `N` items of a proper list. |
| `drop(N, List, Suffix)` | Proper-list suffix after dropping `N` items. |
| `slice(Start, Length, List, Slice)` | Zero-based proper-list slice. |
| `member(X, List)` | Member generator. |
| `select(X, List, Rest)` | Selects one occurrence. |
| `not_member(X, List)` | Succeeds when `X` is not a member. |
| `reverse(A, B)` | Reverses a proper list. |
| `length(List, N)` | Proper-list length. |
| `sum_list(List, Sum)` | Numeric sum of a proper list; empty lists produce `0`. |
| `min_list(List, Min)`, `max_list(List, Max)` | Minimum and maximum under standard term ordering. |
| `list_to_set(List, Set)` | Removes duplicates while preserving the first occurrence order. |
| `sort(Input, Output)` | Sorts and deduplicates a proper list. |

### 9.8 Aggregation and ordering

| Built-in | Meaning |
|---|---|
| `findall(Template, Goal, Bag)` | Collects all templates for solutions of `Goal`. |
| `countall(Goal, Count)` | Counts solutions of `Goal`; empty solution sets produce `0`. |
| `sumall(Template, Goal, Sum)` | Sums numeric `Template` values over solutions of `Goal`; empty solution sets produce `0`. |
| `aggregate_min(Key, Template, Goal, Bestkey, Besttemplate)` | Selects the solution of `Goal` with the smallest resolved `Key`, returning that key and the corresponding resolved `Template`. Fails when `Goal` has no solutions. |
| `aggregate_max(Key, Template, Goal, Bestkey, Besttemplate)` | Selects the solution of `Goal` with the largest resolved `Key`, returning that key and the corresponding resolved `Template`. Fails when `Goal` has no solutions. |

### 9.9 Context and term inspection

Context terms are data representations of atomic formulas and comma conjunctions.

| Built-in | Meaning |
|---|---|
| `holds(Context, Term)` | Enumerates member terms inside a context term and unifies each member with `Term`. |
| `holds(Context, Name, Args)` | Enumerates context members of any arity, exposing each member as atom constant `Name` plus a proper argument list `Args`. |
| `functor(Term, Name, Arity)` | Decomposes a non-variable term into its name and arity. |
| `arg(Index, Term, Arg)` | Extracts the 1-based argument of a compound term. |
| `compound_name_arguments(Term, Name, Args)` | Decomposes a compound term, treats an atom as a zero-argument term, or constructs a term from an atom name and proper argument list. Empty `Args` constructs an atom. |

Example:

```via
holds((name(alice, "Alice"), knows(alice, bob)), name(S, O)).
holds((ready, name(alice, "Alice"), route(alice, bob, 7)), Name, Args).
functor(route(alice, bob, 7), route, 3).
arg(2, route(alice, bob, 7), bob).
compound_name_arguments(Term, route, [alice, bob, 7]).
compound_name_arguments(nil, nil, []).
```

The first goal can yield `holds((name(alice, "Alice"), knows(alice, bob)), name(alice, "Alice")).` The second can yield `holds((ready, name(alice, "Alice"), route(alice, bob, 7)), ready, []).`, `holds((ready, name(alice, "Alice"), route(alice, bob, 7)), name, [alice, "Alice"]).`, and `holds((ready, name(alice, "Alice"), route(alice, bob, 7)), route, [alice, bob, 7]).`

`holds/3` is the appropriate form for schema-style introspection because it exposes the predicate name and all arguments without assuming a fixed arity. For example, a single rule can inspect `heartbeat`, `source(sensor17)`, `temperature(sensor17, 38)`, and `signature(sensor17, sha256, Hash, Time)` as `heartbeat/0`, `source/1`, `temperature/2`, and `signature/4`; see [`context-schema-audit.pl`](../examples/context-schema-audit.pl).

### 9.10 Search control

| Built-in | Meaning |
|---|---|
| `not(Goal)` | Negation as failure. Succeeds when `Goal` has no solution. Portable user-defined negation should be stratified. |
| `once(Goal)` | Succeeds with at most the first solution of `Goal`. |
| `forall(Generator, Test)` | Succeeds when every solution of `Generator` also satisfies `Test`; succeeds vacuously when `Generator` has no solutions. |

## 10. Implementation-specific built-ins

Implementations MAY provide additional built-ins beyond the standard predicates listed above. Such built-ins are **implementation-specific built-ins**. They are useful for embedding via in particular host environments, exposing efficient finite-domain solvers, or providing domain-specific relations for applications.

Implementation-specific built-ins are not required for conformance to this specification. A portable via program SHOULD NOT depend on one unless the target implementation explicitly documents it.

An implementation-specific built-in SHOULD obey the same surface-language discipline as standard built-ins:

- it is called using ordinary atomic-formula syntax, for example `some_extension(A, B)`;
- its arguments and results are via terms from the Herbrand universe;
- it succeeds, fails, and binds variables as a relation over via terms;
- it SHOULD document its intended modes, especially which arguments must be ground before it runs deterministically;
- it MUST NOT change the meaning of ordinary facts, rules, unification, or standard built-ins.

For example, an implementation may include host-specific integrations or domain accelerators. Those modules may be valuable and may make applications much faster, but their predicate names, arities, algorithms, and modes are implementation-defined unless they are separately standardized.

An implementation that provides explanation output SHOULD make implementation-specific built-ins explainable at least as opaque successful or failed built-in calls, so that proof traces do not incorrectly report "no clauses" for a host-provided relation.

## 11. Declarations

Declarations are written as ordinary facts, but the host treats them specially.

### 11.1 Automatic hybrid reasoning

via automatically combines ordinary goal-directed resolution with tabled
resolution. Predicate dependency cycles are detected when a program is loaded,
including dependencies inside conjunctions, negation, `once/1`, `forall/2`, and
aggregation goals. Positive recursive predicate groups, including directly
materialized relations, are tabled automatically. Cyclic calls are evaluated to
an answer fixed point, so a table is complete before its answers are replayed.
Recursive components containing a negative dependency retain guarded ordinary
resolution because positive least-fixed-point tabling does not define
unstratified negation. Other groups use ordinary depth-first resolution and
indexed fact lookup. Authors do not select an execution strategy in source code.

For a tabled call with a ground input argument, answers may be cached and reused
within a solver run. The engine infers common structurally decreasing input
positions from recursive clause heads. Calls whose inferred structural input is
not ground, and fully open calls, continue with ordinary resolution so that an
infinite relation is not forced into a table. This is a search-control strategy
and does not change the logical meaning of a program.

### 11.2 Default-output materialization

```via
materialize(answer, 2).
```

The first argument MUST be an atom constant and the second argument MUST be a non-negative integer. If a program contains one or more `materialize/2` declarations, default CLI output is restricted to those predicate groups. Source facts are still excluded from printed output.

Example:

```via
materialize(status, 2).
materialize(reason, 2).
```

`materialize/2` affects host output selection only; it does not change the logical meaning of the program. Materialized output facts are not asserted as new source facts for subsequent output goals. A host MAY solve several materialized predicates in one solver run, and automatically tabled predicate answers MAY be reused within that run.

### 11.3 Advisory modes and determinism

```via
mode(path, 2, [in, out]).
det(root, 1).
semidet(edge, 2).
```

`mode/3`, `det/2`, and `semidet/2` are advisory declarations. They describe a predicate group's intended calling pattern and determinism, but they do not change proof search or answer output. Because they are ordinary facts, programs may also query them.

For `mode(Name, Arity, Modes)`, the first argument MUST be an atom constant naming the predicate, the second argument MUST be a non-negative integer arity, and the third argument MUST be a proper list whose length is equal to the arity. Portable mode atoms are:

- `in`: the argument is expected to be supplied by the caller;
- `out`: the argument is expected to be produced by the predicate;
- `any`: no portable mode commitment is made for that argument.

`det(Name, Arity)` declares that a predicate is intended to produce exactly one answer for calls in its documented modes. `semidet(Name, Arity)` declares that a predicate is intended to produce zero or one answer. This specification does not require runtime enforcement; hosts MAY use these declarations for linting, documentation, indexing decisions, or editor support.

Example:

```via
mode(member, 2, [out, in]).
semidet(member, 2).
```

The example documents the common checking/generation mode where the list is supplied and the member is enumerated. A future linting host could warn if a program calls `member/2` outside that intended mode, but a conforming solver still treats `mode/3` and `semidet/2` as ordinary facts plus metadata.

## 12. Via Sockets

A **via Socket** is a declared semantic opening in a via program where facts, rules, tools, datasets, or agents can plug in knowledge through an explicit contract while preserving via-readable reasoning and explanations.

The term follows the ordinary socket pattern: a socket defines a place where a matching provider can connect. In via, the matching part is knowledge. A socket identifies what shape of knowledge a program expects; a plug identifies which provider supplies it. This separates reasoning logic from knowledge providers and makes composition boundaries visible as via data.

In this specification, sockets are a portable **programming pattern** expressed with ordinary facts. The core solver does not give `socket/2`, `plug/2`, `provides/1`, or `requires/1` special proof-search behavior unless a host explicitly documents such an extension. Because they are ordinary facts, socket declarations remain readable, inspectable, explainable, and safe to ignore by hosts that do not validate them.

### 12.1 Socket vocabulary

The minimal socket vocabulary is:

```via
socket(Name, Contract).
plug(Provider, Name).
provides(Signature).
requires(Signature).
```

`Name` and `Provider` are ordinary via terms, usually atom constants. `Contract` is an ordinary via term that describes the expected or offered knowledge. A portable signature form is:

```via
predicate(Predicatename, Arity)
```

For example:

```via
socket(family_source, provides(predicate(parent, 2))).
plug(family_file, family_source).
```

This says that `family_source` is a named opening for knowledge of the shape `parent/2`, and that `family_file` is the provider plugged into that opening.

### 12.2 Socket example

A rule module can declare the knowledge it expects:

```via
materialize(ancestor, 2).

socket(family_source, provides(predicate(parent, 2))).
plug(family_file, family_source).

parent(pat, jan).
parent(jan, emma).

ancestor(X, Y) :-
    parent(X, Y).

ancestor(X, Z) :-
    parent(X, Y),
    ancestor(Y, Z).
```

The `ancestor/2` rules do not depend on a particular storage mechanism for `parent/2`. In a small test, the provider may be the same file. In an embedded host, it may be a database adapter, a document extractor, a remote service, or another via module. The socket facts make that boundary explicit without changing the logical meaning of the rules.

When via derives `ancestor(pat, emma)`, the answer explanation can still refer to the source clauses that were actually used, for example facts for `parent/2` and rules for `ancestor/2`. The socket facts add an inspectable description of where such knowledge is intended to enter.

### 12.3 Sockets and AI agents

via Sockets are especially useful for AI-facing systems. An AI agent can extract or propose candidate claims, but those claims should enter a reasoning program as explicit via facts or rules through a declared socket rather than as opaque text. via can then check the claims against other facts and rules, derive consequences, and optionally return ordinary `why/2` explanations.

This gives a clear division of labor: AI can help generate, translate, and connect knowledge; via can represent, check, and explain the reasoning; sockets define the boundary between them.

## 13. Output and read-back profile

Normal answer output prints one resolved answer term followed by a period. Strings are double-quoted; atom constants are quoted when needed; lists use list syntax; compound terms use functor notation. Host interfaces MAY provide an option such as `--proof` to add `why/2` explanation facts; this option MUST NOT change the answers found. Host interfaces MAY also provide a non-fatal warning option such as `--warnings` for portability diagnostics such as unstratified negation; this option MUST NOT change the answers found.

Output SHOULD be accepted as via input when it contains only supported term syntax. Explanations are ordinary via facts, so answer output can be read back and processed by via.

Default host output behavior is:

1. parse all inputs into one program;
2. collect source fact lines for duplicate suppression;
3. if `materialize/2` declarations exist, solve those predicate groups; otherwise solve all binary predicate groups with at least one rule;
4. keep only ground answers;
5. remove answers identical to source facts;
6. suppress duplicates;
7. print each answer, followed by its `why/2` explanation only if the host interface was explicitly asked to emit proof output.

### 13.1 Explanation output

When proof output is enabled, each answer SHOULD be followed by a machine-readable `why/2` fact. Explanation output is ordinary via syntax whose second argument is a nested abstract proof term such as `proof(goal(G), by(Method), bindings(Bindings), uses(Proofs))`; implementations SHOULD print `goal(...)` and `by(...)` on separate lines for readability. A proof term preserves the answer goal, derivation method, relevant bindings, and nested uses while omitting proof IDs. User clauses SHOULD be referenced explicitly as `fact(Filename, clause(N))` or `rule(Filename, clause(N))`, where `N` is the 1-based clause number within that source. Built-ins SHOULD be referenced as `builtin(Name, Arity)` because they do not come from source clauses. Explanation output is outside the logical semantics of the input program and MUST NOT change the set of answers.

## 14. Conformance

A conforming via implementation supports the standard language described above as one conformance surface rather than as separate core and extension profiles. This includes:

- lexical syntax described above;
- facts and definite clauses;
- first-order unification without occurs check;
- left-to-right goal-directed proof search;
- lists and comma conjunctions;
- answer printing and read-back formatting;
- the standard built-ins listed in section 9;
- automatic hybrid goal-directed and tabled execution;
- `materialize/2` declarations;
- advisory `mode/3`, `det/2`, and `semidet/2` declarations;
- default derived output;
- explanation output when the host exposes proof output.

Browser execution, package layout, CLI URL loading, and any implementation-specific built-ins described in host documentation are outside this conformance surface unless separately standardized.

Conformance cases live in the repository under `test/conformance/`. They are run by `npm test` before the example suite, and can be run alone with `node test/run-conformance.mjs`. Positive cases have input programs under `conformance/cases/` and exact expected standard-output files under `conformance/expected/`; both use `.pl` so expected output remains via-readable. Expected-error cases live under `conformance/errors/` with exact messages under `conformance/expected-errors/`. Expected-warning cases live under `conformance/warnings/` with exact `--warnings` stdout and stderr files under `conformance/expected-warnings/`. The corpus is grouped by language area, including arithmetic, strings, lists, terms, atoms, variables, negation, declarations, materialization, rules, syntax, and errors.

## 15. Relationship to ISO Prolog

via source is intended to be familiar to Prolog readers and uses ISO Prolog-compatible variable and quoted-atom spelling, but via is not ISO Prolog. Notable differences include:
- no operators or operator declarations;
- no zero-arity compound syntax such as `nil()`;
- no cut;
- no modules;
- no dynamic database update;
- no DCGs;
- no full ISO term ordering or standard library;
- no variables in functor or predicate position;
- no occurs check in unification.

Programs intended to be portable to via SHOULD use uppercase or underscore variables, avoid ISO-specific features that via does not implement, and keep terms explicit. Atom names that are not plain lowercase-starting names or graphic atom tokens SHOULD be written as quoted atoms, for example `'a-b'` or `'<abc>'`.

## 16. Examples

### 16.1 Transitive closure

```via
parent(pat, jan).
parent(jan, emma).

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Z) :- parent(X, Y), ancestor(Y, Z).
```

### 16.2 Arithmetic

```via
square(X, Y) :- mul(X, X, Y).
answer(three, Y) :- square(3, Y).
```

### 16.3 Lists

```via
first([X | _rest], X).
answer(example, X) :- first([a, b, c], X).
```

### 16.4 Negation as failure

```via
closed(b).
open(X) :- not(closed(X)).
status(a, open) :- open(a).
```

## 17. Security and portability considerations

URL input uses host networking support when available. Hosts SHOULD treat downloaded programs as untrusted code because they can trigger expensive search.

Programs SHOULD be written with finite search in mind. Broad default materialization can be expensive for helper predicates; use `materialize/2` declarations and concise output predicates when needed.
