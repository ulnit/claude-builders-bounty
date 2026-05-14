#!/bin/bash
# generate-changelog.sh — Structured CHANGELOG.md from git history
# Usage: ./generate-changelog.sh [since_tag] [output_file]
#   If no `since_tag` is given, uses the most recent git tag.
#   Default output: CHANGELOG.md

set -euo pipefail

SINCE_TAG="${1:-$(git describe --tags --abbrev=0 2>/dev/null)}"
OUTPUT="${2:-CHANGELOG.md}"
REPO_URL=$(git config --get remote.origin.url 2>/dev/null | sed 's|\.git$||' | sed 's|git@github.com:|https://github.com/|')
REPO_NAME=$(basename "$REPO_URL" 2>/dev/null || echo "unknown")

if [ -z "$SINCE_TAG" ]; then
  echo "❌ No git tags found. Usage: $0 <tag> [output]"
  echo "   Example: $0 v1.0.0"
  exit 1
fi

echo "📝 Generating changelog since $SINCE_TAG..."

# ── Temporary files for categorization ──
TMP_ADDED=$(mktemp)
TMP_FIXED=$(mktemp)
TMP_CHANGED=$(mktemp)
TMP_REMOVED=$(mktemp)
TMP_OTHER=$(mktemp)
trap 'rm -f "$TMP_ADDED" "$TMP_FIXED" "$TMP_CHANGED" "$TMP_REMOVED" "$TMP_OTHER"' EXIT

# ── Fetch commits since tag ──
COMMITS=$(git log "${SINCE_TAG}..HEAD" --pretty=format:"%s|||%h|||%an" --no-merges 2>/dev/null)

if [ -z "$COMMITS" ]; then
  echo "⚠️  No commits since $SINCE_TAG"
  exit 0
fi

# ── Categorize each commit ──
while IFS='|||' read -r msg hash author; do
  # Normalize: trim whitespace, lowercase for matching
  lmsg=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

  case "$lmsg" in
    feat:*|feat\(*|add:*|add\(*|added*|new:*|introduce*)
      echo "- $msg (${hash})" >> "$TMP_ADDED"
      ;;
    fix:*|fix\(*|bug*|patch:*|hotfix:*|resolve*|correct*)
      echo "- $msg (${hash})" >> "$TMP_FIXED"
      ;;
    chore:*|refactor:*|perf:*|style:*|ci:*|test:*|docs:*|build:*|revert:*|update*|improve*|change*|tweak*|modify*|deprecate*)
      echo "- $msg (${hash})" >> "$TMP_CHANGED"
      ;;
    remove*|delete*|drop*|deprecate*)
      echo "- $msg (${hash})" >> "$TMP_REMOVED"
      ;;
    *)
      echo "- $msg (${hash})" >> "$TMP_OTHER"
      ;;
  esac
done <<< "$COMMITS"

# ── Move uncategorized to Changed ──
if [ -s "$TMP_OTHER" ]; then
  cat "$TMP_OTHER" >> "$TMP_CHANGED"
fi

# ── Build CHANGELOG.md ──
DATE=$(date +%Y-%m-%d)
TOTAL=$(git rev-list --count "${SINCE_TAG}..HEAD" --no-merges 2>/dev/null || echo "?")

{
  echo "# Changelog"
  echo ""
  echo "## [Unreleased] — $DATE"
  echo ""
  echo "> ${TOTAL} commits since \`${SINCE_TAG}\`"
  echo ""

  for section in "Added" "Fixed" "Changed" "Removed"; do
    tmp_var="TMP_$(echo "$section" | tr '[:lower:]' '[:upper:]')"
    tmp_file="${!tmp_var}"
    if [ -s "$tmp_file" ]; then
      count=$(wc -l < "$tmp_file")
      echo "### $section ($count)"
      echo ""
      cat "$tmp_file"
      echo ""
    fi
  done

  if [ -n "$REPO_URL" ]; then
    echo "---"
    echo ""
    echo "📦 [View on GitHub](${REPO_URL}/compare/${SINCE_TAG}...HEAD)"
    echo ""
  fi
} > "$OUTPUT"

echo "✅ Changelog written to $OUTPUT"
echo "   Added:   $(wc -l < "$TMP_ADDED" 2>/dev/null || echo 0) entries"
echo "   Fixed:   $(wc -l < "$TMP_FIXED" 2>/dev/null || echo 0) entries"
echo "   Changed: $(wc -l < "$TMP_CHANGED" 2>/dev/null || echo 0) entries"
echo "   Removed: $(wc -l < "$TMP_REMOVED" 2>/dev/null || echo 0) entries"