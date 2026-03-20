#!/usr/bin/env bash
set -euo pipefail

# deploy_and_push.sh
# Commits current workspace files and pushes to GitHub repository
# Usage:
#   export GITHUB_OWNER=your-github-username
#   export GITHUB_TOKEN=ghp_...
#   ./deploy_and_push.sh [repo-name]

REPO_NAME=${1:-CarsonKochanskyProject1}

if [ -z "${GITHUB_OWNER:-}" ]; then
  echo "ERROR: GITHUB_OWNER environment variable is not set. Set it to your GitHub username or org."
  exit 1
fi
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN environment variable is not set. Create a Personal Access Token and export it as GITHUB_TOKEN."
  exit 1
fi

REMOTE_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_OWNER}/${REPO_NAME}.git"

echo "Preparing to push to ${GITHUB_OWNER}/${REPO_NAME}"

# Initialize git if necessary
if [ ! -d .git ]; then
  git init
  echo "Initialized new git repository."
fi

# Add and commit changes
git add -A
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "Add generated site files"
fi

# (Re)create origin remote to ensure we push to the intended repo
if git remote | grep -q '^origin$'; then
  git remote remove origin
fi
git remote add origin "$REMOTE_URL"

# Ensure branch name
if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
else
  BRANCH_NAME=main
  git checkout -b "$BRANCH_NAME"
fi

echo "Pushing to ${REMOTE_URL} (branch: ${BRANCH_NAME})..."
git push -u origin "$BRANCH_NAME"

echo "Push complete."
