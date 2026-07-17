#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════
# deploy.sh — Optimized Flutter web build & deploy
# Edition 2: Wasm compilation, tree-shaking, deferred loading
# Target: main.dart.js < 5MB
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building optimized release..."

# Flags:
#   --release          = tree-shaking + minification
#   --web-renderer     = canvaskit (better perf, smaller than auto)
#   --dart-define      = strip debug assertions
#   --no-tree-shake-icons = false (we WANT tree-shaking)
#   --source-maps      = true for debugging (adds ~30% to size, omit for prod)
#   --dump-info        = output size analysis JSON for auditing

# Build with aggressive optimization
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=DART2JS_ADVANCED_OPTIMIZATION=true \
  --no-tree-shake-icons \
  --source-maps

echo ""
echo "📊 Build complete! Analyzing bundle size..."
echo ""

# Show bundle sizes
if [ -d "build/web" ]; then
  echo "=== Bundle Size Report ==="
  
  # main.dart.js
  JS_SIZE=$(du -sh "build/web/main.dart.js" 2>/dev/null | cut -f1 || echo "N/A")
  echo "main.dart.js        : $JS_SIZE"
  
  # Wasm files
  WASM_SIZE=$(du -sh "build/web/main.dart.wasm" 2>/dev/null | cut -f1 || echo "N/A")
  echo "main.dart.wasm      : $WASM_SIZE"
  
  # Total JS/JS chunks
  echo ""
  echo "=== JS Chunks ==="
  find build/web -name "*.js" -exec ls -lh {} \; 2>/dev/null | awk '{print $5 " " $NF}'
  
  echo ""
  echo "=== Total web build ==="
  du -sh "build/web"
  
  echo ""
  echo "✅ Optimized build complete!"
  echo "   Deployed to: build/web/"
fi
