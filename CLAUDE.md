# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

java2python translates Java source into (best-effort) Python. Both the tool and the code it generates target Python 3.14+. The project is managed with uv (`pyproject.toml`, `uv_build` backend, flat layout); there is no `setup.py`.

There are no runtime dependencies. The ANTLR 3.1.3 Python runtime is vendored as `java2python/lang/antlr3` and was ported to Python 3 by hand (2to3 plus fixes), because no Python 3 release of that runtime version exists. The generated `JavaLexer.py`/`JavaParser.py` only work with that exact runtime version, so don't swap in a newer `antlr3` package.

Open work is tracked in `doc/todo.md`.

## Commands

```bash
uv sync                                    # create .venv (Python 3.14, dev group incl. zope.interface)
uv run j2py SomeFile.java                  # print translation to stdout
uv run j2py SomeFile.java out.py -c myconfig.py
uv run j2py SomeFile.java -s -j            # dump Java AST only (-p python tree, -t lexer tokens)
bin/j2py ...                               # same CLI from a checkout without uv (shim around java2python.cli)
uv build                                   # sdist + wheel
```

Tests (require a JDK: `javac`/`java` on PATH). Each test compiles `test/Foo.java`, translates it with `j2py`, runs both, and diffs stdout:

```bash
cd test && make            # all tests, prints [PASS] Name per test
cd test && make Class02    # single test — no .java suffix
cd test && make clean
cd test && ./runj2py Class01.java   # j2py with the test configs (-d configs)
cd test && make selectors          # unittest suite for lang/selector.py (test/selector/test_all.py)
```

The test Makefile translates with `-c configs.defaults -d configs`: `test/configs/defaults.py` applies to every test, and `test/configs/<TestName>.py` is auto-loaded for a matching `<TestName>.java`. To add a test, create `FeatureNN.java` (next number in sequence) that prints results with `System.out.println`.

Regenerate the parser after editing `java2python/lang/Java.g` (needs the ANTLR 3.1.3 tool as `antlr3`; the Makefile rewrites the generated `from antlr3` imports to the vendored runtime; regenerated files lose any hand edits):

```bash
cd java2python/lang && make
```

## Architecture

Pipeline (`java2python/cli.py` → `java2python/compiler/__init__.py`):

1. `buildAST(source)`: the ANTLR lexer/parser (`lang/JavaLexer.py`, `lang/JavaParser.py`, generated from `lang/Java.g`) with a custom `TreeAdaptor` from `lang/base.py`. `lang/base.py` also exposes `tokens`, the token-type name map used everywhere.
2. `transformAST(tree, config)`: applies `astTransforms` from config, a list of `(selector, function)` pairs. Selectors (`lang/selector.py`) are a CSS-like DSL over AST nodes (`Type('A') > Type('B')` child, `+` adjacent sibling, `/` any sibling). Transform functions live in `mod/transform.py` (identifier renaming, literal fixes, type substitution).
3. `Module(config).walk(tree)`: builds an output tree of blocks, then `str(module)` renders Python source.

Blocks (`compiler/block.py`) are created at import time by combining a template class (`compiler/template.py`, source generation: `iterPrologue/iterHead/iterBody/iterEpilogue`, `dump`) with a visitor class of the same name (`compiler/visitor.py`, AST walking via `accept<TokenType>` methods dispatched by token name). The two halves are tightly coupled, so a feature change usually touches both. Templates create children through a `factory` (e.g. `self.factory.klass(...)`, `self.factory.method(...)`) keyed by the `factoryName` set in `block.py`.

Configuration (`config/__init__.py`): `Config` wraps an ordered list of config modules (default `java2python.config.default`, then `-c` files, then `-d` dir matches). `config.last(key)` takes the last definition, and `config.every(key)` collects all of them. Most generation behavior is delegated to handler lists/functions named by convention (`<block><Part>Handler(s)`, with parts such as `Prologue`, `Base`, `Head`, `Epilogue`) and fetched via `Base.configHandler(s)`. Default handlers are in `mod/basic.py`. `doc/customization.md` documents the config points.

Runtime helpers: when the visitor sees certain constructs it sets a flag on the module (`needsBsrFunc` for `>>>`, `needsJavaDivFunc` for `/` and `/=`, `needsSyncHelpers`, `needsAbstractHelpers`), and a module prologue handler in `mod/basic.py` inlines the source of the matching function from `mod/include/` into the output. Java `/` becomes `jdiv(a, b)`, which truncates toward zero for ints, because types aren't tracked. Interfaces become `ABC` subclasses with `@abstractmethod`.

## Claude Code plugin

`plugin/` is a Claude Code plugin named `j2p` (manifest in
`plugin/.claude-plugin/plugin.json`; the repository root is also a marketplace
via `.claude-plugin/marketplace.json`).  It ships the `java2python` skill and
the `/j2p:translate` command, both of which shell out to
`plugin/scripts/j2py.sh`.  That script resolves the translator from
`$J2PY_HOME`, else this checkout (preferring `uv run`, falling back to
`python3 bin/j2py`), else a `j2py` on `PATH`.  `claude plugin validate .`
checks both manifests.  The skill's value is the list of things j2py cannot
get right without types -- keep it in sync with the real behavior.

## Output post-processing

`moduleOutputHandlers` includes `basic.outputSubs`, which applies the regex pairs in `<typeName>OutputSubs` (e.g. `moduleOutputSubs` in `config/default.py`, which maps `System.out.println` to `print`) to the generated text.
