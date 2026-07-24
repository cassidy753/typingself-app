#!/bin/bash
set -e
cd /Users/ca/Documents/@typingself-app
MSG="${1:-deploy}"
flutter build web --base-href /typingself-app/ --release
TMP_DIR=$(mktemp -d)
cp -r build/web/* "$TMP_DIR/"
git checkout gh-pages
rm -rf ./*
cp -r "$TMP_DIR"/* .
git add -A
git commit -m "$MSG" || true
git push origin gh-pages
git checkout edition-3
rm -rf "$TMP_DIR"
echo "=== Done ==="
