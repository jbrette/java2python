#!/usr/bin/env bash
# Runs the java2python translator, whichever way it happens to be available,
# and forwards every argument to it.  Resolution order:
#
#   1. $J2PY_HOME            -- an explicit java2python checkout
#   2. the checkout this plugin ships inside
#   3. a j2py already on PATH
#
# A checkout is preferred over an installed j2py so that local edits to the
# translator are what actually run.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

findUv() {
    if command -v uv >/dev/null 2>&1; then
        command -v uv
    elif [ -x "$HOME/.local/bin/uv" ]; then
        # uv installs here, and a non-interactive shell may not have it on PATH.
        echo "$HOME/.local/bin/uv"
    fi
}

isCheckout() {
    [ -f "$1/java2python/cli.py" ] && [ -f "$1/pyproject.toml" ]
}

home=${J2PY_HOME:-}
if [ -n "$home" ]; then
    if ! isCheckout "$home"; then
        echo "j2py: J2PY_HOME=$home is not a java2python checkout" >&2
        exit 2
    fi
elif isCheckout "$here/../.."; then
    home=$(cd -- "$here/../.." && pwd)
fi

if [ -n "$home" ]; then
    uv=$(findUv)
    if [ -n "$uv" ]; then
        exec "$uv" run --project "$home" j2py "$@"
    fi
    # No uv:  run from the checkout directly.  This needs the dependencies
    # of any config the caller passes, but the translator itself has none.
    PYTHONPATH="$home${PYTHONPATH:+:$PYTHONPATH}" exec python3 "$home/bin/j2py" "$@"
fi

if command -v j2py >/dev/null 2>&1; then
    exec j2py "$@"
fi

cat >&2 <<'MSG'
j2py: no java2python found.

Install it, or point the plugin at a checkout:

    uv tool install java2python          # or: pip install java2python
    J2PY_HOME=/path/to/java2python       # a git checkout
MSG
exit 127
