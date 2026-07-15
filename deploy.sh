#!/bin/bash
# Deploy @typingself to Vercel
# Usage: bash deploy.sh

echo "Building Flutter web..."
cd "$(dirname "$0")"
flutter build web --release

echo "Deploying to Vercel..."
npx vercel --prod --yes

echo "✅ Deployed to https://xingdeni.app"
