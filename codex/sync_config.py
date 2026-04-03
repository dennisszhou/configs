#!/usr/bin/env python3
"""Reconcile repo-managed Codex config with ~/.codex/config.toml."""

from __future__ import annotations

import argparse
import copy
import datetime as dt
import json
import os
import re
import sys
import tempfile
import tomllib
from pathlib import Path
from typing import Any


BARE_KEY_RE = re.compile(r"^[A-Za-z0-9_-]+$")

def load_toml(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open("rb") as fh:
        data = tomllib.load(fh)
    if not isinstance(data, dict):
        raise ValueError(f"Expected TOML table at {path}")
    return data


def format_key(key: str) -> str:
    if BARE_KEY_RE.match(key):
        return key
    return json.dumps(key)


def format_string(value: str, key_name: str | None = None) -> str:
    if "\n" in value:
        escaped = value.replace("\\", "\\\\").replace('"""', '\\"\\"\\"')
        return f'"""\n{escaped}"""'
    if key_name == "developer_instructions":
        escaped = value.replace("\\", "\\\\").replace('"""', '\\"\\"\\"')
        return f'"""{escaped}"""'
    return json.dumps(value)


def format_value(value: Any, key_name: str | None = None) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, str):
        return format_string(value, key_name)
    if isinstance(value, int) and not isinstance(value, bool):
        return str(value)
    if isinstance(value, float):
        if value == float("inf"):
            return "inf"
        if value == float("-inf"):
            return "-inf"
        if value != value:
            return "nan"
        return repr(value)
    if isinstance(value, dt.datetime):
        return value.isoformat().replace("+00:00", "Z")
    if isinstance(value, (dt.date, dt.time)):
        return value.isoformat()
    if isinstance(value, list):
        return "[" + ", ".join(format_value(item) for item in value) + "]"
    raise TypeError(f"Unsupported TOML value: {value!r}")


def is_array_of_tables(value: Any) -> bool:
    return isinstance(value, list) and all(isinstance(item, dict) for item in value)


def render_table(path: tuple[str, ...], table: dict[str, Any]) -> list[str]:
    scalar_lines: list[str] = []
    nested_sections: list[str] = []

    for key, value in table.items():
        if isinstance(value, dict):
            nested_sections.extend(render_table(path + (key,), value))
            continue
        if is_array_of_tables(value):
            nested_sections.extend(render_array_table(path + (key,), value))
            continue
        scalar_lines.append(f"{format_key(key)} = {format_value(value, key)}")

    sections: list[str] = []
    if path:
        header = "[" + ".".join(format_key(part) for part in path) + "]"
        body = "\n".join([header, *scalar_lines]) if scalar_lines else header
        sections.append(body)
    elif scalar_lines:
        sections.append("\n".join(scalar_lines))

    sections.extend(nested_sections)
    return sections


def render_array_table(path: tuple[str, ...], values: list[dict[str, Any]]) -> list[str]:
    sections: list[str] = []
    header = "[[" + ".".join(format_key(part) for part in path) + "]]"
    for value in values:
        scalar_lines: list[str] = []
        nested_sections: list[str] = []
        for key, item in value.items():
            if isinstance(item, dict):
                nested_sections.extend(render_table(path + (key,), item))
                continue
            if is_array_of_tables(item):
                nested_sections.extend(render_array_table(path + (key,), item))
                continue
            scalar_lines.append(f"{format_key(key)} = {format_value(item, key)}")
        body = "\n".join([header, *scalar_lines]) if scalar_lines else header
        sections.append(body)
        sections.extend(nested_sections)
    return sections


def dump_toml(data: dict[str, Any]) -> str:
    sections = render_table((), data)
    return "\n\n".join(sections) + ("\n" if sections else "")


def collect_conflicts(
    managed: Any, existing: Any, path: tuple[str, ...] = ()
) -> list[tuple[tuple[str, ...], Any, Any]]:
    if existing is None:
        return []

    if isinstance(managed, dict):
        if not isinstance(existing, dict):
            return [(path, existing, managed)]
        conflicts: list[tuple[tuple[str, ...], Any, Any]] = []
        for key, managed_value in managed.items():
            if key in existing:
                conflicts.extend(
                    collect_conflicts(managed_value, existing[key], path + (key,))
                )
        return conflicts

    if managed != existing:
        return [(path, existing, managed)]

    return []


def merge_managed(existing: Any, managed: Any) -> Any:
    if isinstance(managed, dict):
        if existing is None:
            return copy.deepcopy(managed)
        merged = copy.deepcopy(existing)
        for key, managed_value in managed.items():
            if key in merged:
                merged[key] = merge_managed(merged[key], managed_value)
            else:
                merged[key] = copy.deepcopy(managed_value)
        return merged
    return copy.deepcopy(managed if existing is None else existing)


def write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=path.parent, delete=False
    ) as tmp:
        tmp.write(content)
        temp_name = tmp.name
    os.replace(temp_name, path)


def main() -> int:
    args = parse_args_with_defaults()
    repo_config = load_toml(args.repo_config)
    target_config = load_toml(args.target_config)

    conflicts = collect_conflicts(repo_config, target_config)
    if conflicts:
        for path, existing_value, managed_value in conflicts:
            dotted = ".".join(path) or "<root>"
            print(
                f"Conflict for {dotted}: existing={existing_value!r}, managed={managed_value!r}",
                file=sys.stderr,
            )
        return 1

    merged = merge_managed(target_config, repo_config)
    write_atomic(args.target_config, dump_toml(merged))
    print(f"Synced managed Codex config into {args.target_config}")
    return 0


def parse_args_with_defaults() -> argparse.Namespace:
    script_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description="Merge repo-managed Codex settings into a target config.toml."
    )
    parser.add_argument(
        "--repo-config",
        type=Path,
        default=script_dir / "config.toml",
        help="Path to the repo-managed Codex config fragment.",
    )
    parser.add_argument(
        "--target-config",
        type=Path,
        default=Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")) / "config.toml",
        help="Path to the target ~/.codex/config.toml file.",
    )
    return parser.parse_args()


if __name__ == "__main__":
    raise SystemExit(main())
