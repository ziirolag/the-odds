#!/usr/bin/env bash
set -euo pipefail

REPO="ziirolag/the-odds"

git init -b main >/dev/null 2>&1 || true
git add -A
git commit -m "Publish The Odds" --allow-empty >/dev/null

gh repo view "$REPO" >/dev/null 2>&1 \
  || gh repo create "$REPO" --public --source=. --remote=origin

git remote get-url origin >/dev/null 2>&1 \
  || git remote add origin "https://github.com/$REPO.git"

git branch -M main
git push -u origin main

gh api "repos/$REPO/pages" -X POST \
  -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
  && echo "Pages enabled." \
  || echo "Pages already enabled — skipping."

echo "Waiting for the build…"
sleep 30
gh api "repos/$REPO/pages" --jq '{status: .status, url: .html_url}'
