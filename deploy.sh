#!/bin/bash
# deploy.sh — Deploy Flutter Web build to gh-pages
# Usage: ./deploy.sh [commit-message]
set -e

APP_DIR="/Users/ca/Documents/@typingself-app"
DEPLOY_DIR="/tmp/ts-deploy-$(date +%s)"
MSG="${1:-Auto deploy $(date '+%Y-%m-%d %H:%M')}"

echo "=== Building ==="
cd "$APP_DIR"
export PATH="/Users/ca/flutter/bin:$PATH"
flutter build web --base-href /typingself-app/ --release | tail -1

echo "=== Staging build ==="
cp -r build/web "$DEPLOY_DIR"

echo "=== Deploying ==="
git checkout gh-pages
# Remove old files (keep .git)
rm -rf assets/ canvaskit/ icons/ favicon.png flutter.js flutter_bootstrap.js flutter_service_worker.js index.html main.dart.js manifest.json version.json .dart_tool/ 2>/dev/null
cp -r "$DEPLOY_DIR"/* .
git add -A
git commit -m "$MSG"
git push origin gh-pages

echo "=== Returning to edition-3 ==="
git checkout edition-3

echo "=== Done ==="
