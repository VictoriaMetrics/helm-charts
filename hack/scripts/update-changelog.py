#!/usr/bin/env python3
"""Add a dependency update entry to the chart's CHANGELOG.md"""

import re
import sys

NEXT_RELEASE_HEADER = "## Next release"
TODO_LINE = re.compile(r"^- TODO\s*$", re.MULTILINE)


def main(
    changelog_path: str, dep_name: str, old_version: str, new_version: str
) -> None:
    with open(changelog_path, "r") as f:
        content = f.read()

    # Find the position of the "## Next release" header
    header_pos = content.find(NEXT_RELEASE_HEADER)
    if header_pos == -1:
        print(f"No 'Next release' header found in {changelog_path}", file=sys.stderr)
        sys.exit(1)

    # Find the end of the "## Next release" section
    after_header = header_pos + len(NEXT_RELEASE_HEADER)
    next_section = re.search(r"^##\s", content[after_header:], re.MULTILINE)
    section_end = len(content)
    if next_section:
        section_end = after_header + next_section.start()

    section = content[after_header:section_end]

    # Remove "- TODO" line
    section = TODO_LINE.sub("", section)
    new_changelog_entry = f"- {dep_name} {old_version} -> {new_version}"

    # Collect existing non-empty lines, then rebuild with a blank line after heading
    existing_lines = section.splitlines()
    existing_lines.append(new_changelog_entry)
    section = "\n\n" + "\n".join(existing_lines) + "\n\n"

    content = content[:after_header] + section + content[section_end:]

    with open(changelog_path, "w") as f:
        f.write(content)

    print(f"Updated {changelog_path}: {new_changelog_entry}")


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print(
            f"Usage: {sys.argv[0]} <path/to/CHANGELOG.md> <dep_name> <old_version> <new_version>",
            file=sys.stderr,
        )
        sys.exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
