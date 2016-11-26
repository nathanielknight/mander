#!/usr/bin/env python
'''
'''

import sys

def cell(i, j, c):
    template = "(({}, {}), {})"
    if c == 'r':
        content = 'Red'
    elif c == 'b':
        content = 'Blue'
    else:
        return False
    return template.format(i, j, content)


def cells(rows):
    for i, col in enumerate(rows):
        for j, c in enumerate(col):
            parsed = cell(i, j, c)
            if parsed:
                yield parsed


def demograph(source):
    rows = source.lower().splitlines()
    template = "[ {} ]"
    content = ", ".join(cells(rows))
    return template.format(content)


if __name__ == "__main__":
    rows = sys.stdin.read()
    output = demograph(rows)
    sys.stdout.write(output)
