#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.32.0"
FLUTTER_DIR="$HOME/flutter"
FLUTTER_TARBALL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

echo "==> Instalando Flutter $FLUTTER_VERSION"
if [ ! -d "$FLUTTER_DIR" ]; then
  curl -L "$FLUTTER_TARBALL" -o /tmp/flutter.tar.xz
  tar xf /tmp/flutter.tar.xz -C "$HOME"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter pub global activate fvm || true

echo "==> Build do zello_app (web release)"
cd zello_app
flutter pub get
flutter build web --release --base-href=/

echo "==> Build concluído em zello_app/build/web"
