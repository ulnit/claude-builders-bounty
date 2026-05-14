# Changelog Generator

Auto-generate structured `CHANGELOG.md` from git history.

## Quick Start (3 steps)

```bash
# 1. Make executable
chmod +x generate-changelog.sh

# 2. Run (auto-detects latest git tag)
./generate-changelog.sh

# 3. Or specify a starting tag
./generate-changelog.sh v1.0.0
```

## What it does

- Fetches all commits since the last git tag (or a tag you specify)
- Auto-categorizes commits into:
  - **Added** — `feat:`, `add:`, `new:`, `introduce:`
  - **Fixed** — `fix:`, `bug:`, `patch:`, `hotfix:`
  - **Changed** — `refactor:`, `chore:`, `docs:`, `perf:`, `ci:`, `test:`, `style:`, `build:`, `revert:`, `update:`, `improve:`
  - **Removed** — `remove:`, `delete:`, `drop:`, `deprecate:`
- Outputs a clean `CHANGELOG.md` with commit counts and a GitHub compare link
- Skips merge commits automatically
- Works with any git repo

## Example Output

```markdown
# Changelog

## [Unreleased] — 2026-05-14

> 42 commits since `v1.0.0`

### Added (12)

- feat: add user authentication module (a1b2c3d)
- add: support for dark mode toggle (e4f5g6h)

### Fixed (8)

- fix: login redirect preserves ?next= parameter (i7j8k9l)
- bug: correct timezone offset in timestamps (m0n1o2p)

### Changed (20)

- refactor: extract auth middleware into separate module (q3r4s5t)
- docs: update API documentation for v2 endpoints (u6v7w8x)

### Removed (2)

- remove: deprecated /v1/legacy endpoint (y9z0a1b)

---

📦 [View on GitHub](https://github.com/user/repo/compare/v1.0.0...HEAD)
```

## Requirements

- `git` (any version)
- `bash` (any version)
- Works on Linux, macOS, WSL

## Options

```
./generate-changelog.sh [since_tag] [output_file]

  since_tag     Tag to start from (default: latest git tag)
  output_file   Where to write (default: CHANGELOG.md)
```