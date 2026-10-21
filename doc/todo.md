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
- The full `cd test && make` suite has been run against a JDK: all 107
  `test/*.java` programs compile, translate, and run, with the Python output
  diffing clean against the Java output.  `make selectors` passes (11 tests).
- CLI fixes: a directory walk now writes under the output directory instead
  of beside the input (`path.join` discards it for absolute names), each file
  of a walk gets its own config list instead of accumulating the previous
  files' configs, and unreadable or unparseable input reports an error and an
  exit code instead of a traceback (`JavaSyntaxError` from `buildAST`).
- A Claude Code plugin lives in `plugin/`; see CLAUDE.md.
- Labeled `break` and `continue` are translated.  A jump a bare keyword can
  express still emits one; the rest raise a generated per-label exception
  that the labeled statement catches (`java2python/compiler/visitor.py`,
  `basic.maybeLabelClasses`).  Covered by `test/Break2-4.java`,
  `test/Continue3-5.java` and `test/ForEach1.java`.

### To Do

1. **Java `%` semantics.**  Java `%` truncates toward zero, while Python `%`
   floors, so the results differ when an operand is negative.  Consider a
   `jmod()` helper alongside `jdiv()`
   (`java2python/compiler/visitor.py`, `java2python/mod/include/`).
2. **Division readability.**  Every `/` becomes `jdiv(a, b)`, even for floats,
   because types aren't tracked.  Possible improvements: emit plain `/` when an
   operand is a float literal or a float/double cast, or track declared local
   variable types.
3. **Parser regeneration.**  The `java2python/lang/Makefile` flow (ANTLR 3.1.3
   tool, then rewriting the imports to the vendored runtime) is untested.
   Regenerating would also bring back the `__main__` blocks that import
   `antlr3.main`, which isn't vendored.
4. **`test/configs/defaults.py`.**  It defines `outputSubs`, but the code
   reads `moduleOutputSubs`, so those substitutions probably never apply.
   Rename it and check that the tests still pass.
5. **Generated-code style.**  Possible cleanups: emit f-strings instead of
   `.format()` for `String.format` and drop redundant `int()`/`str()` casts on
   literals (flagged by `ruff --select UP` on the test output).
   `@classmethod` for static methods could become `@staticmethod` when `cls`
   isn't used.
6. **Optional dependency on zope.interface.**  It is only needed by
   `test/configs/defaults.py` and the `zope*` handlers in `mod/basic.py`.
   Consider dropping those handlers.
7. **Tooling.**  Add ruff configuration and CI (GitHub Actions with
   `astral-sh/setup-uv`, a JDK, and `make -C test`).  Possibly port the
   Makefile harness to pytest.
8. **Docs.**  `doc/usage.md`, `doc/translation.md`, and
   `doc/customization.md` still show Python 2-era output in places, and the
   links still point at the upstream `natural/java2python` repository.
