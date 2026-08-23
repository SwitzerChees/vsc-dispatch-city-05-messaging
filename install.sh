#!/usr/bin/env sh
set -eu

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR=${1:-.}

if [ ! -f "$TARGET_DIR/deploy/overlays/block-04-ingress/kustomization.yaml" ]; then
  echo "Im Ziel fehlt der Projektstand aus Block 4 (deploy/overlays/block-04-ingress)." >&2
  exit 1
fi

for DIR in build cmd docs internal scripts deploy/overlays/block-05-messaging; do
  mkdir -p "$TARGET_DIR/$DIR"
  cp -R "$SOURCE_DIR/$DIR/." "$TARGET_DIR/$DIR/"
done

cp "$SOURCE_DIR/go.mod" "$SOURCE_DIR/go.sum" "$TARGET_DIR/"

printf 'Block 5 wurde in %s installiert.\n' "$TARGET_DIR"
printf 'Naechster Schritt: Images bauen, in teko-k8s importieren und das Block-5-Overlay anwenden.\n'
