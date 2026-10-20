#!/usr/bin/env python
# java2python.config -> subpackage for run-time configuration.

import sys
from functools import reduce
from importlib.util import module_from_spec, spec_from_file_location
from os import path


def load_source(modname, filename):
    """ Loads a module from a source file, like the removed imp.load_source. """
    spec = spec_from_file_location(modname, filename)
    mod = module_from_spec(spec)
    sys.modules[modname] = mod
    spec.loader.exec_module(mod)
    return mod


class Config:
    """ Config -> wraps multiple configuration modules. """

    def __init__(self, names):
        self.configs = [self.load(name) for name in names]

    def every(self, key, default=None):
        """ Returns the value at the given key from each config module. """
        return [getattr(config, key, default) for config in self.configs]

    def last(self, key, default=None):
        """ Returns the value at the key from the last config defining it. """
        for config in reversed(self.configs):
            if hasattr(config, key):
                return getattr(config, key)
        return default

    @staticmethod
    def load(name):
        """ Imports and returns a module from dotted form or filename. """
        if path.exists(name) and path.isfile(name):
            mod = load_source(str(hash(name)), name)
        else:
            mod = reduce(getattr, name.split('.')[1:], __import__(name))
        return mod
