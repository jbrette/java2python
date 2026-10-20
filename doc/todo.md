## Remaining Work

Status of the Python 3.14 / uv modernization and what is still open.

### Done

- The translator runs on Python 3.14+, packaged with uv (`pyproject.toml`,
  `uv_build`). `setup.py` is gone.
- ANTLR 3.1.3 Python runtime vendored and ported to Python 3 in
  `java2python/lang/antlr3/`.
- Generated code targets Python 3.14+: `python3` shebang, no `__future__`
  imports, `class X:`, `super()`, `ABC` interfaces, `int` for `long`, `0o` octal
  literals, Java integer division via an inlined `jdiv()` helper.
- All 100 `test/*.java` programs translate, compile, and run without errors on
  Python 3.14.8.  The selector unit tests pass.
- The full `cd test && make` suite has been run against a JDK (Temurin 25):
  100/100 `[PASS]`, with the Python output diffing clean against the Java
  output.  `make selectors` passes (11 tests).

### To Do

1. **Labeled `break` and `continue`.**  Python has no labeled loop control, so
   `acceptBreak` and `acceptContinue` drop the label and emit a bare `break` /
   `continue` (`java2python/compiler/visitor.py:375` and `:406`), each warning
   `Detected unhandled break statement with label; generated code incorrect.`
   The statement label itself (`foo:`) is dropped too, so `test/Break0.java`
   translates to a plain `break` inside the `while`.  That test passes only
   because its `break foo;` targets the innermost loop; a label naming an
   *outer* loop from a nested one, or a labeled block, generates silently wrong
   code.  Fixing it needs a real rewrite -- a sentinel flag checked by each
   enclosing loop, a label-specific exception raised and caught around the
   labeled statement, or hoisting the labeled loop into a function so the jump
   becomes a `return`.  A test with a nested loop would catch regressions.
2. **Java `%` semantics.**  Java `%` truncates toward zero, while Python `%`
   floors, so the results differ when an operand is negative.  Consider a
   `jmod()` helper alongside `jdiv()`
   (`java2python/compiler/visitor.py`, `java2python/mod/include/`).
3. **Division readability.**  Every `/` becomes `jdiv(a, b)`, even for floats,
   because types aren't tracked.  Possible improvements: emit plain `/` when an
   operand is a float literal or a float/double cast, or track declared local
   variable types.
4. **Parser regeneration.**  The `java2python/lang/Makefile` flow (ANTLR 3.1.3
   tool, then rewriting the imports to the vendored runtime) is untested.
   Regenerating would also bring back the `__main__` blocks that import
   `antlr3.main`, which isn't vendored.
5. **`test/configs/defaults.py`.**  It defines `outputSubs`, but the code
   reads `moduleOutputSubs`, so those substitutions probably never apply.
   Rename it and check that the tests still pass.
6. **Generated-code style.**  Possible cleanups: emit f-strings instead of
   `.format()` for `String.format` and drop redundant `int()`/`str()` casts on
   literals (flagged by `ruff --select UP` on the test output).
   `@classmethod` for static methods could become `@staticmethod` when `cls`
   isn't used.
7. **Optional dependency on zope.interface.**  It is only needed by
   `test/configs/defaults.py` and the `zope*` handlers in `mod/basic.py`.
   Consider dropping those handlers.
8. **Tooling.**  Add ruff configuration and CI (GitHub Actions with
   `astral-sh/setup-uv`, a JDK, and `make -C test`).  Possibly port the
   Makefile harness to pytest.
9. **Docs.**  `doc/usage.md`, `doc/translation.md`, and
   `doc/customization.md` still show Python 2-era output in places, and the
   links still point at the upstream `natural/java2python` repository.
