#!/usr/bin/env python3
"""Check relative links and heading anchors in a Markdown file or directory.

Usage:
    check_links.py PATH [PATH ...]

Reports, for every Markdown file reachable under the given paths:
  * a relative link whose target file does not exist;
  * a fragment that names no heading in the target document.

Only relative links are checked. External URLs, mail links, and bare fragments
(``#heading`` within the same file) are checked for the fragment only.

Exit code is 1 when anything is reported, so it can gate a commit.
"""

from __future__ import annotations

import pathlib
import re
import sys

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
HEADING = re.compile(r"^(#{1,6})\s+(.*)$")
FENCE = re.compile(r"^(```|~~~)")


def slug(heading: str) -> str:
    """GitHub-style anchor: lowercase, drop punctuation, spaces to hyphens."""
    text = heading.strip().lower()
    text = re.sub(r"`|\*|_", "", text)
    text = re.sub(r"[^\w\s\-]", "", text, flags=re.UNICODE)
    return re.sub(r"\s+", "-", text.strip())


def anchors(path: pathlib.Path) -> set[str]:
    found: set[str] = set()
    in_fence = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if FENCE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        match = HEADING.match(line)
        if match:
            found.add(slug(match.group(2)))
    return found


def markdown_files(paths: list[str]) -> list[pathlib.Path]:
    files: list[pathlib.Path] = []
    for raw in paths:
        path = pathlib.Path(raw)
        if path.is_dir():
            files.extend(sorted(path.rglob("*.md")))
        elif path.suffix == ".md" and path.exists():
            files.append(path)
        else:
            print(f"  skip (no such Markdown): {raw}")
    return files


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    cache: dict[pathlib.Path, set[str]] = {}
    problems: list[str] = []
    for source in markdown_files(argv[1:]):
        for target, fragment in (
            (m.group(1).split("#", 1)[0], m.group(1).split("#", 1)[1] if "#" in m.group(1) else "")
            for m in LINK.finditer(source.read_text(encoding="utf-8"))
        ):
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            resolved = (source.parent / target).resolve() if target else source.resolve()
            if target and not resolved.exists():
                problems.append(f"MISSING  {source}: {target}")
                continue
            if fragment and resolved.suffix == ".md" and resolved.exists():
                if resolved not in cache:
                    cache[resolved] = anchors(resolved)
                if fragment not in cache[resolved]:
                    problems.append(f"ANCHOR   {source}: {target}#{fragment}")
    if problems:
        print("\n".join(problems))
        print(f"\n{len(problems)} problem(s)")
        return 1
    print(f"ok: {len(cache)} target document(s) checked, no problems")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
