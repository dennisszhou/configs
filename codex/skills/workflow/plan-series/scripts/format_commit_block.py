#!/usr/bin/env python3
"""Format a plan-series commit block with aligned inline-indent fields.

Input is JSON on stdin with keys like:
{
  "title": "Commit 3/3: igrepd: update config compatibility coverage",
  "fields": [
    ["Type", "semantic"],
    ["Required", "yes"],
    ["Summary", "Long wrapped text..."],
    ["Files", ["a.rs", "b.rs"]],
    ["Verify", "cargo test ..."]
  ]
}

The script emits the exact inline-indent style required by plan-series.
"""

from __future__ import annotations

import json
import sys
import textwrap

INDENT = "  "
MIN_LABEL_WIDTH = 14
TEXT_WIDTH = 80
LABEL_PADDING = 2


def label_width(fields: list[list[object]]) -> int:
    widest = max((len(str(label)) + 1 for label, _ in fields), default=0)
    return max(MIN_LABEL_WIDTH, widest + LABEL_PADDING)


def format_scalar(label: str, value: str, width: int) -> list[str]:
    prefix = f"{INDENT}{label + ':':<{width}}"
    value_column = len(INDENT) + width
    value_width = TEXT_WIDTH - value_column
    wrapped = textwrap.wrap(
        value,
        width=value_width,
        break_long_words=False,
        break_on_hyphens=False,
    ) or [""]
    lines = [prefix + wrapped[0]]
    cont_prefix = " " * value_column
    lines.extend(cont_prefix + line for line in wrapped[1:])
    return lines


def format_list(label: str, values: list[str], width: int) -> list[str]:
    prefix = f"{INDENT}{label + ':':<{width}}"
    cont_prefix = " " * (len(INDENT) + width)
    if not values:
        return [prefix]
    return [prefix + values[0], *(cont_prefix + v for v in values[1:])]


def main() -> int:
    payload = json.load(sys.stdin)
    title = payload["title"]
    fields = payload["fields"]
    width = label_width(fields)

    out: list[str] = [title, ""]
    for label, value in fields:
        if isinstance(value, list):
            out.extend(format_list(label, value, width))
        else:
            out.extend(format_scalar(label, str(value), width))
    sys.stdout.write("\n".join(out) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
