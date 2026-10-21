---
name: java2python
description: >-
  Translate Java source to Python using the java2python (j2py) compiler, then
  repair what a grammar-driven translator cannot get right on its own. Use when
  asked to translate or port Java to Python, convert a .java file to .py, run
  j2py, or migrate a Java class, package or project to Python. The parser does
  the mechanical work -- classes, control flow, labeled jumps, interfaces,
  operators, comments -- and the remaining fixes need type knowledge the parser
  does not have: string concatenation, the Java standard library, integer
  remainder, and instance fields.
version: 0.1.0
---

# Java to Python with j2py

j2py parses real Java with an ANTLR grammar, so it never guesses at
structure. It also tracks no types at all, so everything that depends on
knowing whether a value is an `int`, a `String` or an `ArrayList` comes out
wrong. Translating well means running the parser first and then fixing the
type-dependent parts by hand.

Do not hand-translate a file that j2py can parse. Its output is a correct
skeleton, and starting from it is faster and less error-prone than rewriting
the structure yourself.

## Running it

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh Foo.java              # to stdout
${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh Foo.java Foo.py       # to a file
${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh src/ out/             # whole tree
cat Foo.java | ${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh -      # from stdin
```

Useful flags: `-s -j` dumps the Java AST instead of source (`-p` the Python
block tree, `-t` the lexer tokens) when output looks wrong and you need to see
what the parser saw; `-c MODULE` and `-d DIR` add configuration modules;
`-l info` reports timings. A non-zero exit means the file did not parse or
could not be read -- the message says which, and the parser prints the
offending line and column before it.

The script finds the translator itself: `$J2PY_HOME`, else the checkout it
ships in, else a `j2py` on PATH.

## What it gets right

Classes, interfaces (as `ABC` with `@abstractmethod`), enums, constructors,
fields, static methods (as `@classmethod`), all the loops, `switch` (as an
if/elif chain), `try`/`catch`/`finally`, `synchronized`, labeled `break` and
`continue`, the ternary, casts, `>>>`, Java's truncating integer division (as
an inlined `jdiv()` helper), comments and Javadoc.

## What you have to fix

Check each of these in the output. They are not bugs to report; they are the
known cost of translating without a type checker.

**String concatenation.** `"i is " + i` is valid Java and a `TypeError` in
Python. Every `+` that mixes a string with anything else needs an f-string.

**The Java standard library.** Imports are dropped and the class names survive
as-is, so `new ArrayList<String>()` becomes `ArrayList()` and raises
`NameError`. Map the types and their methods onto Python equivalents: `List`
to `list`, `Map` to `dict`, `StringBuilder` to a list of parts or an f-string,
`.add()` to `.append()`, `.put(k, v)` to `d[k] = v`, `.size()` -- which does
become `len(...)` -- and so on.

**Integer remainder.** Java's `%` truncates toward zero and Python's floors,
so they disagree whenever an operand is negative: `-7 % 3` is `-1` in Java and
`2` in Python. j2py emits a bare `%`. Fix it where a negative operand is
reachable. (`/` is already handled, by `jdiv()`.)

**Instance fields.** A field initialized at its declaration becomes a class
attribute, which every instance then shares. Move mutable ones into
`__init__`.

**Overloads.** Python keeps only the last method of a given name. Merge them
into one with default or variadic arguments.

**Generics** are erased, and inner, anonymous and nested classes, threads and
annotations are best-effort. Read them closely.

## Verify, do not assume

Translate, then actually run the Python. If a JDK is available, run the Java
too and diff the output -- that is what the project's own test suite does:

```bash
javac Foo.java && java Foo > java.txt
python3 Foo.py > py.txt
diff -u java.txt py.txt
```

Without a JDK, at minimum `python3 -c "import ast; ast.parse(open('Foo.py').read())"`
and then read the output against the Java with the list above in hand.

For a tree of files, translate the whole tree in one run, then work through
the failures one file at a time rather than eyeballing all of them.
