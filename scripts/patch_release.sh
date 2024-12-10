#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Check if two arguments are passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <release-branch-name>"
    exit 1
fi

# Assign arguments to variables
RELEASE_BRANCH=$1

# Checkout main branch
git checkout main

# Pull the latest changes
git pull

# Checkout release branch
git checkout $RELEASE_BRANCH

# Merge the main branch
git merge main --commit --no-edit

# Automatically bump the patch version (Y)
VERSION_FILE="ansys/api/geometry/VERSION"
if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: VERSION file not found at $VERSION_FILE"
    exit 1
fi

# Extract current version and bump Y
CURRENT_VERSION=$(cat "$VERSION_FILE")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"

# Update the VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"

# Commit the release bump
git add "$VERSION_FILE"
git commit -m "release: v$NEW_VERSION"

# Push to origin
git push origin $RELEASE_BRANCH

# Tag the release
git tag "v$NEW_VERSION"
git push origin "v$NEW_VERSION"

# Checkout main again
git checkout main
