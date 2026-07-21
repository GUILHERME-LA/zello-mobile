#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.32.0"
CACHE_DIR="/vercel/.cache/flutter"
FLUTTER_DIR="$CACHE_DIR/flutter"
PUB_CACHE="$CACHE_DIR/pub-cache"
export PUB_CACHE
FLUTTER_TARBALL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "==> Instalando Flutter $FLUTTER_VERSION (cacheado em $CACHE_DIR)"
if [ ! -d "$FLUTTER_DIR" ]; then
  mkdir -p "$CACHE_DIR"
  curl -L "$FLUTTER_TARBALL" -o /tmp/flutter.tar.xz
  tar xf /tmp/flutter.tar.xz -C "$CACHE_DIR"
  echo "Flutter $FLUTTER_VERSION instalado em $FLUTTER_DIR"
else
  echo "Usando Flutter cacheado em $FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

git config --global --add safe.directory "$FLUTTER_DIR"

flutter --version

echo "==> Build do zello_app (web release)"
cd zello_app
flutter pub get
flutter build web --release --base-href=/

echo "==> Build concluído em zello_app/build/web"
