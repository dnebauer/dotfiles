#!/usr/bin/env python3
"""
Add page break at the start of each H1 section

    --- page break ---

    # Section

"""

from __future__ import print_function
import sys
import os
# pylint: disable=wrong-import-position,import-error, unused-import
from pandocfilters import RawInline, Para, Header, toJSONFilter  # NOQA


# method signature for rehead determined by pandocfilters
# - format is redefined, meta is unused
# pylint: disable=redefined-builtin,unused-argument
def rehead(key, value, format, meta):
    """ Insert newpage before each Header 1
    """
    if key == 'Header' and value[0] == 1:
        if format == 'latex':
            text = '\\newpage\n\\thispagestyle{empty}\n\\setcounter{page}{1}'
            return [Para([RawInline('latex', text)]),
                    Header(value[0], value[1], value[2])]
        elif format == 'html':
            text = '<hr>'
            return [Para([RawInline('html', text)]),
                    Header(value[0], value[1], value[2])]


if __name__ == "__main__":
    toJSONFilter(rehead)
