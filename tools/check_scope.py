#!/usr/bin/env python3
"""Scope gate: fail when a change touches a file outside the unit.

    python3 tools/check_scope.py [--base REF] PATTERN...

PATTERN is a path or a glob (fnmatch; `*` also crosses `/`), relative to the repo root, naming the unit's files. The
change checked is everything between REF and the working tree: commits after REF, staged and unstaged edits, and new
untracked files. REF defaults to HEAD (only the uncommitted work); pass `--base origin/main` or `--base HEAD~1` to check
commits. A rename counts both its old and its new path. Always in scope: docs/history/name_map.csv, docs/HANDOFF.md,
docs/RULES.md. Prints `scope OK` or each file outside the unit and `scope FAIL` (exit 1)."""
import fnmatch, subprocess, sys

ALWAYS = ['docs/history/name_map.csv', 'docs/HANDOFF.md', 'docs/RULES.md']


def git(*a):
    return subprocess.run(['git', *a], check=True, capture_output=True, text=True).stdout


def changed(base):
    paths = set()
    for line in git('diff', '--name-status', '-M', base).splitlines():
        paths.update(line.split('\t')[1:])
    paths.update(git('ls-files', '--others', '--exclude-standard').splitlines())
    return sorted(p for p in paths if p)


def main(argv):
    base = 'HEAD'
    if argv[:1] == ['--base']:
        if len(argv) < 2:
            sys.exit(__doc__)
        base, argv = argv[1], argv[2:]
    if not argv:
        sys.exit(__doc__)
    pats = argv + ALWAYS
    out = [p for p in changed(base) if not any(fnmatch.fnmatch(p, q) for q in pats)]
    for p in out:
        print('outside unit:', p)
    print('scope FAIL' if out else 'scope OK')
    return 1 if out else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
