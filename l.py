#!/usr/bin/env python3

import os
import sys

os.execvp("ls", ["ls"] + sys.argv[1:])