# j2p -- the java2python Claude Code plugin

Translate Java to Python from inside Claude Code, using the
[java2python](https://github.com/jbrette/java2python) compiler for the
structure and the model for the parts that need type knowledge.

## What is in it

| Component | Name | Purpose |
| --- | --- | --- |
| Skill | `java2python` | Loads when a task involves translating Java to Python. Explains how to run j2py and, more importantly, what to check in its output. |
| Command | `/j2p:translate <file>` | Translate a named file, directory or snippet now. |
| Script | `scripts/j2py.sh` | Runs the translator, finding it wherever it lives. |

## Install

```
/plugin install j2p --marketplace jbrette/java2python
```

From a checkout of this repository, where the repository root is itself the
marketplace:

```bash
claude plugin marketplace add .
claude plugin install j2p@java2python
```

`claude plugin validate ./plugin` checks the manifest without installing
anything.

## Finding the translator

`scripts/j2py.sh` resolves j2py in this order:

1. `$J2PY_HOME`, if set, which must be a java2python checkout.
2. The checkout the plugin ships inside (`plugin/` lives at its root).
3. A `j2py` already on `PATH`.

A checkout wins over an installed `j2py` so that local edits to the translator
are what actually run. With a checkout it prefers `uv run`, falling back to
`python3 bin/j2py` when uv is not installed.

## Why the model is still in the loop

j2py parses Java with an ANTLR grammar, so it gets the structure right and
never hallucinates it. It tracks no types, so `"n is " + i` -- fine in Java --
comes out as a Python `TypeError`, `new ArrayList<>()` comes out as an
undefined name, and `%` keeps Python's sign rules instead of Java's. The skill
lists these, and the fix is a reading pass over the generated file, not a
rewrite of it.
