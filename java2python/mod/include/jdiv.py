def jdiv(a, b):
    """ jdiv(a, b) -> a divided by b, with Java semantics

    This function is here because the original java source divides
    with '/' and/or '/=', which truncates toward zero when both operands
    are integers.  Python's '/' always returns a float, so the python
    source code below calls this function instead.
    """
    if isinstance(a, int) and isinstance(b, int):
        q = abs(a) // abs(b)
        return q if (a < 0) == (b < 0) else -q
    return a / b
