#!/usr/bin/env python
'''
'''

import sys


def cells(rows):

    def cell(i, j, c):
        template = "(({}, {}), {})"
        if c == 'r':
            content = 'Red'
        elif c == 'b':
            content = 'Blue'
        else:
            return False
        return template.format(i, j, content)

    for j, col in enumerate(rows):
        for i, c in enumerate(col):
            parsed = cell(i, j, c)
            if parsed:
                yield parsed


def districts(source):
    '''A list of districts from a text map

    Takes a text map with district HQs reqpresented as capital Rs and
    Bs, . Ensures that there are an odd number of districts.
    '''
    rows = source.splitlines()

    def district(id_no, hq_coord):
        (i, j) = hq_coord
        format = "{{ id = {} , hq = ({}, {}) , assigned = Set.emtpy }}"
        return format.format(id_no, i, j)

    def hq_coords():
        for j, col in enumerate(rows):
            for i, c in enumerate(col):
                if c.isupper():
                    yield (i,j)

    districts = [district(id_no, coord) for id_no, coord
                 in enumerate(sorted(hq_coords()))]
    district_count = len(districts)
    assert_msg = "An odd number of districts is required ({} given)"
    assert district_count % 2 != 0, assert_msg.format(district_count)
    return districts


def demograph(source):
    rows = source.lower().splitlines()
    demo_cells = list(cells(rows))

    assert_msg = "An add number of cells is required ({} given)"
    cell_count = len(demo_cells)
    assert cell_count % 2 != 0, assert_msg.format(cell_count)

    template = "[ {} ]"
    content = ", ".join(cells(rows))
    return template.format(content)


if __name__ == "__main__":
    rows = sys.stdin.read()
    output = demograph(rows)
    sys.stdout.write(output)
