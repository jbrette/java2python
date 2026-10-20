.PHONY: all clean
.SILENT: clean

all: JavaParser.py JavaLexer.py


# The generated modules import the runtime vendored in ./antlr3, so the
# stock "from antlr3" imports are rewritten after generation.
JavaParser.py JavaLexer.py: Java.g
	antlr3 Java.g
	sed -i.bak -e 's/^from antlr3/from java2python.lang.antlr3/' \
		-e '/^from java2python.lang.antlr3.compat import/d' JavaParser.py JavaLexer.py
	rm -f JavaParser.py.bak JavaLexer.py.bak


clean:
	rm -f *.pyo
	rm -f *.pyc
	rm -f *Parser.py
	rm -f *Lexer.py
	rm -f *.tokens




