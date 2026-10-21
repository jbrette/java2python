---
description: Translate a Java file, directory or snippet to Python with j2py, then fix what the translator cannot infer without types.
argument-hint: <Foo.java | src/ > [output]
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh:*)", "Read", "Write", "Edit", "Glob", "Grep"]
---

Translate `$ARGUMENTS` from Java to Python.

Follow the `java2python` skill. In short:

1. Run the translator rather than hand-writing the Python:
   `${CLAUDE_PLUGIN_ROOT}/scripts/j2py.sh $ARGUMENTS`
2. Read the result against the skill's "What you have to fix" list -- string
   concatenation, the Java standard library, `%` on negatives, fields that
   became class attributes, lost overloads -- and repair each one.
3. Run the Python. If a JDK is on PATH, run the Java too and diff the output.
4. Report what you changed after the translation and anything left uncertain.

If no argument was given, ask which file or directory to translate.
