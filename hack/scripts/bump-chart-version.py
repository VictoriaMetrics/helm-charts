#!/usr/bin/env python3
"""Bump the patch version of a Helm chart's Chart.yaml."""

import re
import sys


def bump_patch(version: str) -> str:
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", version)
    if not match:
        raise ValueError(f"Cannot parse version: {version!r}")
    major, minor, patch = match.groups()
    return f"{major}.{minor}.{int(patch) + 1}"


def main(chart_yaml_path: str) -> None:
    with open(chart_yaml_path, "r") as f:
        content = f.read()

    def replacer(m: re.Match) -> str:
        return m.group(1) + bump_patch(m.group(2))

    new_content, count = re.subn(
        r"(^version:\s+)(\S+)",
        replacer,
        content,
        flags=re.MULTILINE,
    )
    if count == 0:
        print(f"No 'version:' field found in {chart_yaml_path}", file=sys.stderr)
        sys.exit(1)

    with open(chart_yaml_path, "w") as f:
        f.write(new_content)

    version_match = re.search(r"^version:\s+(\S+)", new_content, re.MULTILINE)
    if not version_match:
        raise ValueError(f"Cannot parse version: {new_content!r}")
    print(f"Bumped chart version to {version_match.group(1)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path/to/Chart.yaml>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
