#!/bin/bash
set -e

echo "=== Installing Flutter SDK ==="

# Download and extract Flutter
FLUTTER_VERSION="${FLUTTER_VERSION:-3.22.0}"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "Downloading Flutter ${FLUTTER_VERSION}..."
curl -sL "$FLUTTER_URL" | tar xJ -C /opt/buildhome

# Add Flutter to PATH
export PATH="/opt/buildhome/flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "=== Getting dependencies ==="
flutter pub get

echo "=== Building Flutter web ==="
flutter build web --release \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

echo "=== Build complete ==="
ls -la build/web/
